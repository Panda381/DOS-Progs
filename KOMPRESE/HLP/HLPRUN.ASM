
; Doplnit rozbor FCB (slu‘ba 2901h) !
; Doplnit konverzi podle aktivn¡ho PSP !

MAXFILES EQU       1024                     ; maxim ln¡ po‡et otev©en˜ch soubor–
INPBSIZE EQU       1024                     ; velikost ‡tec¡ho bufferu souboru
OUTBSIZE EQU       4400h                    ; velikost v˜stupn¡ho bufferu

; ------ definice k¢dovac¡ tabulky

MAXLENX  EQU       25                       ; min. d‚lka dlouh‚ho ©etˆzce
MAXLEN   EQU       MAXLENX+254              ; maxim ln¡ d‚lka ©etˆzce
SUBSTLEN EQU       7                        ; d‚lka nahrazen  dlouh˜m k¢dem

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ kontrola pamˆti

Start:   cmp       sp,offset Zasob          ; je z sobn¡k OK ?
         jae       Start1                   ; pamˆŸ je OK

; ------ chyba - zobrazen¡ £vodn¡ho textu

         mov       dx,offset MemTxt         ; text - nedostatek pamˆti
Chyba:   push      dx                       ; £schova textu chyby
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         pop       dx

; ------ zobrazen¡ textu chybov‚ho hl ¨en¡

         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho hl ¨en¡
         mov       ax,4cffh
         int       21h                      ; n vrat s chybou

; ------ p©edefinov n¡ z sobn¡ku

Start1:  mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku

; ------ zmen¨en¡ bloku programu na minimum

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost bloku programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0

; ------ nalezen¡ za‡ tku jm‚na programu

         cld
         mov       dx,offset HelpTxt        ; text n povˆdy
Start2:  jcxz      Chyba                    ; chyba - nic nezad no
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; mezera ?
         je        Start2                   ; mezera se p©esko‡¡
         cmp       al,9                     ; tabul tor ?
         je        Start2                   ; tabul tor se p©esko‡¡

; ------ p©enesen¡ jm‚na programu (ES=DS !)

         mov       di,offset ProgName       ; buffer jm‚na programu
Start3:  stosb                              ; ulo‘en¡ znaku
         jcxz      Start34                  ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       al," "                   ; je konec jm‚na programu ?
         je        Start32                  ; konec jm‚na programu
         cmp       al,9
         je        Start32                  ; konec jm‚na programu
         cmp       al,"/"
         jne       Start3                   ; nen¡ konec - dal¨¡ znak
Start32: dec       si                       ; n vrat ukazatele znak–
         inc       cx                       ; n vrat ‡¡ta‡e zbyl˜ch znak–
Start34: mov       al,0
         stosb                              ; ukon‡ovac¡ 0 jm‚na programu

; ------ p©enesen¡ parametr– programu

         mov       di,offset ProgComL       ; buffer p©¡kazov‚ho © dku programu
         mov       al,cl                    ; AL <- d‚lka p©¡kaz. © dku
         stosb                              ; d‚lka p©¡kazov‚ho © dku
         rep       movsb                    ; p©enesen¡ p©¡kazov‚ho © dku
         mov       al,13
         stosb                              ; ukon‡ovac¡ CR

;; ------ kontrola kompatibility syst‚mu
;
;         xor       bx,bx                    ; p©ednastaven¡ BX <- 0
;         mov       ah,51h
;         int       21h                      ; poskytnut¡ aktivn¡ho PSP
;         mov       ax,ds                    ; AX <- segment PSP
;         cmp       ax,bx                    ; je to platn  adresa PSP ?
;         je        Start4                   ; je to kompatibiln¡ syst‚m OK
;         and       byte ptr ds:[Param],not 1; p©¡znak nekompatibiln¡ho syst‚mu

; ------ p©¡prava bloku parametr– programu

Start4:  mov       ax,ds:[2ch]              ; segment prost©ed¡
         mov       ds:[ProgEnv],ax          ; segment prost©ed¡ programu
         mov       word ptr ds:[ProgComm+2],ds ; segment p©¡kazov‚ho © dku
         mov       word ptr ds:[ProgFCB1+2],ds ; segment FCB1
         mov       word ptr ds:[ProgFCB2+2],ds ; segment FCB2

; ------ £schova adresy INT 21h

         push      es
         mov       ax,3521h
         int       21h                      ; poskytnut¡ adresy INT 21h
         mov       word ptr ds:[Old21],bx   ; £schova adresy INT 21h
         mov       word ptr ds:[Old21+2],es
         pop       es

; ------ p©edefinov n¡ adresy INT 23h (p©eru¨en¡ programu)

         mov       ax,2523h
         mov       dx,offset Int23
         int       21h                      ; p©edefinov n¡ adresy INT 23h

; ------ p©edefinov n¡ adresy INT 21h

         mov       ax,2521h
         mov       dx,offset Int21
         int       21h                      ; p©edefinov n¡ adresy INT 21h

; ------ spu¨tˆn¡ zadan‚ho programu

         mov       ds:[SegmSS],ss           ; £schova segmentu SS
         mov       ax,4b00h
         mov       dx,offset ProgName       ; jm‚no programu
         mov       bx,offset ProgPack       ; blok parametr– programu
         int       21h                      ; spu¨tˆn¡ programu

; ------ inicializace registr–

Start6:  mov       ss,cs:[SegmSS]           ; n vrat segmentu SS
         mov       sp,offset Zasob          ; n vrat ukazatele z sobn¡ku

; ------ n vrat adresy INT 21h

         pushf
         lds       dx,cs:[Old21]            ; p–vodn¡ adresa INT 21h
         mov       ax,2521h
         int       21h                      ; n vrat adresy INT 21h
         popf
         push      cs
         pop       ds                       ; DS <- CS

; ------ rozli¨en¡ typu chyby

         jnc       Start8                   ; operace OK
         mov       dx,offset FndTxt         ; text - program nenalezen
         cmp       al,3
         jbe       Start7                   ; program nebo cesta nenalezena
         mov       dx,offset MemTxt         ; text - chyba pamˆti
         cmp       al,8
         je        Start7                   ; nedostatek pamˆti
         mov       dx,offset RunTxt         ; text - program nelze spusti
Start7:  jmp       Chyba                    ; chyba operace

; ------ n vratov˜ k¢d programu

Start8:  mov       ah,4dh
         int       21h                      ; poskytnut¡ n vratov‚ho k¢du

; ------ konec programu

         mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

Int23:   clc                                ; p©¡znak operace OK
         jmp       short Start6

; -----------------------------------------------------------------------------
;        obsluha INT 21h
; -----------------------------------------------------------------------------
;þ
Int21    PROC      FAR

         cmp       ah,1ah
         je        Int2108
         cmp       ah,25h
         je        Int2108
         cmp       ah,35h
         je        Int2108
         cmp       ah,30h
         jne       Int2109


Int2108:
         jmp       dword ptr cs:[Old21]     ; p–vodn¡ obsluha INT 21h


Int2109:





; ------ test, zda je otev©en¡ souboru

         pushf
         cmp       ah,6ch                   ; otev©en¡ souboru ?
         je        Int2116                  ; je otev©en¡ souboru 6ch
         cmp       ah,3dh                   ; otev©en¡ souboru ?
         jne       Int212                   ; nen¡ otev©en¡ souboru 3Dh

; ------ proveden¡ funkce otev©en¡ souboru (v z sobn¡ku je F !)

Int2116: call      dword ptr cs:[Old21]     ; funkce otev©en¡ souboru
         jc        Int2119                  ; chyba operace
         call      OpenHlp                  ; test, zda je AX soubor HLP
Int2119: jmp       Int21R                   ; n vrat z obsluhy

; ------ test, zda je uzav©en¡ souboru

Int212:  cmp       ah,3eh                   ; uzav©en¡ souboru ?
         jne       Int213                   ; nen¡ uzav©en¡ souboru
         call      ClosHlp                  ; uzav©en¡ souboru BX
         jmp       short Int218             ; uzav©en¡ souboru

; ------ test, zda je otev©en˜ soubor HLP

Int213:  call      TestHlp                  ; test, zda je soubor HLP
         jc        Int218                   ; nen¡ soubor HLP

; ------ test, zda je z pis do souboru

         cmp       ah,40h                   ; je z pis do souboru ?
         jne       Int214                   ; nen¡ z pis do souboru
         popf                               ; n vrat registru p©¡znak–
         stc                                ; p©¡znak chyby z pisu
         mov       ax,5                     ; p©¡znak odm¡tnut¡ po‘adavku
         jmp       short Int21R             ; n vrat z funkce

; ------ test, zda je ‡ten¡ ze souboru

Int214:  cmp       ah,3fh                   ; je ‡ten¡ ze souboru ?
         jne       Int215                   ; nen¡ ‡ten¡ ze souboru

; ------ na‡ten¡ dat s dekomprimac¡

         popf                               ; n vrat registru p©¡znak–
         call      ReadHlp                  ; na‡ten¡ dat ze souboru BX
         jmp       short Int21R

; ------ posun ukazatele od konce souboru

Int215:  cmp       ax,4202h                 ; je posun od konce ?
         jne       Int218                   ; nen¡ posun od konce

         popf
         call      EndUHlp                  ; posun ukazatele od konce
         jmp       short Int21R

; ------ pokra‡ov n¡ p–vodn¡ funkc¡

Int218:  popf                               ; n vrat registru p©¡znak–
         jmp       dword ptr cs:[Old21]     ; p–vodn¡ obsluha INT 21h

; ------ n vrat z operace INT 21h s navr cen¡m registru p©¡znak–

Int21R:                                     ; SS:[BP+8]=Flag
                                            ; SS:[BP+6]=CS
                                            ; SS:[BP+4]=IP
         push      bp                       ; SS:[BP+2]=BP
         push      ax                       ; SS:[BP+0]=AX
         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         pushf                              ; navr cen˜ registr p©¡znak–
         pop       ax                       ; AX <- Flag
         mov       ss:[bp+8],al             ; navr cen‚ p©¡znaky
         pop       ax
         pop       bp
         iret

Int21    ENDP

; -----------------------------------------------------------------------------
;        vol n¡ obsluhy INT 21h
; -----------------------------------------------------------------------------

Call21   PROC      NEAR

         pushf
         call      dword ptr cs:[Old21]
         ret

Call21   ENDP

; -----------------------------------------------------------------------------
;        test, zda je AX soubor HLP (a p©¡p. ulo‘en¡ identifik toru)
; -----------------------------------------------------------------------------

OpenHlp  PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

; ------ kontrola identifik toru souboru

         cmp       ax,MAXFILES              ; je ‡¡slo souboru OK ?
         jae       OpenHlp9                 ; chybn‚ ‡¡slo souboru

; ------ £schova ukazatele v souboru

         xchg      ax,bx                    ; BX <- identifik tor souboru
         call      PushUk                   ; £schova ukazatele v souboru

; ------ nastaven¡ ukazatele v souboru na za‡ tek

         xor       dx,dx                    ; offset LOW
         xor       cx,cx                    ; offset HIGH
         mov       ax,4200h
         call      call21                   ; nastaven¡ ukazatele v souboru

; ------ na‡ten¡ z hlav¡ souboru

         push      cs
         pop       ds                       ; DS <- CS
         mov       dx,offset BuffZahl       ; buffer z hlav¡ souboru
         mov       cx,6                     ; po‡et bajt– k na‡ten¡
         mov       ah,3fh
         call      call21                   ; na‡ten¡ z hlav¡ souboru
         jc        OpenHlp8                 ; chyba ‡ten¡
         cmp       ax,6                     ; na‡teno dost dat ?
         jne       OpenHlp8                 ; na‡teno m lo dat

; ------ test, zda to je soubor XCD

         cmp       word ptr ds:[BuffZahl],"X"*256 + 27 ; 1. a 2. bajt z hlav¡
         jne       OpenHlp8                 ; nen¡ HLP
         cmp       word ptr ds:[BuffZahl+2],"DC" ; 3. a 4. bajt z hlav¡
         jne       OpenHlp8                 ; nen¡ HLP
         cmp       byte ptr ds:[BuffZahl+5],0 ; parametry HIGH
         jne       OpenHlp8

; ------ je soubor HLP - nastaven¡ p©¡znaku souboru

         push      bx
         mov       cl,bl                    ; CL <- identifik tor
         and       cl,7                     ; ni‘¨¡ 3 bity
         mov       al,1                     ; nastavovac¡ bit
         shl       al,cl                    ; rotace bitu na pozici
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; identifik tor / 8
         or        ds:[JeHlp+bx],al         ; nastaven¡ p©¡znaku HLP
         pop       bx

; ------ n vrat ukazatele v souboru

OpenHlp8:call      PopUk                    ; n vrat ukazatele v souboru

; ------ n vrat registr–

OpenHlp9:pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

OpenHlp  ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru BX
; -----------------------------------------------------------------------------

ClosHlp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ kontrola identifik toru souboru

         cmp       bx,MAXFILES              ; je ‡¡slo souboru OK ?
         jae       ClosHlp9                 ; chybn‚ ‡¡slo souboru

; ------ nulov n¡ aktivn¡ho souboru

         cmp       bx,cs:[InpIdent]         ; je to aktivn¡ otev©en˜ soubor ?
         jne       ClosHlp2                 ; nen¡ to aktivn¡ otev©en˜ soubor
         mov       word ptr cs:[InpIdent],-1 ; aktivn¡ soubor je neplatn˜
         mov       word ptr cs:[FileSize],-1 ; velikost souboru nezn m 
         mov       word ptr cs:[FileSize+2],-1

; ------ nulov n¡ p©¡znaku otev©en¡ souboru

ClosHlp2:mov       cl,bl                    ; CL <- identifik tor
         and       cl,7                     ; ni‘¨¡ 3 bity
         mov       al,not 1                 ; nulovac¡ bit
         rol       al,cl                    ; rotace bitu na pozici
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; identifik tor / 8
         and       cs:[JeHlp+bx],al         ; nulov n¡ p©¡znaku HLP

; ------ n vrat registr–

ClosHlp9:pop       cx
         pop       bx
         pop       ax
         ret

ClosHlp  ENDP

; -----------------------------------------------------------------------------
;        test, zda je BX soubor HLP (-> CY=nen¡)
; -----------------------------------------------------------------------------

TestHlp  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx

; ------ kontrola identifik toru souboru

         cmp       bx,MAXFILES              ; je ‡¡slo souboru OK ?
         jae       TestHlp8                 ; chybn‚ ‡¡slo souboru

; ------ test p©¡znaku souboru HLP

         mov       cl,bl                    ; CL <- identifik tor
         and       cl,7                     ; ni‘¨¡ 3 bity
         mov       al,1                     ; testovac¡ bit
         shl       al,cl                    ; rotace bitu na pozici
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; identifik tor / 8
         test      cs:[JeHlp+bx],al         ; test p©¡znaku HLP
         jnz       TestHlp9                 ; je soubor HLP
TestHlp8:stc                                ; p©¡znak - nen¡ soubor HLP

; ------ n vrat registr–

TestHlp9:pop       cx
         pop       bx
         pop       ax
         ret

TestHlp  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ CX bajt– ze souboru BX (HLP) na adresu DS:DX
; -----------------------------------------------------------------------------
;þ
ReadHlp  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         call      PushUk                   ; £schova ukazatele v souboru

; ------ p©¡prava registr–

         push      ds
         pop       es                       ; ES <- segment k na‡ten¡ dat
         mov       di,dx                    ; DI <- offset k na‡ten¡ dat
         mov       bp,cx                    ; BP <- po‡et bajt– k na‡ten¡
         push      cs
         pop       ds                       ; DS <- segment programu

; ------ p©¡prava ukazatel– pro soubor BX

         call      InitHlp                  ; p©¡prava ukazatel–

; ------ offset ve v˜stupn¡m bufferu

ReadHlp3:mov       ax,word ptr ds:[OldUk]   ; po‘adovan˜ offset dat
         mov       cx,word ptr ds:[OldUk+2]
         sub       ax,word ptr ds:[OutBOffs] ; offset dat v bufferu
         sbb       cx,word ptr ds:[OutBOffs+2]
         jnz       ReadHlp4                 ; nen¡ je¨tˆ dosa‘eno po‡ tku
         cmp       ax,ds:[OutBNum]          ; je ukazatel OK ?
         jb        ReadHlp5                 ; ukazatel je OK

; ------ na‡ten¡ dal¨¡ch dat do bufferu

ReadHlp4:call      DeKomp                   ; na‡ten¡ dal¨¡ch dat
         jc        ReadHlp9                 ; chyba
         cmp       word ptr ds:[OutBNum],0  ; je nˆco v bufferu ?
         je        ReadHlp8                 ; konec souboru
         jmp       short ReadHlp3           ; test ukazatele

; ------ p©enesen¡ ‡ sti dat do bufferu

ReadHlp5:xchg      si,ax                    ; SI <- offset v bufferu
         mov       cx,ds:[OutBNum]          ; po‡et bajt– v bufferu
         sub       cx,si                    ; po‡et zbyl˜ch bajt– dat
         add       si,offset OutBuff        ; v˜stupn¡ buffer
         cmp       cx,bp                    ; po‘aduje se m‚nˆ ?
         jbe       ReadHlp6
         mov       cx,bp                    ; omezen¡ po‡tu bajt–
ReadHlp6:sub       bp,cx                    ; sn¡‘en¡ ‡¡ta‡e dat
         cld
         add       word ptr ds:[OldUk],cx   ; zv˜¨en¡ ukazatele v souboru
         adc       word ptr ds:[OldUk+2],0
         rep       movsb                    ; p©enesen¡ dat

; ------ test, zda se po‘aduj¡ dal¨¡ data

         or        bp,bp                    ; po‘aduj¡ se dal¨¡ data ?
         jnz       ReadHlp3                 ; po‘aduj¡ se dal¨¡ data

; ------ operace OK - po‡et na‡ten˜ch bajt– dat -> AX

ReadHlp8:mov       ax,di                    ; konec ukl dac¡ adresy
         sub       ax,dx
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

ReadHlp9:call      PopUk                    ; n vrat ukazatele v souboru
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

ReadHlp  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ dal¨¡ch komprimovan˜ch dat (DS=datov˜ segment) -> CY=chyba
; -----------------------------------------------------------------------------

DeKomp   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡sun rezervovan˜ch dat v bufferu

         push      ds
         pop       es                       ; ES <- DS
         mov       si,ds:[OutBNum]          ; po‡et bajt– v bufferu
         mov       cx,2200h                 ; omezen¡ dat k ponech n¡
         cmp       si,2200h                 ; zb˜v  dost dat ?
         ja        DeKomp0                  ; zb˜v  dost dat
         xor       cx,cx                    ; nic se neponech 
DeKomp0: sub       si,cx                    ; data k p©¡sunu
         add       word ptr ds:[OutBOffs],si ; posun offsetu bufferu
         adc       word ptr ds:[OutBOffs+2],0
         mov       di,offset OutBuff        ; v˜stupn¡ buffer
         add       si,di                    ; konec dat v bufferu
         mov       ds:[OutBNum],cx          ; nov˜ po‡et bajt– v bufferu
         cld
         rep       movsb                    ; p©¡sun zbytku dat

; ------ p©¡prava registr–

         mov       dx,ds:[WordBuff]         ; uschovan‚ p©¡znakov‚ slovo
         mov       si,ds:[InpBRead]         ; ‡tec¡ offset ze vstupn¡ho bufferu

; ------ test, zda je v˜stupn¡ buffer ji‘ pln˜

DeKomp1: cmp       di,offset OutBuff0       ; je buffer ji‘ pln˜ ?
         jae       DeKomp19                 ; buffer je ji‘ pln˜

; ------ p©esun jednoho bajtu dat bez komprese

         call      ReadBit                  ; na‡ten¡ prvn¡ho bitu
         jc        DeKomp2                  ; je komprese ©etˆzce
         call      ReadByte                 ; na‡ten¡ dal¨¡ho bajtu
         jc        DeKomp19                 ; chyba
         jz        DeKomp19                 ; konec souboru
         stosb                              ; ulo‘en¡ bajtu dat
         jmp       short DeKomp1            ; dal¨¡ data

DeKomp19:jmp       DeKomp9

; ------ p©¡prava k opakov n¡ ©etˆzce

DeKomp2: xor       bx,bx                    ; BX <- 0 offset ©etˆzce
         xor       cx,cx                    ; CX <- 0 d‚lka ©etˆzce

; -----------------------------------
;        stanoven¡ d‚lky ©etˆzce
; -----------------------------------

; ------ prvn¡ bit d‚lky ©etˆzce -> CX

         call      ReadBit                  ; na‡ten¡ bitu d‚lky
         rcl       cx,1                     ; rotace bitu do registru CX

; ------ zv˜¨en¡ ‡¡ta‡e d‚lky

DeKomp3: inc       cx
         inc       cx

; ------ na‡ten¡ p©¡znaku konce k¢du

         call      ReadBit                  ; p©¡znakov˜ bit
         jnc       DeKomp4                  ; konec k¢du

; ------ p©¡padn‚ pokra‡ov n¡ k¢du

         cmp       cl,MAXLENX-4+1           ; je ji‘ maxim ln¡ d‚lka ?
         jb        DeKomp3                  ; pokra‡ov n¡ k¢du
         inc       cx
         inc       cx                       ; korekce posledn¡ch 2 k¢d–

; ------ korekce pro n hradn¡ k¢d

DeKomp4: cmp       cl,SUBSTLEN              ; je n hradn¡ d‚lka ?
         jb        DeKomp7                  ; d‚lka je OK
         ja        DeKomp6                  ; je dlouh  d‚lka

; ------ dlouh‚ opakov n¡

         call      ReadByte                 ; na‡ten¡ bajtu
DeKomp5: jc        DeKomp19                 ; chyba
         jz        DeKomp19                 ; konec souboru
         mov       cl,al                    ; d‚lka (stav 0 a‘ 255)
         cmp       cl,255                   ; konec dek¢dov n¡ ?
         je        DeKomp19                 ; je konec
         add       cx,MAXLENX+1             ; zv˜¨en¡ d‚lky

; ------ korekce d‚lky pro dlouh˜ k¢d

DeKomp6: dec       cx

; ------------------------------------
;        stanoven¡ offsetu ©etˆzce
; ------------------------------------

; ------ d‚lka 2 nem  offset HIGH

DeKomp7: cmp       cx,2                     ; je d‚lka 2 ?
         je        DeKomp74                 ; je d‚lka 2

; ------ prvn¡ p©¡znakov˜ bit - p©¡znak offsetu HIGH=0

         call      ReadBit                  ; ‡ten¡ p©¡znakov‚ho bitu
         jc        DeKomp74                 ; offset HIGH = 0

; ------ 3 bity offsetu HIGH

         call      ReadBit                  ; na‡ten¡ bitu
         rcl       bh,1                     ; rotace bitu do registru BH
         call      ReadBit                  ; na‡ten¡ bitu
         rcl       bh,1                     ; rotace bitu do registru BH
         call      ReadBit                  ; na‡ten¡ bitu
         rcl       bh,1                     ; rotace bitu do registru BH

; ------ stav 0,1: offset HIGH = 1,2

         cmp       bh,1                     ; je stav 0,1 ?
         jbe       DeKomp72                 ; offset HIGH = 1,2

; ------ ‡tvrt˜ bit offsetu

         call      ReadBit                  ; na‡ten¡ bitu
         rcl       bh,1                     ; rotace bitu do registru BH

; ------ stav 4,7: offset HIGH=3 a‘ 6

         dec       bh                       ; stav 3 a‘ 14
         cmp       bh,6                     ; je stav 3 a‘ 6 ?
         jbe       DeKomp74                 ; je offset 3 a‘ 6
                                            ; jinak stav 7 a‘ 14
; ------ p t˜ bit offsetu

         call      ReadBit                  ; na‡ten¡ bitu
         rcl       bh,1                     ; rotace bitu do registru BH

; ------ stav 14 a‘ 23: offset HIGH=7 a‘ 13

         sub       bh,7                     ; stav 7 a‘ 22
         cmp       bh,13
         jbe       DeKomp74                 ; je offset 7 a‘ 13
                                            ; jinak stav 14 a‘ 22
; ------ ¨est˜ bit offsetu: offset HIGH=14 a‘ 31

         call      ReadBit                  ; na‡ten¡ bitu
         rcl       bh,1                     ; rotace bitu do registru BH
         sub       bh,15                    ; stav 13 a‘ 30

; ------ offset ©etˆzce LOW

DeKomp72:inc       bh                       ; korekce BH
DeKomp74:call      ReadByte                 ; na‡ten¡ offsetu d‚lky LOW
DeKomp76:jc        DeKomp9                  ; chyba
         jz        DeKomp9                  ; konec souboru
         mov       bl,al                    ; offset d‚lky LOW

; ------ p©enos ©etˆzce

         push      si                       ; £schova SI
         mov       si,di                    ; sou‡asn˜ ukazatel
         sub       si,bx                    ; posun za‡ tku ©etˆzce
         rep       movsb                    ; p©enos ©etˆzce
         pop       si
         jmp       DeKomp1                  ; dal¨¡ dek¢dov n¡

; ------ ulo‘en¡ nov‚ho stavu registr–
; sem se sk ‡e z procedury ReadBit p©i chybˆ nebo konci souboru

DeKomp9: pushf
         mov       ds:[InpBRead],si         ; ‡tec¡ offset ze vstupn¡ho bufferu
         mov       ds:[WordBuff],dx         ; p©¡znakov‚ slovo
         sub       di,offset OutBuff        ; nov˜ po‡et bajt– v bufferu
         mov       ds:[OutBNum],di          ; po‡et bajt– ve v˜stupn¡m bufferu
         popf

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

DeKomp   ENDP

; ------ na‡ten¡ bitu ze stavov‚ho slova -> CF (p©i chybˆ skok na DeKomp9)

ReadBit: shr       dx,1                     ; poskytnut¡ bitu ze stavov‚ho slova
         jnz       ReadBit2                 ; nen¡ je¨tˆ konec slova
         call      ReadByte                 ; na‡ten¡ dal¨¡ho bajtu
         jc        ReadBit9                 ; chyba
         jz        ReadBit9                 ; konec souboru
         mov       dl,al                    ; ni‘¨¡ bajt stavov‚ho slova
         call      ReadByte                 ; na‡ten¡ dal¨¡ho bajtu
         jc        ReadBit9                 ; chyba
         jz        ReadBit9                 ; konec souboru
         mov       dh,al                    ; vy¨¨¡ bajt stavov‚ho slova
         stc                                ; p©¡znak konce
         rcr       dx,1                     ; prvn¡ bit stavov‚ho slova
ReadBit2:ret

; ------ p©eru¨en¡ operace

ReadBit9:pop       cx                       ; zru¨en¡ n vratov‚ adresy
         jmp       short DeKomp9

; -----------------------------------------------------------------------------
;     ‡ten¡ bajtu ze souboru (offset v bufferu DS:SI) -> AL, ZY=konec, CY=chyba
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ kontrola, zda jsou dal¨¡ data v bufferu

         cmp       si,ds:[InpBNum]          ; jsou dal¨¡ data ?
         jae       ReadByt2                 ; je konec bufferu

; ------ na‡ten¡ bajtu z bufferu

ReadByt1:clc
         mov       al,ds:[si+InpBuff]       ; na‡ten¡ dal¨¡ho znaku
         inc       si                       ; zv˜¨en¡ ukazatele v bufferu
         ret                                ; zde je NC a NZ !

; ------ na‡ten¡ dal¨¡ho bloku dat

ReadByt2:xor       si,si                    ; ukazatel dat na za‡ tek bufferu
         call      ReadBuff                 ; na‡ten¡ dal¨¡ho bloku dat
         jc        ReadByt3                 ; chyba (p©¡znak CY)

; ------ test, zda je ji‘ konec souboru

         cmp       si,ds:[InpBNum]          ; jsou ji‘ dal¨¡ data ?
         jb        ReadByt1                 ; jsou dal¨¡ data OK
         or        si,si                    ; p©¡znaky ZY a NC
ReadByt3:ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ dal¨¡ho bloku dat ze souboru do vstupn¡ho bufferu DS -> CY chyba
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax
         push      cx
         push      dx

; ------ posun ukazatele dat

         mov       ax,ds:[InpBNum]          ; po‡et bajt– v bufferu
         add       word ptr ds:[InpBOffs],ax ; posun ukazatele v souboru
         adc       word ptr ds:[InpBOffs+2],0
         mov       word ptr ds:[InpBNum],0

; ------ nastaven¡ ukazatele v souboru

         mov       ax,4200h
         mov       bx,ds:[InpIdent]         ; identifik tor souboru
         mov       dx,word ptr ds:[InpBOffs] ; offset po‡ tku bufferu v souboru
         mov       cx,word ptr ds:[InpBOffs+2]
         call      call21                   ; nastaven¡ ukazatele v souboru

; ------ na‡ten¡ dal¨¡ho bloku dat

         mov       ah,3fh
         mov       dx,offset InpBuff        ; vstupn¡ buffer
         mov       cx,INPBSIZE              ; velikost vstupn¡ho bufferu
         call      call21                   ; na‡ten¡ vstupn¡ho bufferu
         jc        ReadBuf8                 ; chyba operace
         mov       ds:[InpBNum],ax          ; po‡et bajt– ve vstupn¡m bufferu
         clc                                ; p©¡znak operace OK

; ------ operace OK - n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         pop       bx
         cld
         ret

; ------ chyba operace - n vrat registr– (AX=chybov˜ k¢d)

ReadBuf8:pop       dx
         pop       cx
         pop       bx
         pop       bx
         cld
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        posun ukazatele BX od konce souboru
; -----------------------------------------------------------------------------

EndUHlp  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      ds

; ------ inicializace ukazatel– souboru

         push      cs
         pop       ds
         call      InitHlp                  ; inicializace ukazatel–

; ------ test, zda je velikost souboru ji‘ zn m 

         cmp       word ptr ds:[FileSize],-1
         jne       EndUHlp4
         cmp       word ptr ds:[FileSize+2],-1
         jne       EndUHlp4

; ------ zji¨tˆn¡ velikosti souboru

         mov       word ptr ds:[OldUk],-1
         mov       word ptr ds:[OldUk+2],-1
EndUHlp2:call      DeKomp                   ; na‡ten¡ dal¨¡ch dat
         jc        EndUHlp3                 ; chyba
         cmp       word ptr ds:[OutBNum],0  ; je nˆco v bufferu ?
         jne       EndUHlp2                 ; konec souboru
EndUHlp3:mov       ax,word ptr ds:[OutBOffs] ; ukazatel v souboru
         mov       word ptr ds:[FileSize],ax
         mov       ax,word ptr ds:[OutBOffs+2]
         mov       word ptr ds:[FileSize+2],ax

; ------ nastaven¡ ukazatele v souboru

EndUHlp4:mov       ax,word ptr ds:[FileSize] ; velikost LOW
         sub       ax,dx                    ; offset LOW
         xchg      ax,dx                    ; DX <- offset LOW
         mov       ax,word ptr ds:[FileSize+2] ; velikost HIGH
         sbb       ax,cx                    ; offset HIGH
         xchg      ax,cx                    ; CX <- offset HIGH
         mov       ax,4200h
         call      call21                   ; nastaven¡ ukazatele v souboru

; ------ n vrat registr–

         pop       ds
         pop       cx
         pop       bx
         ret

EndUHlp  ENDP

; -----------------------------------------------------------------------------
;        inicializace aktu ln¡ho souboru BX (DS=datov˜ segment)
; -----------------------------------------------------------------------------

InitHlp  PROC      NEAR

; ------ £schova registr–

         push      ax

; ------ test, zda to je aktu ln¡ soubor v bufferu

         cmp       bx,ds:[InpIdent]         ; je to aktu ln¡ soubor ?
         mov       ds:[InpIdent],bx         ; nov˜ aktu ln¡ soubor
         jne       InitHlp5                 ; nen¡ aktu ln¡ soubor - nulov n¡

; ------ test, zda je po‘adovan˜ ukazatel za daty v bufferu

         mov       ax,word ptr ds:[OldUk+2] ; ukazatel dat HIGH
         cmp       ax,word ptr ds:[OutBOffs+2] ; je za po‡ tkem bufferu ?
         jne       InitHlp4
         mov       ax,word ptr ds:[OldUk]   ; ukazatel dat LOW
         cmp       ax,word ptr ds:[OutBOffs]
InitHlp4:jae       InitHlp8                 ; ukazatel je za po‡ tkem bufferu
         jmp       short InitHlp6           ; nulov n¡ ukazatel– na za‡ tek

; ------ p©i jin‚m souboru velikost souboru nezn m 

InitHlp5:mov       word ptr ds:[FileSize],-1 ; velikost souboru nezn m 
         mov       word ptr ds:[FileSize+2],-1

; ------ inicializace ukazatel– na za‡ tek souboru

InitHlp6:xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[InpBOffs],6 ; offset po‡ tku vstupn¡ho bufferu
         mov       word ptr ds:[InpBOffs+2],ax
         mov       word ptr ds:[InpBNum],ax ; nejsou data ve vstupn¡m bufferu
         mov       word ptr ds:[InpBRead],ax ; ‡tec¡ offset ze vstupn¡ho bufferu
         mov       word ptr ds:[OutBOffs],ax ; offset po‡ tku v˜stupn¡ho bufferu
         mov       word ptr ds:[OutBOffs+2],ax
         mov       word ptr ds:[OutBNum],ax ; nejsou data ve v˜stupn¡m bufferu
         inc       ax                       ; AX <- 1
         mov       word ptr ds:[WordBuff],ax ; uschovan‚ p©¡znakov‚ slovo

; ------ n vrat registr–

InitHlp8:pop       ax
         ret

InitHlp  ENDP

; -----------------------------------------------------------------------------
;        £schova ukazatele v souboru BX
; -----------------------------------------------------------------------------

PushUk   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ poskytnut¡ ukazatele v souboru

         xor       dx,dx                    ; offset LOW
         xor       cx,cx                    ; offset HIGH
         mov       ax,4201h
         call      call21                   ; poskytnut¡ ukazatele v souboru

; ------ £schova ukazatele v souboru

         mov       word ptr cs:[OldUk],ax   ; aktu ln¡ ukazatel LOW
         mov       word ptr cs:[OldUk+2],dx ; aktu ln¡ ukazatel HIGH

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

PushUk   ENDP

; -----------------------------------------------------------------------------
;        n vrat ukazatele v souboru BX (uchov v  registr p©¡znak–)
; -----------------------------------------------------------------------------

PopUk    PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      cx
         push      dx

; ------ n vrat ukazatele v souboru

         mov       dx,word ptr cs:[OldUk]   ; ukazatel LOW
         mov       cx,word ptr cs:[OldUk+2] ; ukazatel HIGH
         mov       ax,4200h
         call      call21                   ; n vrat ukazatele v souboru

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         popf
         ret

PopUk    ENDP

; -----------------------------------------------------------------------------
;        dat
; -----------------------------------------------------------------------------

UvTxt    db        'HLPRUN v1.0 - rezidentni dekomprimace HLP; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte jako parametr specifikaci programu ke spusteni !',13,10,'$'
MemTxt   db        'CHYBA - nedostatek pameti ke spusteni programu !',13,10,'$'
FndTxt   db        'CHYBA - zadany program nenalezen !',13,10,'$'
RunTxt   db        'CHYBA - program nelze spustit !',13,10,'$'

BuffZahl db        6 dup(0)                 ; buffer z hlav¡ souboru XCD

Old21    dd        0                        ; uschovan  p–vodn¡ adresa INT 21h
OldUk    dd        0                        ; uschovan˜ ukazatel v souboru

; ------ buffer aktivn¡ho souboru

InpIdent dw        -1                       ; identifik tor souboru v bufferu
InpBOffs dd        0                        ; offset po‡ tku vstupn¡ho bufferu
InpBNum  dw        0                        ; po‡et bajt– ve vstupn¡m bufferu
InpBRead dw        0                        ; ‡tec¡ offset ze vstupn¡ho bufferu
OutBOffs dd        0                        ; offset po‡ tku v˜stupn¡ho bufferu
OutBNum  dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu
FileSize dd        -1                       ; detekovan  velikost souboru
WordBuff dw        1                        ; uschovan‚ p©¡znakov‚ slovo

;Param    db        1                        ; parametry
;                                            ;   bit 0: 1=kompatibiln¡ syst‚m

ProgPack label     byte                     ; blok parametr– programu
ProgEnv  dw        0                        ; segment prost©ed¡ programu
ProgComm dd        offset ProgComL          ; adresa p©¡kazov‚ho © dku programu
ProgFCB1 dd        5ch                      ; adresa prvn¡ho FCB programu
ProgFCB2 dd        6ch                      ; adresa druh‚ho FCB programu

JeHLP    db        (MAXFILES+7)/8 dup(0)    ; buffer p©¡znak– soubor–

SegmSS   dw        ?                        ; uschovan˜ segment SS

ProgComL db        128 dup(?)               ; p©¡kazov˜ © dek programu
ProgName db        128 dup(?)               ; jm‚no programu ke spu¨tˆn¡

InpBuff  db        INPBSIZE dup(?)          ; vstupn¡ buffer souboru
OutBuff  db        OUTBSIZE dup(?)          ; v˜stupn¡ buffer
OutBuff0 db        MAXLEN+10 dup(?)         ; rezerva za v˜stupn¡m bufferem

         dw        200h dup(?)
Zasob    label     byte                     ; z sobn¡k

Code     ENDS
         END       Start

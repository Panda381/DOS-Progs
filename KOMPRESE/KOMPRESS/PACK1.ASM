
; -----------------------------------------------------------------------------
;
;                              K O M P
;
;                        komprese program–
;
; -----------------------------------------------------------------------------


BuffIO   EQU       10h                     ; velikost vstup. a v˜stup. bufferu
BuffSize EQU       1000h                    ; velikost kompresn¡ho bufferu
StrLen   EQU       1000h                      ; d‚lka ©etˆzce

                                          ;* definice buffer–
Buff     EQU       offset Konec             ; kompresn¡ buffer
BuffIn   EQU       Buff + BuffSize + StrLen +4 ; vstupn¡ buffer
BuffOut  EQU       BuffIn + BuffIO          ; v˜stupn¡ buffer




code     segment
         assume    cs:code,ds:code
         org       100h

                                          ;* zobrazen¡ £vodn¡ho textu
Start:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

                                          ;* rozbor zad n¡ zdrojov‚ho souboru
         mov       si,81h                   ; za‡ tek textu
         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[80h]              ; po‡et znak– zadan‚ho textu
         call      RozbFile                 ; rozbor zad n¡ jm‚na souboru
         jnc       Start3                   ; zad n¡ OK

Start1:  mov       dx,offset ZadTxt         ; text n povˆdy
Start2:  mov       ah,9
         int       21h
         mov       ax,4c01h                 ; n vrat s chybou
         int       21h                      ; konec programu

                                          ;* pokus o otev©en¡ zdrojov‚ho souboru
Start3:  mov       ax,3d00h                 ; funkce otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        Start1                   ; chybn‚ zad n¡ jm‚na souboru
         mov       ds:[ZdrojId],ax          ; identifik tor zdrojov‚ho souboru

                                          ;* rozbor zad n¡ c¡lov‚ho souboru
         call      RozbFile                 ; rozbor zad n¡ jm‚na souboru
         jc        Start1                   ; chyba zad n¡

                                          ;* pokus o otev©en¡ c¡lov‚ho souboru
         mov       ah,3ch                   ; funkce vytvo©en¡ souboru
         xor       cx,cx                    ; atributy souboru
         int       21h                      ; vytvo©en¡ c¡lov‚ho souboru
         jc        Start1                   ; chybn‚ zad n¡ jm‚na souboru
         mov       ds:[CilId],ax            ; identifik tor v˜stupn¡ho souboru

                                          ;* inicializace kompresn¡ho bufferu
         cld                                ; smˆr nahoru
         mov       di,Buff                  ; kompresn¡ buffer
         xor       al,al                    ; po‡ te‡n¡ inicializa‡n¡ bajt
         mov       cx,256                   ; po‡et vzork–
Start4:  push      cx
         mov       cx,BuffSize/256          ; d‚lka jednoho vzorku v bufferu
         rep       stosb                    ; z pis jednoho vzorku
         pop       cx
         inc       al                       ; zv˜¨en¡ vzorku
         loop      Start4                   ; z pis dal¨¡ho vzorku
         mov       si,Buff
         mov       di,Buff+BuffSize
         mov       cx,StrLen
         rep       movsb

         call      Komp                     ; komprese programu

         call      ClrStr
         call      ClrBuf                   ; vypr zdnˆn¡ p©echodn‚ho bufferu

                                          ;* z pis v˜stupn¡ho bufferu
         call      WritBuf                  ; z pis obsahu v˜stupn¡ho bufferu

                                          ;* uzav©en¡ soubor–
         mov       bx,ds:[ZdrojId]          ; identifik tor zdrojov‚ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ zdrojov‚ho souboru
         mov       bx,ds:[CilId]            ; identifik tor c¡lov‚ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ c¡lov‚ho souboru

         mov       ax,4c00h
         int       21h                      ; n vrat z programu bez chyby

; -----------------------------------------------------------------------------
;        Komprese souboru
; -----------------------------------------------------------------------------

Komp0:   ret

PUBLIC   Komp

Komp:    cld
         mov       bp,Buff                  ; ukl dac¡ adresa do bufferu
         mov       ds:[StrBeg],bp           ; adresa za‡ tku ©etˆzce

                                          ;* zarovn n¡ ukazatele na za‡ tek buf.
Komp1:   cmp       bp,offset(Buff+BuffSize) ; je konec bufferu ?
         jb        Komp2                    ; nen¡ je¨tˆ konec bufferu
         mov       bp,Buff                  ; p©esun na za‡ tek bufferu

                                          ;* ‡ten¡ dal¨¡ho bajtu ze vstupu
Komp2:   call      readbyte                 ; ‡ten¡ dal¨¡ho bajtu ze vstupu
         jc        komp0                    ; chyba
         je        komp0                    ; konec souboru

                                          ;* ulo‘en¡ bajtu do bufferu
         mov       ds:[bp],al               ; ulo‘en¡ bajtu do kompres. bufferu
         cmp       bp,offset(Buff+StrLen)   ; je v oblasti duplikace ?
         jae       Komp3                    ; nen¡ duplikace dat
         mov       ds:[bp+BuffSize],al      ; duplikace bajtu
Komp3:   inc       bp                       ; zv˜¨en¡ adresy v bufferu

                                          ;* p©i p©eplnˆn¡ bufferu vypr zdnˆn¡
Komp33:  mov       bx,ds:[StringN]          ; ‡¡ta‡ shodn˜ch bajt–
         cmp       bx,StrLen+2              ; dosa‘eno maxim ln¡ d‚lky ?
         je        Komp7                    ; je maxim ln¡ d‚lka - vypr zdnˆn¡

                                          ;* nalezen¡ shodn‚ho ©etˆzce v tabulce
         mov       si,ds:[StrBeg]           ; za‡ tek nezpracovan‚ho ©etˆzce
         inc       si
         mov       di,Buff                  ; kompresn¡ buffer
         mov       cx,BuffSize              ; velikost kompresn¡ho bufferu

Komp4:   jcxz      Komp7                    ; nen¡ dal¨¡ bajt
;         push      ax
         mov       al,ds:[si-1]             ; prvn¡ bajt ©etˆzce
         repne     scasb                    ; pokus o nalezen¡ bajtu
;         pop       ax
         jne       Komp7                    ; ©etˆzec nenalezen

         push      cx
         push      di
         push      si
         mov       cx,bx                    ; d‚lka porovn van‚ho ©etˆzce
         repe      cmpsb                    ; porovn n¡ ©etˆzc–
         pop       si
         pop       di
         pop       cx
         jne       Komp4                    ; ©etˆzec nesouhlas¡ - dal¨¡

                                          ;* test, zda to je ukl dan˜ ©etˆzec
         cmp       si,bp                    ; je za‡ tek pod koncem ?
         ja        Komp5                    ; ne, za‡ tek je nad koncem
         cmp       di,bp                    ; je to ukl dan˜ bajt ?
         ja        Komp6                    ; nen¡ to ukl dan˜ ©etˆzec - OK
         cmp       di,si                    ; je to ukl dan˜ ©etˆzec ?
         jb        Komp6                    ; nen¡ to ukl dan˜ ©etˆzec - OK
         jmp       short Komp4              ; zahrnuje ukl dan˜ ©etˆzec - neplat¡
Komp5:   cmp       di,bp                    ; je to ukl dan˜ ©etˆzec ?
         jbe       Komp4                    ; je to ukl dan˜ ©etˆzec - dal¨¡
         cmp       di,si                    ; je to ukl dan˜ ©etˆzec ?
         jae       Komp4                    ; je to ukl dan˜ ©etˆzec - dal¨¡

                                          ;* ©etˆzec nalezen - zv˜¨en¡ shody
Komp6:   inc       bx                       ; zv˜¨en¡ po‡tu bajt– v ©etˆzci
         mov       ds:[StringN],bx          ; nov˜ po‡et bajt– shody
         dec       di                       ; adresa za‡ tku ©etˆzce
         mov       ds:[StrAdr],di           ; adresa nalezen‚ho ©etˆzce
Komp11:  jmp       short Komp1              ; dal¨¡ bajt

                                          ;* ©etˆzec nenalezen - vypr zdnˆn¡
Komp7:   call      ClrStr                   ; vypr zdnˆn¡ textu ©etˆzce
         inc       word ptr ds:[StringN]
         mov       di,bp
         dec       di
         mov       ds:[StrBeg],di
;         call      ClrStr
         jmp       short Komp11

komp9:   ret

; -----------------------------------------------------------------------------
;        Vypr zdnˆn¡ bufferu ©etˆzce
; -----------------------------------------------------------------------------

PUBLIC   ClrStr
ClrStr:  mov       cx,ds:[StringN]          ; po‡et bajt– ©etˆzce shody
         jcxz      ClrStr8                  ; nen¡ ‘ dn˜ bajt
         mov       word ptr ds:[StringN],0  ; vynulov n¡ bufferu ©etˆzce
         mov       di,offset Buff0+1        ; buffer k ukl d n¡ bajt–
         add       di,ds:[BuffN]            ; adresa k ulo‘en¡ dal¨¡ho bajtu

                                          ;* test, zda je pouze 1 bajt
         mov       si,ds:[StrBeg]           ; adresa za‡ tku ©etˆzce
         lodsb                              ; znak k v˜stupu
         cmp       cx,1                     ; je 1 znak ?
         je        ClrStr6                  ; je 1 znak - nen¡ komprese

                                          ;* je kompresn¡ slovo
         mov       ax,ds:[StrAdr]           ; adresa za‡ tku ©etˆzce
         sub       ax,Buff                  ; offset ©etˆzce v bufferu

         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1

         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1

         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1

         sub       cl,2                     ; korekce (rozsah 2 a‘ 34 bajt–)
         or        al,cl                    ; + po‡et bajt–
         stosb                              ; ulo‘en¡ ni‘¨¡ho bajtu slova
         inc       word ptr ds:[BuffN]      ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       al,ah                    ; vy¨¨¡ bajt slova

         mov       bl,ds:[Mask]             ; maska pro nastaven¡ atribut–
         or        ds:[Buff0],bl            ; nastaven¡ p©¡znaku slova

ClrStr6: stosb                              ; ulo‘en¡ dal¨¡ho bajtu
         inc       word ptr ds:[BuffN]      ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
ClrStr7: shl       byte ptr ds:[Mask],1     ; rotace masky na novou pozici
         jc        ClrBuf                   ; buffer zaplnˆn - vypr zdnˆn¡
ClrStr8: ret

; -----------------------------------------------------------------------------
;        Vypr zdnˆn¡ p©echodn‚ho bufferu
; -----------------------------------------------------------------------------

PUBLIC   ClrBuf
ClrBuf:
         mov       si,offset Buff0          ; p©echodn˜ buffer
         mov       cx,ds:[BuffN]            ; po‡et bajt– v bufferu
         jcxz      ClrBuf3                  ; nen¡ ‘ dn˜ bajt k v˜stupu

         cld                                ; smˆr nahoru
         inc       cx                       ; zap¡¨e se i registr p©¡znak–
ClrBuf1: lodsb                              ; bajt p©¡znak–
         call      WritByte                 ; z pis bajtu na v˜stup
         loop      ClrBuf1                  ; z pis dal¨¡ho bajtu/slova

ClrBuf3: mov       ds:[BuffN],cx            ; nulov n¡ bufferu
         mov       byte ptr ds:[Mask],1     ; inicializace masky
         ret




; -----------------------------------------------------------------------------
;        Rozbor jm‚na souboru z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

PUBLIC   RozbFile
                                          ;* nalezen¡ za‡ tku jm‚na souboru
RozbFile:stc                                ; p©ednastaven¡ p©¡znaku chyby
         cld                                ; smˆr nahoru
         jcxz      RozbFil3                 ; nen¡ dal¨¡ znak - chyba
         mov       dx,si                    ; p©ednastaven¡ za‡ tku jm‚na
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; je platn˜ znak ?
         jbe       RozbFile                 ; je oddˆlova‡ - dal¨¡ znak

                                          ;* nalezen¡ konce jm‚na
RozbFil1:jcxz      RozbFil2                 ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "                   ; je platn˜ znak ?
         ja        RozbFil1                 ; je platn˜ znak - dal¨¡ znak
         dec       si                       ; n vrat posledn¡ho znaku

RozbFil2:mov       byte ptr ds:[si],0       ; ozna‡en¡ konce jm‚na souboru
         inc       si                       ; p©esko‡en¡ ukon‡ovac¡ 0
         clc                                ; p©¡znak operace OK

RozbFil3:ret


; -----------------------------------------------------------------------------
;        Vstup znaku ze vstupn¡ho souboru (CY=chyba, ZY=konec)
; -----------------------------------------------------------------------------

PUBLIC   ReadByte
ReadByte:push      bx
         mov       bx,ds:[UkazIn]           ; ukazatel dat ve vstupn¡m bufferu
         cmp       ds:[NumIn],bx            ; je nˆco v bufferu ?
         ja        ReadByt1                 ; je je¨tˆ nˆco v bufferu

                                          ;* na‡ten¡ bufferu
         call      ReadBuf                  ; na‡ten¡ nov‚ho obsahu bufferu
         jc        ReadByt2                 ; chyba operace
         je        ReadByt2                 ; nejsou dal¨¡ data
         mov       bx,ds:[UkazIn]           ; ukazatel dat ve vstupn¡m bufferu

                                          ;* ‡ten¡ bajtu z bufferu
ReadByt1:mov       al,ds:[bx+BuffIn]        ; ‡ten¡ bajtu z bufferu
         inc       word ptr ds:[UkazIn]     ; zv˜¨en¡ ukazatele v bufferu
ReadByt2:pop       bx
         ret

; -----------------------------------------------------------------------------
;        €ten¡ vstupn¡ho bufferu z disku (CY=chyba, ZY=konec)
; -----------------------------------------------------------------------------

PUBLIC   ReadBuf
ReadBuf: push      ax
         push      bx
         push      cx
         push      dx
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         mov       bx,ds:[ZdrojId]          ; identifik tor zdrojov‚ho souboru
         mov       cx,BuffIO                ; velikost bufferu
         mov       dx,BuffIn                ; vstupn¡ buffer
         int       21h                      ; ‡ten¡ dat ze souboru
         jc        ReadBuf2                 ; byla chyba operace
         mov       ds:[NumIn],ax            ; nov˜ po‡et bajt– v bufferu
         mov       word ptr ds:[UkazIn],0   ; nov˜ ukazatel v bufferu
         or        ax,ax                    ; bylo nˆco na‡teno ?
ReadBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Z pis bajtu do v˜stupn¡ho bufferu (CY=chyba, NZ=disk je pln˜)
; -----------------------------------------------------------------------------

PUBLIC   WritByte
WritByte:push      bx
         mov       bx,ds:[NumOut]           ; po‡et bajt– ve v˜stupn¡m bufferu
         cmp       bx,BuffIO                ; je ji‘ buffer zaplnˆn ?
         jb        WritByt1                 ; jsou je¨tˆ nˆjak  data v bufferu

                                          ;* ulo‘en¡ obsahu bufferu na disk
         call      WritBuf                  ; z pis bufferu na disk
         jc        WritByt2                 ; chyba operace
         jnz       WritByt2                 ; disk je pln˜
         mov       bx,ds:[NumOut]           ; ukazatel dat v bufferu

                                          ;* ulo‘en¡ bajtu do bufferu
WritByt1:mov       ds:[bx+BuffOut],al       ; ulo‘en¡ bajtu do bufferu
         inc       word ptr ds:[NumOut]     ; zv˜¨en¡ po‡tu bajt– v bufferu
         cmp       al,al                    ; p©¡znaky NC, ZY
WritByt2:pop       bx
         ret

; -----------------------------------------------------------------------------
;        Z pis v˜stupn¡ho bufferu na disk (CY=chyba, NZ=disk je pln˜)
; -----------------------------------------------------------------------------

PUBLIC   WritBuf
WritBuf: push      ax
         push      bx
         push      cx
         push      dx
         mov       ah,40h                   ; funkce z pisu na disk
         mov       bx,ds:[CilId]            ; identifik tor v˜stupn¡ho souboru
         mov       cx,ds:[NumOut]           ; po‡et bajt– ve v˜stupn¡m bufferu
         or        cx,cx
         jz        WritBuf1                 ; nejsou ‘ dn  data k z pisu
         mov       dx,BuffOut               ; v˜stupn¡ buffer
         int       21h                      ; z pis dat na disk
         jc        WritBuf1                 ; chyba z pisu
         mov       word ptr ds:[NumOut],0   ; nulov n¡ obsahu bufferu
         cmp       ax,cx                    ; souhlas¡ po‡et zapsan˜ch bajt– ?
         clc                                ; p©¡znak operace OK
WritBuf1:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

Mask     db        1                        ; maska pro nastaven¡ atribut–
BuffN    dw        0                        ; ‡¡ta‡ bajt– v p©echodn‚m bufferu
Buff0    db        0                        ; bajt p©¡znak– (0=bajt, 1=slovo)
         db        16 dup(0)                ; buffer bajt– pro v˜stup

StrBeg   dw        0                        ; adresa za‡ tku ©etˆzce
StrAdr   dw        0                        ; adresa shodn‚ho ©etˆzce v tabulce
StringN  dw        0                        ; po‡et shodn˜ch bajt–


NumIn    dw        0                        ; po‡et bajt– ve vstupn¡m bufferu
UkazIn   dw        0                        ; ukazatel ve vstupn¡m bufferu
NumOut   dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu

ZdrojId  dw        0                        ; identifik tor zdrojov‚ho souboru
CilId    dw        0                        ; identifik tor c¡lov‚ho souboru


UvTxt    db        'KOMP V1.0 - komprese programu; (c) Miroslav Nemecek',13,10,'$'

ZadTxt   db        'Chyba zadani - zadejte jmeno programu (.COM) ke kompresi'
         db        '               a jmeno vystupniho souboru (.EXE) !',13,10,'$'

         EVEN                               ; zarovn n¡ na sudou adresu

Konec    label     byte                     ; konec programu

code     ends
         end       start

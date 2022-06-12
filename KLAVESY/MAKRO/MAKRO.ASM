
BUFFSIZE EQU       1000h                    ; velikost bufferu souboru

KORIG    EQU       5ch-103h

KLIC1    EQU       4e5ah                    ; AX
KLIC2    EQU       653Bh                    ; BX
KLIC3    EQU       99A3h                    ; CX
KLIC4    EQU       0A4Ch                    ; DX
KLIC5    EQU       0E56Ah                   ; BX v˜stup

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

SHIFT    EQU       1                        ; p©esmyka‡ SHIFT
CTRL     EQU       2                        ; p©esmyka‡ CTRL
ALT      EQU       4                        ; p©esmyka‡ ALT
FLAG1    EQU       8                        ; p©¡znak 1
FLAG2    EQU       10h                      ; p©¡znak 2
FLAG3    EQU       20h                      ; p©¡znak 3
FLAG4    EQU       40h                      ; p©¡znak 4
FLAG5    EQU       80h                      ; p©¡znak 5

KODFLAG  EQU       0E5D0h                   ; k¢d pro ovl d n¡ p©¡znak–
                                            ;  bit 0 a‘ 2: ‡¡slo p©¡znaku 0-4
                                            ;  bit 3: 1=nastaven¡, 0=nulov n¡

KODOLD   EQU       KODFLAG+14               ; k¢d pro p–vodn¡ kl vesu
KODALL   EQU       KODFLAG+15               ; k¢d pro v¨echny kl vesy

MaxFile  EQU       86                       ; maxim ln¡ d‚lka jm‚na souboru


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init

RezBeg   label     byte                     ; za‡ tek rezidentn¡ ‡ sti

; -----------------------------------------------------------------------------
;        data rezidentn¡ho programu
; -----------------------------------------------------------------------------

Old16    dd        0                        ; p–vodn¡ adresa INT 16h

Param    db        0                        ; parametry
                                            ;   bit 0:
                                            ;   bit 1: 1=‡ek  se hork  kl vesa
                                            ;   bit 2: 1=prob¡h  definice makra
                                            ;   bit 3:
                                            ;   bit 4: 1=byl parametr "R"
                                            ;   bit 5: 1=m¢d ASCII textu
                                            ;   bit 6: 1=po‘adavek odinstalov n¡
                                            ;   bit 7: 1=je prvn¡ instalace

CitTest  dw        0                        ; ‡¡ta‡ test– p©ipravenosti znaku

HotKey   dw        8300h                    ; hork  kl vesa definice makra(ALT=)
HotSwc   db        SHIFT+ALT                ; p©esmyka‡e hork‚ kl vesy

BuffBeg  dw        offset RezEnd+KORIG      ; za‡ tek bufferu
BuffEnd  dw        offset RezEnd+KORIG      ; konec dat v bufferu
BuffMax  dw        offset RezEnd+KORIG+1000 ; maxim ln¡ konec bufferu
                                            ; za koncem mus¡ z–stat 6 bajt– !
                                            ; (z toho 1 bajt na p©esah kl vesy)

FLAGS    db        0                        ; p©¡znaky (FLAG1 a‘ FLAG5)

; Struktura jednoho makra v bufferu:
;   0: (2) offset dal¨¡ho makra
;   2: (1) p©esmyka‡e hork‚ kl vesy makra
;   3: (2) hork  kl vesa makra
;   5: (2*x) kl vesy makra (ka‘d  kl vesa 2 bajty)
; Za bufferem mus¡ z–stat rezerva 6 bajt–, aby mohla b˜t ru¨ena star  makra.

MakroR   dw        0                        ; ‡tec¡ adresa makra
MakroRN  dw        0                        ; po‡et kl ves ke ‡ten¡ makra (0=ne)

OldKey   dw        0                        ; p–vodn¡ kl vesa (vyvolala makro)
Povel    db        0                        ; uschovan˜ povel INT 16h

MaxTest  dw        10                       ; po‡et test– kl vesnice

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

Int16    PROC      FAR

; ------ test instalace programu

         pushf
         cmp       ax,KLIC1
         jne       Int162
         cmp       bx,KLIC2
         jne       Int162
         cmp       cx,KLIC3
         jne       Int162
         cmp       dx,KLIC4
         jne       Int162
         push      cs
         pop       es
         mov       bx,KLIC5
         popf
         iret

; ------ jin‚ funkce - p–vodn¡ obsluha kl vesnice

Int161:  popf
         jmp       dword ptr cs:[Old16+KORIG]

; ------ test, zda je slu‘ba vstupu nebo testu znaku z kl vesnice

Int162:  test      ah,0eeh                  ; test nebo vstup znaku ?
         jnz       Int161                   ; nen¡ obsluhovan  funkce
         mov       cs:[Povel+KORIG],ah      ; £schova ‡¡sla povelu
         popf

; ------ £schova registr–

         push      dx
         push      si
         push      di
         push      ds

; ------ p©¡prava DS

         push      cs
         pop       ds                       ; DS <- CS


; ====== obsluha interpretace makra

; ------ test, zda je vstup kl vesy z makra

Int163:  call      TestMac                  ; test, zda je kl vesa z makra
         jz        Int164                   ; nen¡ kl vesa z makra
         test      byte ptr ds:[Povel+KORIG],1 ; je test kl vesnice ?
         jz        Int1634                  ; nen¡ test - je vstup znaku

; ------ test, zda je povolena kl vesa z makra

         cmp       word ptr ds:[CitTest+KORIG],0 ; ‡¡t. test–-povolena kl vesa ?
         je        Int1632                  ; kl vesa povolena
         dec       word ptr ds:[CitTest+KORIG] ; ‡¡t n¡ test–
Int1631: xor       ax,ax                    ; nastaven¡ p©¡znaku ZY
         jmp       short Int1633            ; kl vesa nepovolena
Int1632: or        sp,sp                    ; nastaven¡ p©¡znaku NZ
Int1633: jmp       Int169                   ; n vrat

; ------ vstup znaku z makra

Int1634: push      word ptr ds:[MaxTest+KORIG] ; max. test– kl vesnice
         pop       word ptr ds:[CitTest+KORIG] ; nov˜ ‡¡ta‡ test–
         add       word ptr ds:[MakroR+KORIG],2 ; zv˜¨en¡ ukazatele kl ves
         dec       word ptr ds:[MakroRN+KORIG] ; sn¡‘en¡ po‡tu kl ves
         call      StorMac                  ; ulo‘en¡ znaku do makra
         jmp       Int168                   ; n vrat


; ====== vstup znaku z kl vesnice

; ------ test, zda je p©ipraven znak z kl vesnice

Int164:  call      GetShift                 ; poskytnut¡ p©esmyka‡– do DL
         call      TestKey                  ; je p©ipraven znak z kl vesnice ?
         jnz       Int165                   ; je p©ipraven znak z kl vesnice

; ------ nen¡ p©ipraven znak - ‡ek n¡ na znak nebo konec

         test      byte ptr ds:[Povel+KORIG],1 ; je to test kl vesnice ?
         jnz       Int1631                  ; je to test kl vesnice - konec
         jmp       short Int164             ; jinak ‡ek n¡ na znak z kl vesnice


; ====== obsluha hork‚ kl vesy (zapnut¡ nebo vypnut¡ definice makra)

; ------ test, zda je hork  kl vesa

Int165:  cmp       ax,ds:[HotKey+KORIG]     ; je to hork  kl vesa ?
         je        Int1650                  ; k¢d kl vesy souhlas¡
Int16500:jmp       Int166                   ; nen¡ to hork  kl vesa
Int1650: cmp       dl,ds:[HotSwc+KORIG]     ; souhlas¡ p©esmyka‡e ?
         jne       Int16500                 ; nen¡ to hork  kl vesa
         call      InpKey                   ; zru¨en¡ znaku z bufferu kl vesnice

; ------ zah jen¡ definice makra

         test      byte ptr ds:[Param+KORIG],bit1+bit2 ; je ji‘ definice ?
         jnz       Int1652                  ; je ji‘ definice makra
         mov       si,ds:[BuffEnd+KORIG]    ; konec dat = za‡ tek makra
         mov       word ptr ds:[si],5       ; offset dal¨¡ho makra
         or        byte ptr ds:[Param+KORIG],bit1 ; p©¡znak hork‚ kl vesy
         mov       ax,1356
         call      Beep                     ; p¡pnut¡
         mov       ax,1076
         call      Beep
         mov       ax,905
         call      Beep
         mov       ax,678
         call      Beep
Int1651: jmp       short Int164             ; dal¨¡ znak

; ------ ukon‡en¡ definice makra

Int1652:
         mov       ax,678
         call      Beep
         mov       ax,905
         call      Beep                     ; p¡pnut¡
         mov       ax,1076
         call      Beep
         mov       ax,1356
         call      Beep

         mov       dh,ds:[Param+KORIG]      ; p©¡znaky
         and       byte ptr ds:[Param+KORIG],not bit1+bit2 ; zru¨en¡ p©¡znak–
         test      dh,bit1                  ; byla ji‘ hork  kl vesa ?
         jnz       Int164                   ; nebyla je¨tˆ hork  kl vesa

; ------ zru¨en¡ star‚ definice makra

         mov       si,ds:[BuffEnd+KORIG]    ; za‡ tek makra
         mov       dl,ds:[si+2]             ; p©esmyka‡e
         mov       ax,ds:[si+3]             ; kl vesa makra
         call      SrcMac                   ; nalezen¡ makra v bufferu -> DI
         jc        Int1653                  ; makro nenalezeno
         call      DelMac                   ; zru¨en¡ makra DI
         mov       si,ds:[BuffEnd+KORIG]    ; nov˜ za‡ tek makra

; ------ za©azen¡ nov‚ definice makra

Int1653: mov       ax,ds:[si]               ; d‚lka makra
         cmp       ax,5                     ; jsou nˆjak‚ znaky makra ?
         jbe       Int1651                  ; bylo jen zru¨en¡ star‚ho makra
         add       ds:[BuffEnd+KORIG],ax    ; posun konce dat v bufferu
         jmp       short Int1651


; ====== definice hork‚ kl vesy makra

; ------ zad n¡ hork‚ kl vesy pro makro

Int166:  test      byte ptr ds:[Param+KORIG],bit1 ; ‡ek  se hork  kl vesa ?
         jz        Int1663                  ; ne‡ek  se hork  kl vesa
         and       byte ptr ds:[Param+KORIG],not bit1 ; zru¨en¡ hork‚ kl vesy
         or        byte ptr ds:[Param+KORIG],bit2 ; p©¡znak definice makra
         call      InpKey                   ; zru¨en¡ znaku z bufferu kl vesnice
         mov       si,ds:[BuffEnd+KORIG]    ; za‡ tek makra
         mov       ds:[si+3],ax             ; hork  kl vesa
         mov       ds:[si+2],dl             ; p©esmyka‡e hork‚ kl vesy
         mov       ax,678
         call      Beep
         call      Beep
         call      Beep
Int1662: jmp       short Int1651            ; dal¨¡ kl vesa

; ====== zah jen¡ interpretace makra

; ------ nalezen¡ makra v bufferu maker

Int1663: call      SrcMac                   ; nalezen¡ makra -> DI
         jc        Int167                   ; makro nenalezeno
         call      InpKey                   ; zru¨en¡ kl vesy z bufferu kl ves

; ------ zah jen¡ interpretace makra

         mov       ax,ds:[di]               ; offset dal¨¡ho makra
         sub       ax,5                     ; ode‡ten¡ z hlav¡
         shr       ax,1                     ; po‡et kl ves makra
         mov       ds:[MakroRN+KORIG],ax    ; po‡et kl ves ke ‡ten¡ makra
         add       di,5                     ; za‡ tek makra
         mov       ds:[MakroR+KORIG],di     ; ‡tec¡ adresa makra
         push      word ptr ds:[MaxTest+KORIG] ; max. test–
         pop       word ptr ds:[CitTest+KORIG] ; ‡¡ta‡ test–
         jmp       Int163                   ; dal¨¡ kl vesa


; ------ ulo‘en¡ znaku do definice makra

Int167:  test      byte ptr ds:[Povel+KORIG],1 ; je test ?
         jnz       Int1674                  ; je test kl vesnice
         call      InpKey                   ; vstup znaku z kl vesnice
         call      StorMac                  ; ulo‘en¡ znaku do makra
         call      KorKey                   ; korekce znaku
         jnz       Int168                   ; znak je OK
Int1673: jmp       short Int1662            ; znak neplatn˜ - dal¨¡ znak

Int1674: call      KorKey                   ; korekce znaku
         jnz       Int169                   ; znak je OK
         call      InpKey                   ; zru¨en¡ znaku z bufferu
         jmp       short Int1662            ; jinak dal¨¡ znak

; ------ n vrat registr– - registr p©¡znak– se nemˆn¡

Int168:  pop       ds
         pop       di
         pop       si
         pop       dx
         iret

; ------ n vrat registr– - nov‚ nastaven¡ registru p©¡znak–

Int169:  pop       ds
         pop       di
         pop       si
         pop       dx
         sti
         ret       +2

Int16    ENDP

; -----------------------------------------------------------------------------
;        test znaku z kl vesnice (ZY=nen¡)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

TestKeyK:mov       ah,11h
         call      Exec16
         ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

InpKeyK: mov       ah,10h
         call      Exec16
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        vol n¡ funkce INT 16h (DS=CS !)
; -----------------------------------------------------------------------------

Exec16   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di

         pushf
         call      dword ptr ds:[Old16+KORIG]

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Exec16   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ p©esmyka‡– do DL
; -----------------------------------------------------------------------------

GetShift PROC      NEAR

         push      ax
         push      ds

         mov       ax,40h
         mov       ds,ax
         mov       dl,ds:[17h]              ; p©esmyka‡e

         pop       ds
         pop       ax
                                            ; n sleduje korekce p©esmyka‡– !

GetShift ENDP

; -----------------------------------------------------------------------------
;        korekce p©esmyka‡– v DL
; -----------------------------------------------------------------------------

KorShift PROC      NEAR

         push      ax
         mov       al,dl
         and       dl,SHIFT                 ; SHIFT
         shr       al,1
         and       al,SHIFT+CTRL+ALT
         or        dl,al
         pop       ax
         ret

KorShift ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ kl vesy AX do definice makra
; -----------------------------------------------------------------------------

StorMac  PROC      NEAR

         test      byte ptr ds:[Param+KORIG],bit2 ; prob¡h  definice makra ?
         jz        StorMac3                 ; neprob¡h  definice makra

         push      si
         push      ax

         mov       si,ds:[BuffEnd+KORIG]    ; definovan‚ makro
         mov       ax,si                    ; adresa za‡ tku makra
         add       ax,ds:[si]               ; offset konce makra
         cmp       ax,ds:[BuffMax+KORIG]    ; bylo by p©ete‡en¡ bufferu ?
         jae       StorMac2                 ; bylo by p©ete‡en¡ bufferu
         add       word ptr ds:[si],2       ; zv˜¨en¡ d‚lky dat v bufferu
         xchg      ax,si                    ; star˜ offset konce dat

         pop       ax
         mov       ds:[si],ax               ; ulo‘en¡ kl vesy do bufferu
         pop       si
         ret

StorMac2:mov       ax,1356
         call      Beep
         call      Beep
         pop       ax
         pop       si
StorMac3:ret

StorMac  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ hork‚ kl vesy AX s p©esmyka‡i DL v bufferu -> DI (CY=nen¡)
; -----------------------------------------------------------------------------

SrcMac   PROC      NEAR

         push      dx
         mov       ds:[OldKey+KORIG],ax     ; £schova hledan‚ kl vesy

; ------ p©¡prava registr–

         mov       di,ds:[BuffBeg+KORIG]    ; za‡ tek dat

; ------ test, zda je konec dat

SrcMac2: cmp       di,ds:[BuffEnd+KORIG]    ; je ji‘ konec dat v bufferu ?
         jae       SrcMac8                  ; konec dat

; ------ test, zda je hledan  hork  kl vesa

         cmp       word ptr ds:[di+3],KODALL ; je to univerz ln¡ kl vesa ?
         je        SrcMac3                  ; je to univerz ln¡ kl vesa
         cmp       ax,ds:[di+3]             ; souhlas¡ kl vesa ?
         jne       SrcMac4                  ; kl vesa nesouhlas¡ - dal¨¡
SrcMac3: mov       dh,ds:[di+2]             ; p©esmyka‡e a p©¡znaky
         and       dh,SHIFT+CTRL+ALT        ; p©esmyka‡e
         cmp       dh,dl                    ; souhlas¡ p©esmyka‡e ?
         jne       SrcMac4                  ; p©esmyka‡e nesouhlas¡
         mov       dh,ds:[FLAGS+KORIG]      ; p©¡znaky
         xor       dh,FLAG1+FLAG2+FLAG3+FLAG4+FLAG5
         test      dh,ds:[di+2]             ; souhlas¡ p©¡znaky ?
         jz        SrcMac9                  ; kl vesa nalezena OK

; ------ adresa dal¨¡ kl vesy

SrcMac4: add       di,ds:[di]               ; adresa dal¨¡ kl vesy
         jnc       SrcMac2                  ; test dal¨¡ kl vesy

; ------ kl vesa nenalezena

SrcMac8: stc                                ; p©¡znak - kl vesa nenalezena
SrcMac9: pop       dx
         ret

SrcMac   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ makra DI z bufferu (p©isunou se i data do konce bufferu)
; -----------------------------------------------------------------------------

DelMac   PROC      NEAR

; ------ £schova registr–

         pushf
         push      cx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       es

; ------ adresa dal¨¡ho makra

         mov       si,ds:[di]               ; offset dal¨¡ho makra
         sub       ds:[BuffEnd+KORIG],si    ; posun konce dat v bufferu
         add       si,di                    ; adresa dal¨¡ho makra

; ------ p©¡sun zbytku dat

         mov       cx,ds:[BuffMax+KORIG]    ; konec bufferu
         add       cx,6                     ; p©esah p©es konec
         sub       cx,si                    ; d‚lka zbytku dat
         cld
         shr       cx,1                     ; d‚lka zbytku dat ve slovech
         rep       movsw                    ; p©esun dat po slovech
         adc       cx,cx
         rep       movsb                    ; p©¡sun zbytku dat - lich˜ bajt

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       cx
         popf
         ret

DelMac   ENDP

; -----------------------------------------------------------------------------
;        test, zda je nˆjak‚ makro (ZY=nen¡, -> AX=kl vesa)
; -----------------------------------------------------------------------------

TestMac  PROC      NEAR

         push      cx

TestMac1:cmp       word ptr ds:[MakroRN+KORIG],0 ; je nˆjak‚ makro ?
         je        TestMac9                 ; nen¡ ‘ dn‚ makro

         push      si
         mov       si,ds:[MakroR+KORIG]     ; ‡tec¡ adresa makra
         mov       ax,ds:[si]               ; p©ipraven  kl vesa
         pop       si

         push      ax
         and       al,not 0fh
         cmp       ax,KODFLAG               ; je ovl d n¡ p©¡znak– ?
         pop       ax
         jne       TestMac3                 ; nen¡ ovl d n¡ p©¡znak–

         cmp       al,KODOLD AND 0ffh
         je        TestMac2                 ; z–st v  p–vodn¡ kl vesa

         mov       cl,al                    ; ‡¡slo p©¡znaku
         and       cl,7                     ; ‡¡slo p©¡znaku
         cmp       cl,4                     ; maxim ln¡ p©¡znak
         ja        TestMac4                 ; neplatn˜ p©¡znak - ignoruje se
         mov       ah,bit3
         and       al,bit3                  ; nastaven¡/nulov n¡
         shl       ax,cl                    ; rotace p©¡znaku na pozici
         not       ah
         and       byte ptr ds:[FLAGS+KORIG],ah ; nulov n¡ p©¡znaku
         or        byte ptr ds:[FLAGS+KORIG],al ; nov‚ nastaven¡ p©¡znaku
         jmp       short TestMac4

TestMac2:mov       ax,ds:[OldKey+KORIG]     ; p–vodn¡ kl vesa
TestMac3:call      KorKey                   ; test platnosti kl vesy
         jnz       TestMac9                 ; kl vesa je platn 

TestMac4:add       word ptr ds:[MakroR+KORIG],2 ; zv˜¨en¡ ukazatele kl ves
         dec       word ptr ds:[MakroRN+KORIG] ; sn¡‘en¡ po‡tu kl ves
         jmp       short TestMac1

TestMac9:pop       cx
         ret

TestMac  ENDP

; -----------------------------------------------------------------------------
;        korekce k¢du kl vesy v AX (ZY=kl vesa neplat¡)
; -----------------------------------------------------------------------------

KorKey   PROC      NEAR

; ------ rozli¨en¡, zda je roz¨¡©en  kl vesnice

         test      byte ptr ds:[Povel+KORIG],10h ; je roz¨¡©en  kl vesnice ?
         jnz       KorKey2                  ; je roz¨¡©en  kl vesnice

; ------ korekce [Enter] na Enter a [/] na /

         cmp       ah,0e0h                  ; je zdvojen  kl vesa [Enter], [/] ?
         jne       KorKey1                  ; nen¡ zdvojen  kl vesa
         mov       ah,1ch                   ; SCAN k¢d pro ENTER
         cmp       al,"/"                   ; je kl vesa "/" v numerick‚m poli ?
         jne       KorKey4                  ; nen¡ kl vesa "/"
         mov       ah,35h                   ; SCAN k¢d pro kl vesu "/"
         jmp       short KorKey4

; ------ kontrola maxim ln¡ho SCAN k¢du kl vesy

KorKey1: cmp       ah,84h                   ; maxim ln¡ k¢d kl vesy
         ja        KorKey3                  ; SCAN k¢d kl vesy nepovolen

; ------ korekce zvl ¨tn¡ ©idic¡ kl vesy na bˆ‘nou

         cmp       al,0e0h                  ; je ©¡dic¡ kl vesa ?
         jne       KorKey2                  ; nen¡ ©¡dic¡ kl vesa
         or        ah,ah                    ; je to znak s Alt ?
         jz        KorKey4                  ; je to znak s Alt
         mov       al,0                     ; korekce na bˆ‘nou ©¡dic¡ kl vesu
         jmp       short KorKey4

; ------ kontrola, zda je zak zan  kl vesa

KorKey2: cmp       al,0f0h                  ; je kl vesa roz¨¡©en‚ kl vesnice ?
         jne       KorKey4                  ; nen¡
         or        ah,ah                    ; je to znak s Alt ?
         jz        KorKey4                  ; je to znak s Alt
         mov       al,0                     ; korekce na bˆ‘nou kl vesu
         test      byte ptr ds:[Povel+KORIG],10h ; je roz¨¡©en  kl vesnice ?
         jnz       KorKey4                  ; je to roz¨¡©en  kl vesnice

; ------ kl vesa nen¡ povolen 

KorKey3: xor       ax,ax                    ; p©¡znak nepovolen‚ kl vesy
         ret

; ------ kl vesa povolen  OK

KorKey4: or        sp,sp                    ; NZ=p©¡znak kl vesy OK
         ret

KorKey   ENDP

; -----------------------------------------------------------------------------
;        p¡pnut¡ (frekvence AX)
; -----------------------------------------------------------------------------

Beep     PROC      NEAR

         cli
         push      ax
         in        al,[61h]
         or        al,3
         out       [61h],al

         mov       al,0b6h
         out       [43h],al
         pop       ax

         out       [42h],al
         xchg      ah,al
         out       [42h],al
         xchg      ah,al

         push      cx
BeepK:   mov       cx,40000
         loop      $
         pop       cx

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al
         pop       ax

         ret

Beep     ENDP

RezEnd   label     byte                     ; konec rezidentn¡ ‡ sti

; *****************************************************************************
;
;                          Instalace programu
;
; *****************************************************************************
;þ
; ------ zobrazen¡ £vodn¡ho textu

Init:    mov       dx,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ korekce pro po‡¡ta‡e XT

         push      ds
         mov       ax,0f000h
         mov       ds,ax
         cmp       byte ptr ds:[0fffeh],0fch
         pop       ds
         jbe       Init001                  ; je AT
         mov       byte ptr ds:[TestKeyK+1],1
         mov       byte ptr ds:[InpKeyK+1],0

; ------ inicializace hodin

Init001: push      ds
         xor       dx,dx
         xor       cx,cx
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
Init01:  sti
         cmp       ax,ds:[46ch]
         je        Init01
         mov       ax,ds:[46ch]

Init02:  cmp       ax,ds:[46ch]
         jne       Init03
         inc       cx
         jnz       Init02
         inc       dx
         jnz       Init02

Init03:  xchg      ax,cx
         shr       dx,1
         rcr       ax,1
         shr       dx,1
         rcr       ax,1

         or        dx,dx
         jz        Init04
         mov       ax,-1

Init04:  or        ax,ax
         jnz       Init05
         mov       ax,1000
Init05:
         pop       ds
         mov       word ptr ds:[BeepK+1],ax

; ------ £schova p©¡kazov‚ho © dku do bufferu

         mov       si,81h
         mov       di,offset Command
         mov       cl,ds:[si-1]
         mov       ch,0
         cld
         rep       movsb                    ; £schova p©¡kazov‚ho © dku
         mov       al,0
         stosb                              ; ozna‡en¡ konce textu

; ------ posun programu dol–

         mov       si,offset RezBeg
         mov       di,offset RezBeg+KORIG
         mov       cx,offset(RezEnd-RezBeg)
         rep       movsb                    ; p©esun programu dol–

; ------ test, zda je ji‘ program nainstalov n

         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         mov       dx,KLIC4
         int       16h                      ; test instalace programu
         cmp       bx,KLIC5
         je        Init1
         push      cs
         pop       es
         or        byte ptr ds:[Param+KORIG],bit7 ; p©¡znak prvn¡ instalace
Init1:   mov       ds:[RezSegm],es

; ------ test, zda je nˆco zad no

         mov       si,offset Command        ; buffer p©¡kazov‚ho © dku
Init16:  call      RozbSpc                  ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
         call      RozbChr
         jnc       Init18                   ; je nˆco zad no
Init164: test      byte ptr ds:[Param+KORIG],bit7 ; je to prvn¡ instalace ?
         jz        Init201                  ; nen¡ to prvn¡ instalace
Chyba0:  mov       dx,offset HelpTxt        ; text n povˆdy
Chyba:   call      DispTxt                  ; zobrazen¡ textu n povˆdy
         mov       ax,4c01h
         int       21h

Init18:  cmp       al,";"
         je        Init164
         cmp       al,"/"
         je        Init16                   ; znak "/" se ignoruje
         dec       si                       ; n vrat znaku

; ------ na‡ten¡ prvn¡ho znaku parametru

Init2:   call      RozbSpc                  ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
         call      RozbChr                  ; na‡ten¡ prvn¡ho znaku
         jnc       Init21
Init201: jmp       Init4
Init21:  cmp       al,"/"
         je        Init2                    ; znak "/" se ignoruje
         cmp       al,";"
         je        Init201                  ; konec textu

; ------ definice velikosti bufferu "B cislo"

         cmp       al,"B"
         jne       Init22
         mov       dx,offset ReInsTxt       ; text - nutno odinstalovat
         test      byte ptr ds:[Param+KORIG],bit7 ; je ji‘ nainstalov n ?
         jz        Chyba                    ; chyba - je ji‘ nainstalov n
         call      RozbNum                  ; dek¢dov n¡ ‡¡sla
         jc        Chyba0                   ; nezad no - chyba zad n¡ parametr–
         cmp       ax,60000
         jb        Init222
Init210: mov       ax,60000                 ; omezen¡ shora
Init222: add       ax,offset RezEnd+KORIG   ; adresa konce bufferu
         mov       bx,sp
         sub       bx,200h
         cmp       ax,bx
         jb        Init223
         mov       ax,bx
Init223: mov       ds:[BuffMax+KORIG],ax    ; konec bufferu
         jmp       short Init2              ; dal¨¡ parametr

; ------ definice po‡tu opakov n¡ testu kl vesnice "T ‡¡slo"

Init22:  cmp       al,"T"
         jne       Init22A

         call      RozbNum                  ; dek¢dov n¡ ‡¡sla
         jc        Chyba0                   ; nezad no - chyba zad n¡ parametr–
         mov       es:[MaxTest+KORIG],ax    ; konec bufferu
         jmp       short Init2              ; dal¨¡ parametr

; ------ po‘adavek odinstalov n¡ programu "!"

Init22A: cmp       al,"!"
         jne       Init23
         mov       dx,offset NeniTxt        ; text - nen¡ nainstalov n
         test      byte ptr ds:[Param+KORIG],bit7 ; je ji‘ nainstalov n ?
         jnz       Chyba                    ; chyba - nen¡ nainstalov n
         or        byte ptr ds:[Param+KORIG],bit6 ; po‘adavek odinstalov n¡
         jmp       short Init2              ; dal¨¡ parametr

; ------ jin˜ parametr - test, zda je ji‘ nainstalov n

Init23:  mov       dx,offset NutnoTxt
         test      byte ptr ds:[Param+KORIG],bit7 ; je ji‘ nainstalov n ?
         jnz       Init232                  ; chyba - nen¡ nainstalov n

; ------ parametr "R soubor" - na‡ten¡ definice maker do pamˆti

         cmp       al,"R"
         jne       Init25
         call      ReadMac                  ; na‡ten¡ souboru maker
Init231: jnc       Init233
Init232: jmp       Chyba                    ; nˆjak  chyba
Init233: jmp       short Init2              ; dal¨¡ parametr

; ------ parametr "W soubor" - z pis definice maker do souboru

Init25:  cmp       al,"W"
         jne       Init26
         call      WritMac                  ; z pis maker do souboru
         jmp       short Init231

; ------ parametr "H" - definice hork‚ kl vesy

Init26:  cmp       al,"H"
         jne       Init27
         call      RozbKey                  ; rozbor zad n¡ kl vesy
         and       dl,SHIFT+CTRL+ALT
         mov       cl,dl
         mov       dx,offset HelpTxt        ; text n povˆdy
         jc        Init232
         mov       es:[HotKey+KORIG],ax     ; hork  kl vesa
         mov       es:[HotSwc+KORIG],cl     ; p©esmyka‡e hork‚ kl vesy
         jmp       short Init233

; ------ parametr "M" - start zadan‚ho makra

Init27:  cmp       al,"M"
         jne       Init28
         call      RozbKey                  ; rozbor zad n¡ kl vesy
         and       dl,SHIFT+CTRL+ALT
         mov       cl,dl
         mov       dx,offset HelpTxt        ; text n povˆdy
         jc        Init232
         mov       dl,cl

         push      ds
         push      es
         pop       ds
         call      SrcMac+KORIG             ; nalezen¡ makra -> DI
         pop       ds
         mov       dx,offset NMacTxt        ; text - nenalezena
         jc        Init232

         mov       ax,es:[di]               ; offset dal¨¡ho makra
         sub       ax,5                     ; ode‡ten¡ z hlav¡
         shr       ax,1                     ; po‡et kl ves makra
         mov       es:[MakroRN+KORIG],ax    ; po‡et kl ves ke ‡ten¡ makra
         add       di,5                     ; za‡ tek makra
         mov       es:[MakroR+KORIG],di     ; ‡tec¡ adresa makra
         push      word ptr es:[MaxTest+KORIG] ; max. test–
         pop       word ptr es:[CitTest+KORIG] ; ‡¡ta‡ test–
         jmp       short Init233


Init28:  jmp       Chyba0

; ------ test, zda lze program odinstalovat

Init4:   test      byte ptr ds:[Param+KORIG],bit6 ; po‘aduje se odinstalov n¡ ?
         jz        Init5
         call      TestDIns                 ; test, zda lze program odinstalovat
         jnc       Init42
         mov       dx,offset NelzeTxt
Init41:  jmp       Chyba

; ------ odinstalov n¡ programu z pamˆti

Init42:  call      DeInst                   ; odinstalov n¡ programu
         mov       dx,offset DeInsTxt       ; text - byl odinstalov n
         call      DispTxt
         int       20h

; ------ test, zda je prvn¡ instalace programu

Init5:   test      byte ptr ds:[Param+KORIG],bit7 ; je prvn¡ instalace ?
         jnz       Init51                   ; je prvn¡ instalace
         call      DispStav                 ; zobrazen¡ stavu
         int       20h

; ------ hl ¨en¡ o instalaci

Init51:  mov       dx,offset InstTxt
         call      DispTxt

         call      DispStav                 ; zobrazen¡ stavu

; ------ £schova vektoru INT 16h

         mov       ax,3516h
         int       21h
         mov       word ptr ds:[Old16+KORIG],bx
         mov       word ptr ds:[Old16+KORIG+2],es

; ------ instalace obsluhy INT 16h

         mov       dx,offset Int16+KORIG
         mov       ax,2516h
         int       21h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]
         mov       ah,49h
         int       21h

; ------ instalace do pamˆti

         mov       dx,ds:[BuffMax+KORIG]    ; adresa konce
         add       dx,6                     ; rezerva za koncem pro jedno makro

         int       27h                      ; instalace do pamˆti

; -----------------------------------------------------------------------------
;        test, zda lze program odinstalovat
; -----------------------------------------------------------------------------

TestDIns PROC      NEAR

; ------ test adresy INT 16h

         mov       ax,3516h
         int       21h
         mov       ax,es
         cmp       ax,ds:[RezSegm]
         je        TestDIn9
         stc
TestDIn9:ret

TestDIns ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu z pamˆti
; -----------------------------------------------------------------------------

DeInst   PROC      NEAR

         mov       es,ds:[RezSegm]

; ------ n vrat INT 16h

         push      ds
         lds       dx,es:[Old16+KORIG]
         mov       ax,2516h
         int       21h
         pop       ds

; ------ uvolnˆn¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ bloku programu
         ret

DeInst   ENDP

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
;        na‡ten¡ souboru maker
; -----------------------------------------------------------------------------
;þ
ReadMac  PROC      NEAR

; ------ rozbor jm‚na souboru

         mov       di,offset SoubBuff       ; buffer jm‚na souboru
         call      RozbFile                 ; rozbor jm‚na souboru
         mov       dx,offset HelpTxt
         jc        ReadMac9                 ; chyba zad n¡

; ------ otev©en¡ souboru

         mov       dx,offset SoubBuff       ; buffer jm‚na souboru
         mov       ax,3d00h
         int       21h
         mov       dx,offset FndTxt
         jc        ReadMac9                 ; soubor nenalezen
         mov       ds:[SoubIdnt],ax         ; identifik tor souboru

; ------ na‡ten¡ obsahu bufferu

         and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ m¢du ASCII textu
         mov       word ptr ds:[BuffNum],0  ; nulov n¡ obsahu bufferu
         mov       word ptr ds:[BuffRead],0 ; offset ‡tec¡ adresy
         mov       byte ptr ds:[BuffChr],0
         mov       byte ptr ds:[BuffChr2],0
         mov       word ptr ds:[CitRad],1
         mov       word ptr ds:[TopRad],1

         call      ReadBuff                 ; na‡ten¡ obsahu bufferu

; ------ uzav©en¡ souboru

         mov       bx,ds:[SoubIdnt]
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         clc
ReadMac9:ret

ReadMac  ENDP


; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu bufferu
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      si

         mov       di,es:[BuffBeg+KORIG]    ; ukl dac¡ adresa do bufferu
         test      byte ptr ds:[Param+KORIG],bit4 ; byl ji‘ parametr "R" ?
         jz        ReadBf01                 ; nebyl je¨tˆ parametr "R"
         mov       di,es:[BuffEnd+KORIG]    ; star˜ konec dat v bufferu
ReadBf01:or        byte ptr ds:[Param+KORIG],bit4 ; p©¡znak parametru "R"

; ------ zah jen¡ ukl d n¡ prvn¡ho makra

         mov       si,di                    ; £schova za‡ tku makra
         mov       word ptr es:[si],5       ; d‚lka z hlav¡ makra
         mov       word ptr es:[si+3],-1    ; hork  kl vesa - neplatn 
         mov       byte ptr es:[si+2],0     ; p©esmyka‡e
         add       di,5                     ; ukl dac¡ adresa makra
         cmp       di,es:[BuffMax+KORIG]    ; konec bufferu ?
         jb        ReadBf21
ReadBf95:jmp       ReadBuf9                 ; buffer je ji‘ pln˜

; ------ na‡ten¡ jedn‚ kl vesy

ReadBf21:mov       ax,ds:[CitRad]
         mov       ds:[TopRad],ax
         call      ReadKey                  ; na‡ten¡ k¢du kl vesy
         jnc       ReadBf22                 ; kl vesa OK

         call      ReadB
         jc        ReadBf95

         push      ax
         mov       dx,offset SyntTxt1
         call      DispTxt
         mov       ax,ds:[TopRad]
         call      DispNum
         mov       dx,offset SyntTxt2
         call      DispTxt
         pop       ax

ReadB212:cmp       al,13
         je        ReadBf21
         call      ReadB
         jc        ReadBf95
         jmp       short ReadB212

; ------ test, zda je to hork  kl vesa

ReadBf22:test      byte ptr ds:[Param+KORIG],bit5 ; je m¢d ASCII ?
         jz        ReadB226                 ; nen¡ m¢d ASCII

         push      ax
         call      ReadB
         jc        ReadB224
         cmp       al,'"'
         jne       ReadB223
         call      ReadB
         jc        ReadB220
         cmp       al,'"'
         je        ReadB221
         call      ReadRet
ReadB220:and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ m¢du ASCII
         jmp       short ReadB224

ReadB221:call      ReadRet
         mov       al,'"'
ReadB223:call      ReadRet
         stc                                ; p©¡znak - z–st v  m¢d ASCII
ReadB224:pop       ax
         jc        ReadBuf3                 ; z–st v  m¢d ASCII


ReadB226:push      ax
         call      ReadBSpc                 ; vypu¨tˆn¡ mezer
         jc        ReadBf23
         cmp       al,"="                   ; je hork  kl vesa ?
         je        ReadBf23                 ; je hork  kl vesa
         call      ReadRet                  ; n vrat znaku
         stc                                ; p©¡znak - nen¡ hork  kl vesa
ReadBf23:pop       ax
         jc        ReadBuf3                 ; nen¡ hork  kl vesa

; ------ vytvo©en¡ nov‚ kl vesy

         cmp       word ptr es:[si+3],-1
         je        ReadBf24
         cmp       word ptr es:[si],5
         jbe       ReadBf24
         mov       si,di                    ; £schova za‡ tku makra
ReadBf24:mov       di,si
         mov       word ptr es:[si],5       ; d‚lka z hlav¡ makra
         mov       word ptr es:[si+3],ax    ; hork  kl vesa
         mov       byte ptr es:[si+2],dl    ; p©esmyka‡e
         add       di,5                     ; ukl dac¡ adresa makra
         cmp       di,es:[BuffMax+KORIG]    ; konec bufferu ?
         jae       ReadBuf9                 ; buffer je ji‘ pln˜
ReadB218:jmp       ReadBf21                 ; dal¨¡ kl vesa

; ------ ulo‘en¡ kl vesy do bufferu

ReadBuf3:mov       es:[di],ax               ; ulo‘en¡ k¢du kl vesy
         add       word ptr es:[si],2       ; zv˜¨en¡ d‚lky kl vesy
         inc       di
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         cmp       di,es:[BuffMax+KORIG]    ; je buffer ji‘ pln˜ ?
         jb        ReadB218                 ; buffer je¨tˆ nen¡ pln˜

; ------ kontrola velikosti posledn¡ho makra

ReadBuf9:cmp       word ptr es:[si+3],-1
         je        ReadBf91                 ; kl vesa neplatn 
         cmp       word ptr es:[si],5+2     ; minim ln¡ d‚lka makra
         jae       ReadBf92                 ; d‚lka makra je OK
ReadBf91:mov       di,si                    ; zru¨en¡ posledn¡ho makra
ReadBf92:mov       es:[BuffEnd+KORIG],di    ; konec ukl dac¡ adresy v bufferu

         pop       si
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;   ‡ten¡ k¢du kl vesy (CY=konec nebo chyba, AX<-k¢d kl vesy, DL<-p©esmyka‡e)
; -----------------------------------------------------------------------------

ReadKey  PROC      NEAR

         push      bx

; ------ ‡ten¡ znaku v ASCII m¢du

         mov       dl,0                     ; p©esmyka‡e - ‘ dn‚
         test      byte ptr ds:[Param+KORIG],bit5 ; je ASCII m¢d ?
         jz        ReadKey3                 ; nen¡ ASCII m¢d
ReadKey1:call      ReadB                    ; na‡ten¡ znaku
         jc        ReadKey9                 ; konec souboru
         mov       ah,0fh
         cmp       al,9
         je        ReadKey9                 ; tabel tor je povolen
         cmp       al," "                   ; je platn˜ znak ?
         jb        ReadKey1                 ; nen¡ platn˜ znak
         cmp       al,'"'
         je        ReadKey2                 ; znak uvozovek
ReadKe12:mov       ah,0
         cmp       al,127
         ja        ReadKey9                 ; je znak s ALT
         mov       bx,ax
         mov       ah,ds:[bx+AsciScan-32]   ; SCAN k¢d kl vesy
         clc
         jmp       short ReadKey9

; ------ ukon‡en¡ ASCII m¢du

ReadKey2:call      ReadB                    ; ‡ten¡ druh‚ho znaku '"'
         jc        ReadKe22                 ; nen¡ dal¨¡ znak
         cmp       al,'"'                   ; je zdvojen˜ znak '"' ?
         je        ReadKe12                 ; je zdvojen˜ znak
         call      ReadRet                  ; n vrat znaku
ReadKe22:and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ ASCII m¢du

; ------ vypu¨tˆn¡ po‡ te‡n¡ch mezer

ReadKey3:call      ReadBSpc                 ; vypu¨tˆn¡ mezer
         jc        ReadKey9                 ; konec souboru

; ------ zah jen¡ ASCII m¢du

         cmp       al,'"'
         jne       ReadKey4
         or        byte ptr ds:[Param+KORIG],bit5 ; zah jen¡ ASCII m¢du
         jmp       short ReadKey1           ; dek¢dov n¡ znaku v ASCII m¢du

; ------ ‡ten¡ znaku v HEX k¢du

ReadKey4:cmp       al,'$'
         jne       ReadKey5
         call      ReadHex                  ; ‡ten¡ znaku v HEX k¢du
         jmp       short ReadKey9

; ------ ‡ten¡ znaku v dekadick‚m k¢du

ReadKey5:cmp       al,"#"
         jne       ReadKey6
         call      ReadDek                  ; ‡ten¡ znaku v dekadick‚m k¢du
         jmp       short ReadKey9

; ------ ‡ten¡ k¢du kl vesy

ReadKey6:cmp       al,"{"
         je        ReadKe62
         cmp       al,"["
         jne       ReadKey7
ReadKe62:call      ReadK                    ; ‡ten¡ k¢du kl vesy (prvn¡ znak AL)
         jmp       short ReadKey9

; ------ ‡ten¡ ©¡dic¡ho k¢du

ReadKey7:cmp       al,"("
         jne       ReadKey8
         call      ReadCtr                  ; ‡ten¡ ©idic¡ho k¢du
         jmp       short ReadKey9

; ------ ‡ten¡ p©esmyka‡–

ReadKey8:call      ReadSwc                  ; na‡ten¡ p©esmyka‡e do DL
         jc        ReadKey9                 ; chyba
         jmp       short ReadKey3           ; dal¨¡ kl vesa

ReadKey9:pop       bx
         ret

ReadKey  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ p©esmyka‡e do DL (v AL je prvn¡ znak, CY=neplatn˜ p©esmyka‡)
; -----------------------------------------------------------------------------

ReadSwc  PROC      NEAR

         push      bx
         push      cx
         push      si

         mov       ah,"-"                   ; koncov˜ znak
         call      ReadTxt                  ; na‡ten¡ textu

         mov       si,offset TextSwc        ; tabulka text– p©esmyka‡–
         call      ReadSrc                  ; nalezen¡ textu
         jc        ReadSwc8                 ; text nenalezen

         mov       cl,bl                    ; ‡¡slo textu
         mov       al,bit0
         shl       al,cl                    ; rotace bitu na pozici
         or        dl,al                    ; nastaven¡ p©esmyka‡e

ReadSwc8:
         pop       si
         pop       cx
         pop       bx
         ret

ReadSwc  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ k¢du ©¡dic¡ho povelu do AX (v AL je prvn¡ znak, CY=neplatn˜ k¢d)
; -----------------------------------------------------------------------------

ReadCtr  PROC      NEAR

         push      si
         push      bx

         mov       ah,")"                   ; koncov˜ znak
         call      ReadTxt                  ; na‡ten¡ textu
         mov       si,offset TextCtr        ; tabulka ©¡dic¡ch k¢d–
         call      ReadSrc                  ; nalezen¡ textu
         jc        ReadCtr8                 ; nenalezen

         cmp       bl,5
         jb        ReadCtr2
         add       bl,8-5
         cmp       bl,10+8-5
         jb        ReadCtr2
         inc       bx
ReadCtr2:or        bx,KODFLAG
         xchg      ax,bx

ReadCtr8:pop       bx
         pop       si
         ret

ReadCtr  ENDP

; -----------------------------------------------------------------------------
;  ‡ten¡ k¢du kl vesy do AX (AL=prvn¡ znak, DL=p©esmyka‡e, CY=neplatn  kl vesa)
; -----------------------------------------------------------------------------

ReadK    PROC      NEAR

         push      si
         push      bx

         mov       ah,al                    ; po‡ te‡n¡ znak
         add       ah,2                     ; koncov˜ znak
         call      ReadTxt                  ; na‡ten¡ textu
         mov       si,offset TextKey        ; tabulka text– kl ves
         call      ReadSrc                  ; nalezen¡ textu kl vesy
         jc        ReadK9                   ; neplatn  kl vesa

         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; ‡¡slo kl vesy * 8
         test      dl,SHIFT+CTRL+ALT        ; nen¡ p©esmyka‡
         jz        ReadK4
         test      dl,CTRL+ALT
         jz        ReadK3                   ; je SHIFT
         test      dl,ALT
         jz        ReadK2                   ; je Ctrl

         inc       bx                       ; Alt
         inc       bx
ReadK2:  inc       bx                       ; Ctrl
         inc       bx
ReadK3:  inc       bx                       ; Shift
         inc       bx
ReadK4:  mov       ax,ds:[bx+KodKey]        ; k¢d kl vesy
         clc

ReadK9:  pop       bx
         pop       si
         ret

ReadK    ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ textu v tabulce SI do BX (CY=nenalezen)
; -----------------------------------------------------------------------------

ReadSrc  PROC      NEAR

         push      cx

         mov       ch,0
         xor       bx,bx                    ; ukazatel ‡¡sla textu

ReadSrc2:mov       cl,ds:[si]               ; d‚lka jm‚na kl vesy
         stc
         jcxz      ReadSrc6                 ; konec - kl vesa nenalezena

         call      ReadTst                  ; test textu
         je        ReadSrc6                 ; kl vesa nalezena
         inc       bx
         add       si,cx                    ; adresa dal¨¡ kl vesy
         jmp       short ReadSrc2

ReadSrc6:pop       cx
         ret

ReadSrc  ENDP

; -----------------------------------------------------------------------------
;        test jednoho textu DS:SI na shodu s bufferem
; -----------------------------------------------------------------------------

ReadTst  PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

         push      ds
         pop       es
         mov       di,offset BuffText
         mov       ch,0
         mov       cl,ds:[si]               ; d‚lka textu + 1
         inc       si
         dec       cx
         cld
         repe      cmpsb                    ; porovn n¡ text–

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

ReadTst  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ textu (v AL je prvn¡ znak, v AH posledn¡ znak)
; -----------------------------------------------------------------------------

ReadTxt  PROC      NEAR

         push      di
         mov       di,offset BuffText

ReadTxt1:call      UpCase
         mov       ds:[di],al
         inc       di
         cmp       di,offset BuffTxt0-1
         jae       ReadTxt4

ReadTxt2:call      ReadB
         jc        ReadTxt4
         cmp       al," "
         jbe       ReadTxt3
         cmp       al,ah
         jne       ReadTxt1                 ; nen¡ konec
         cmp       di,offset BuffText+2
         jne       ReadTx21
         cmp       word ptr ds:[BuffText],"]{"
         je        ReadTxt1
ReadTx21:call      UpCase
         mov       ds:[di],al
         inc       di
         jmp       short ReadTxt4

ReadTxt3:call      ReadRet
ReadTxt4:mov       byte ptr ds:[di],0       ; konec textu

         pop       di
         ret

ReadTxt  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ HEX k¢du do AX
; -----------------------------------------------------------------------------

ReadHex  PROC      NEAR

         push      bx
         xor       bx,bx                    ; st©ada‡
ReadHex1:call      ReadB
         jc        ReadHex8

         cmp       al,"0"
         jb        ReadHex7
         cmp       al,"9"
         jbe       ReadHex5

         cmp       al,"A"
         jb        ReadHex7
         cmp       al,"F"
         jbe       ReadHex4

         cmp       al,"a"
         jb        ReadHex7
         cmp       al,"f"
         ja        ReadHex7

         sub       al,32
ReadHex4:sub       al,7
ReadHex5:sub       al,"0"
         shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1
         or        bl,al
         jmp       short ReadHex1

ReadHex7:call      ReadRet
ReadHex8:xchg      ax,bx
         clc
         pop       bx
         ret

ReadHex  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ DEK k¢du do AX
; -----------------------------------------------------------------------------

ReadDek  PROC      NEAR

         push      bx
         push      dx

         xor       bx,bx
ReadDek1:call      ReadB
         jc        ReadDek9

         cmp       al,"0"
         jb        ReadDek8
         cmp       al,"9"
         ja        ReadDek8

         sub       al,"0"
         mov       ah,0
         xchg      ax,bx
         mov       dx,10
         mul       dx
         add       bx,ax
         jmp       short ReadDek1

ReadDek8:call      ReadRet
ReadDek9:xchg      ax,bx
         clc
         pop       dx
         pop       bx
         ret

ReadDek  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer ze souboru (CY=konec, AL=prvn¡ platn˜ znak)
; -----------------------------------------------------------------------------

ReadBSpc PROC      NEAR

         call      ReadB
         jc        ReadBSp2
         cmp       al," "
         jbe       ReadBSpc
         cmp       al,","
         je        ReadBSpc

         cmp       al,";"
         clc
         jne       ReadBSp2

ReadBSp1:call      ReadB
         jc        ReadBSp2
         cmp       al,13
         jne       ReadBSp1
         jmp       short ReadBSpc

ReadBSp2:ret

ReadBSpc ENDP

; -----------------------------------------------------------------------------
;        konverze znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ znaku AL
; -----------------------------------------------------------------------------

ReadRet  PROC      NEAR

         push      ax

         xchg      al,ds:[BuffChr]
         mov       ds:[BuffChr2],al

         pop       ax
         ret

ReadRet  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu ze souboru (CY=konec)
; -----------------------------------------------------------------------------

ReadB    PROC      NEAR

         mov       al,0
         xchg      al,ds:[BuffChr2]
         xchg      al,ds:[BuffChr]
         or        al,al
         jnz       ReadB4                   ; je platn˜ znak

         push      si
         mov       si,ds:[BuffRead]
         cmp       si,ds:[BuffNum]
         jae       ReadB3                   ; nejsou dal¨¡ data

ReadB2:  mov       al,ds:[si+Buff]
         cmp       al,13
         jne       ReadB23
         inc       word ptr ds:[CitRad]     ; ‡¡ta‡ © dk–
ReadB23: inc       si
         mov       ds:[BuffRead],si         ; nov˜ ‡tec¡ offset
         clc
         pop       si
         ret

ReadB3:  xor       si,si
         call      ReadBf                   ; nov‚ na‡ten¡ bufferu
         jnc       ReadB2
         pop       si
ReadB4:  ret                                ; n vrat s chybou

ReadB    ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bufferu souboru (CY=konec)
; -----------------------------------------------------------------------------

ReadBf   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,offset Buff           ; buffer
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       ah,3fh
         mov       cx,BUFFSIZE
         or        bx,bx
         jz        ReadBf4
         int       21h

         jnc       ReadBf2
         xor       ax,ax
ReadBf2: mov       ds:[BuffNum],ax          ; na‡ten˜ po‡et bajt–
         mov       word ptr ds:[BuffRead],0 ; ‡tec¡ offset z bufferu
         or        ax,ax
         jnz       ReadBf3
ReadBf4: stc                                ; p©¡znak konce souboru

ReadBf3: pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBf   ENDP

; -----------------------------------------------------------------------------
;        z pis souboru maker
; -----------------------------------------------------------------------------
;þ
WritMac  PROC      NEAR

; ------ rozbor jm‚na souboru

         mov       di,offset SoubBuff       ; buffer jm‚na souboru
         call      RozbFile                 ; rozbor jm‚na souboru
         mov       dx,offset HelpTxt
         jc        WritMac9                 ; chyba zad n¡

; ------ vytvo©en¡ souboru

         mov       dx,offset SoubBuff       ; buffer jm‚na souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h
         mov       dx,offset OpenTxt
         jc        WritMac9                 ; soubor nelze vytvo©it
         mov       ds:[SoubIdnt],ax         ; identifik tor souboru
         mov       word ptr ds:[BuffNum],0  ; nulov n¡ bufferu
         mov       byte ptr ds:[Pozice],0   ; nulov n¡ ukazatele pozice
         and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ m¢du ASCII textu

; ------ z pis obsahu bufferu

         call      WritBuff                 ; z pis obsahu bufferu
         jc        WritMac8

; ------ uzav©en¡ souboru

         call      WritAsc                  ; uzav©en¡ m¢du ASCII textu
         jc        WritMac8
         call      WritCR
         jc        WritMac8
         call      WritBf                   ; vypr zdnˆn¡ bufferu

WritMac8:mov       dx,offset WritTxt        ; text - chyba z pisu
         pushf
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
WritMac9:ret

WritMac  ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu bufferu (ES=segment bufferu, CY=chyba z pisu)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      si

         mov       si,es:[BuffBeg+KORIG]    ; za‡ tek bufferu

; ------ test, zda je ji‘ konec dat v bufferu

WritBuf2:cmp       si,es:[BuffEnd+KORIG]    ; je ji‘ konec bufferu ?
         jae       WritBuf9                 ; je ji‘ konec bufferu

; ------ z pis ozna‡en¡ hork‚ kl vesy

         mov       dl,es:[si+2]             ; p©esmyka‡e
         mov       ax,es:[si+3]             ; k¢d hork‚ kl vesy
         call      WritKey                  ; z pis ozna‡en¡ kl vesy
         jc        WritBuf9
         call      WritAsc                  ; uzav©en¡ m¢du ASCII
         jc        WritBuf9
         mov       al,"="
         call      WritB                    ; oddˆlova‡ hork‚ kl vesy
         jc        WritBuf9
         call      WritSpc
         jc        WritBuf9

; ------ z pis kl ves makra

         mov       cx,es:[si]               ; po‡et kl ves k z pisu
         add       si,5                     ; prvn¡ kl vesa
         sub       cx,5
         shr       cx,1
         jcxz      WritBuf5

WritBuf3:mov       ax,es:[si]
         mov       dl,0
         call      WritKey                  ; z pis k¢du kl vesy
         jc        WritBuf9
         add       si,2
         jc        WritBuf5
         loop      WritBuf3

; ------ ozna‡en¡ konce jednoho makra

WritBuf5:call      WritAsc                  ; uzav©en¡ m¢du ASCII textu
         jc        WritBuf9
         call      WritCR
         jc        WritBuf9
         jmp       short WritBuf2           ; z pis dal¨¡ho makra

WritBuf9:pop       si
         ret

WritBuff ENDP

; -----------------------------------------------------------------------------
;        z pis ozna‡en¡ kl vesy AX, p©esmyka‡e DL
; -----------------------------------------------------------------------------

WritKey  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         push      ds
         pop       es                       ; ES <- DS

; ------ test, zda bude z pis v ASCII m¢du

         or        ax,ax
         jz        WritKey4                 ; Ctrl-BREAK
         cmp       ah,0
         jne       WritKey2                 ; nen¡ kl vesa s ALT
         cmp       al,127
         jbe       WritKey4
         jmp       short WritKey3           ; z pis znaku s ALT-‡¡slo

WritKey2:cmp       al,127
         jae       WritKey4
         cmp       al," "
         jb        WritKey4
         mov       bl,al
         mov       bh,0
         cmp       ah,ds:[bx+AsciScan-32]
         jne       WritKey4

; ------ omezen¡ d‚lky © dku p©i zobrazen¡ ASCII

WritKey3:cmp       byte ptr ds:[Pozice],80-3
         jb        WrtKey31
         call      WritAsc
         jc        WrtKey98
         call      WritCR
         jc        WrtKey98

; ------ zobrazen¡ p©esmyka‡–

WrtKey31:or        dl,dl                    ; jsou p©esmyka‡e ?
         jz        WrtKey32                 ; nejsou p©esmyka‡e
         call      WritAsc
         jc        WrtKey98
         call      WritSwc                  ; zobrazen¡ p©esmyka‡–
         jc        WrtKey98

; ------ otev©en¡ ASCII m¢du

WrtKey32:test      byte ptr ds:[Param+KORIG],bit5 ; je ASCII m¢d ?
         jnz       WrtKey34                 ; je ji‘ ASCII m¢d
         or        byte ptr ds:[Param+KORIG],bit5 ; otev©en¡ ASCII m¢du
         push      ax
         mov       al,'"'
         call      WritB
         pop       ax
         jc        WrtKey98

; ------ zobrazen¡ ASCII znaku

WrtKey34:cmp       al,'"'
         jne       WrtKey36
         call      WritB
         jc        WrtKey99
WrtKey36:call      WritB
WrtKey98:jmp       short WrtKey99

; ------ p©¡prava pro zobrazen¡ kl vesy v NE-ASCII m¢du

WritKey4:call      WritAsc                  ; uzav©en¡ m¢du ASCII
         jc        WrtKey99
         cmp       byte ptr ds:[Pozice],80-8
         jb        WrtKey42
         call      WritCR
         jc        WrtKey99

; ------ zobrazen¡ ©¡dic¡ho slova

WrtKey42:push      ax
         and       al,not 0fh
         cmp       ax,KODFLAG
         pop       ax
         jne       WritKey5                 ; nen¡ ©¡dic¡ slovo

         call      WritSwc                  ; zobrazen¡ p©esmyka‡– DL
         jc        WrtKey99

         mov       si,offset TextAll
         cmp       al,KODALL AND 0ffh
         je        WrtKey46
         mov       si,offset TextOld
         cmp       al,KODOLD AND 0ffh
         je        WrtKey46

         mov       cl,al
         and       cl,7
         cmp       cl,4
         ja        WrtKey51
         add       cl,"1"
         mov       si,offset TextSet
         test      al,bit3
         jnz       WrtKey44
         mov       si,offset TextRes
WrtKey44:mov       ds:[si+5],cl
WrtKey46:jmp       short WritKey8

; ------ nalezen¡ k¢du kl vesy v tabulce k¢d–

WritKey5:mov       di,offset KodKey         ; tabulka k¢d– kl ves
         mov       cx,offset(KodKey0-KodKey)/2 ; d‚lka tabulky k¢d– kl ves
         cld
         repne     scasw                    ; nalezen¡ k¢du kl vesy
         je        WritKey6                 ; k¢d kl vesy nalezen OK

; ------ zobrazen¡ kl vesy v HEX k¢du

         call      WritSwc                  ; zobrazen¡ p©esmyka‡– DL
         jc        WritKey9

WrtKey51:push      ax
         mov       al,"$"
         call      WritB                    ; zobrazen¡ ozna‡en¡ "$"
         pop       ax
         jc        WritKey9

         cmp       ah,0
         je        WrtKey52                 ; je 1 bajt ?
         xchg      ah,al
         call      WritBH                   ; zobrazen¡ bajtu HIGH
         xchg      ah,al
         jc        WritKey9

WrtKey52:call      WritBH                   ; zobrazen¡ bajtu HEX v AL
         jnc       WritKy82
WrtKey99:jmp       short WritKey9

; ------ ‡¡slo kl vesy

WritKey6:sub       cx,offset(KodKey0-KodKey)/2-1 ; - ‡¡slo kl vesy
         neg       cx                       ; relativn¡ ‡¡slo kl vesy
         mov       ax,cx                    ; £schova ‡¡sla kl vesy

; ------ korekce p©esmyka‡– kl vesy

         and       ax,3
         dec       ax
         jnz       WrtKey62
         or        dl,SHIFT
WrtKey62:dec       ax
         jnz       WrtKey64
         or        dl,CTRL
WrtKey64:dec       ax
         jnz       WrtKey66
         or        dl,ALT

; ------ zobrazen¡ p©esmyka‡– kl vesy

WrtKey66:call      WritSwc                  ; zobrazen¡ p©esmyka‡– v DL
         jc        WritKey9

; ------ nalezen¡ textu kl vesy

WritKey7:shr       cx,1
         shr       cx,1                     ; relativn¡ ‡¡slo textu kl vesy
         mov       si,offset TextKey
         jcxz      WritKey8
WrtKey72:mov       al,ds:[si]
         mov       ah,0
         add       si,ax
         loop      WrtKey72

; ------ zobrazen¡ textu DS:SI

WritKey8:call      WritText
         jc        WritKey9
WritKy82:call      WritSpc                  ; oddˆlovac¡ mezera

; ------ n vrat registr–

WritKey9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritKey  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ p©esmyka‡– DL
; -----------------------------------------------------------------------------

WritSwc  PROC      NEAR

         push      ax
         push      si
         push      dx

         mov       si,offset TextSwc
WritSwc1:shr       dl,1
         jnc       WritSwc2
         push      si
         call      WritText
         pop       si
         jc        WritSwc9
WritSwc2:mov       al,ds:[si]
         mov       ah,0
         add       si,ax
         or        dl,dl
         jnz       WritSwc1

WritSwc9:pop       dx
         pop       si
         pop       ax
         ret

WritSwc  ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ m¢du ASCII textu
; -----------------------------------------------------------------------------

WritAsc  PROC      NEAR

         push      ax
         test      byte ptr ds:[Param+KORIG],bit5 ; je m¢d ASCII textu ?
         jz        WritAsc2                 ; nen¡ m¢d ASCII textu
         and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ m¢du ASCII

         mov       al,'"'
         call      WritB
         jc        WritAsc2

         call      WritSpc

WritAsc2:pop       ax
         ret

WritAsc  ENDP

; -----------------------------------------------------------------------------
;        z pis textu do souboru DS:SI (1. bajt = d‚lka + 1)
; -----------------------------------------------------------------------------

WritText PROC      NEAR

         push      ax
         push      cx

         cld
         lodsb
         mov       ah,0
         dec       ax
         xchg      ax,cx
WritTxt1:cld
         lodsb
         call      WritB
         jc        WritTxt3
         loop      WritTxt1

WritTxt3:pop       cx
         pop       ax
         ret

WritText ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu HEX AL
; -----------------------------------------------------------------------------

WritBH   PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      WritHH                   ; z pis vy¨¨¡ tetr dy
         pop       ax
         jc        WritHH3                  ; chyba
                                            ; pokra‡uje z pis ni‘¨¡ tetr dy
WritBH   ENDP

; -----------------------------------------------------------------------------
;        z pis znaku HEX
; -----------------------------------------------------------------------------

WritHH   PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,10
         jb        WritHH2
         add       al,7
WritHH2: add       al,"0"
         call      WritB
         pop       ax
WritHH3: ret

WritHH   ENDP

; -----------------------------------------------------------------------------
;        z pis mezery do souboru
; -----------------------------------------------------------------------------

WritSPC  PROC      NEAR

         push      ax
         mov       al," "
         call      WritB
         pop       ax
         ret

WritSPC  ENDP

; -----------------------------------------------------------------------------
;        z pis konce © dku CR do souboru
; -----------------------------------------------------------------------------

WritCR   PROC      NEAR

         push      ax
         mov       al,13
         call      WritB
         jc        WritCR2
         mov       al,10
         call      WritB
WritCR2: pop       ax
         ret

WritCR   ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL do souboru
; -----------------------------------------------------------------------------

WritB    PROC      NEAR

         push      si
         mov       si,ds:[BuffNum]          ; po‡et bajt– v bufferu
         cmp       si,BUFFSIZE              ; je buffer pln˜ ?
         jae       WritB5                   ; je ji‘ pln˜
WritB2:  mov       ds:[si+Buff],al          ; ulo‘en¡ znaku do bufferu
         inc       si
         mov       ds:[BuffNum],si          ; nov˜ po‡et bajt– v bufferu

         cmp       al,13
         jne       WritB3
         mov       byte ptr ds:[Pozice],0   ; nulov n¡ pozice
         jmp       short WritB4
WritB3:  cmp       al,10
         je        WritB4
         inc       byte ptr ds:[Pozice]     ; zv˜¨en¡ ukazatele pozice na © dku

WritB4:  clc
         pop       si
         ret

WritB5:  xor       si,si
         call      WritBf                   ; z pis obsahu bufferu
         jnc       WritB2
         pop       si
         ret

WritB    ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu bufferu souboru
; -----------------------------------------------------------------------------

WritBf   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,40h
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       cx,ds:[BuffNum]          ; po‡et bajt– v bufferu
         mov       dx,offset Buff           ; datov˜ buffer souboru
         int       21h
         mov       word ptr ds:[BuffNum],0  ; zru¨en¡ dat v bufferu

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBf   ENDP

; *****************************************************************************
;
;                         Rozbor p©¡kazov‚ho © dku
;
; *****************************************************************************
;þ

; -----------------------------------------------------------------------------
;        rozbor zad n¡ hork‚ kl vesy (-> AX, p©esmyka‡e DL)
; -----------------------------------------------------------------------------

RozbKey  PROC      NEAR

         push      es
         push      si


         push      ds
         pop       es
         mov       di,offset Buff
         mov       word ptr ds:[BuffRead],0
         mov       word ptr ds:[BuffNum],0
         mov       byte ptr ds:[BuffChr],0
         mov       byte ptr ds:[BuffChr2],0
         and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ m¢du ASCII textu
         mov       word ptr ds:[SoubIdnt],0

RozbKey1:call      RozbChr
         jc        RozbKey2
         cld
         stosb
         inc       word ptr ds:[BuffNum]
         jmp       short RozbKey1

RozbKey2:call      ReadKey                  ; na‡ten¡ kl vesy

         pop       si
         pop       es

         push      ax
         pushf
         mov       cx,ds:[BuffRead]
         jcxz      RozbKey8
         cmp       byte ptr ds:[BuffChr],0
         je        RozbKey7
         dec       cx
         jcxz      RozbKey8
         cmp       byte ptr ds:[BuffChr2],0
         je        RozbKey7
         dec       cx
         jcxz      RozbKey8
RozbKey7:call      RozbChr
         loop      RozbKey7
RozbKey8:test      byte ptr ds:[Param+KORIG],bit5
         jz        RozbKey9
         call      RozbChr
         cmp       al,'"'
         je        RozbKey9
         dec       si
RozbKey9:popf
         pop       ax

         ret

RozbKey  ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ ‡¡sla -> AX
; -----------------------------------------------------------------------------

RozbNum  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      dx
         xor       cx,cx                    ; st©ada‡ ‡¡sla

; ------ na‡ten¡ prvn¡ ‡¡slice

         call      RozbSpc
         call      RozbNm
         jc        RozbNum6                 ; nen¡ zad no ‘ dn‚ ‡¡slo

; ------ p©id n¡ ‡¡sla ke st©ada‡i

RozbNum2:push      ax
         mov       ax,10
         mul       cx
         or        dx,dx
         jz        RozbNum3
         mov       ax,-1
RozbNum3:pop       cx
         mov       ch,0
         add       cx,ax
         jnc       RozbNum4
         mov       cx,-1

; ------ dal¨¡ ‡¡slice

RozbNum4:call      RozbNm
         jnc       RozbNum2
         clc

; ------ n vrat registr–

RozbNum6:xchg      ax,cx                    ; AX <- ‡¡slo
         pop       dx
         pop       cx
         ret

RozbNum  ENDP

; -----------------------------------------------------------------------------
;        ‡¡slice
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         call      RozbChr
         jc        RozbNm4
         cmp       al,"0"
         jb        RozbNm3
         cmp       al,"9"
         ja        RozbNm3
         sub       al,"0"
         ret

RozbNm3: dec       si
RozbNm4: stc
         ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ jm‚na souboru do bufferu DI (-> CX=d‚lka)
; -----------------------------------------------------------------------------

RozbFile PROC      NEAR

         xor       cx,cx

         call      RozbSpc
         jc        RozbFil9
         cmp       al,"/"
         stc
         je        RozbFil9

RozbFil1:call      RozbChr
         jc        RozbFil8
         je        RozbFil7
         cmp       al,"/"
         je        RozbFil7

         cmp       cl,MaxFile-1
         jae       RozbFil1

         mov       byte ptr ds:[di],al
         inc       di
         inc       cx
         jmp       short RozbFil1

RozbFil7:dec       si
RozbFil8:mov       byte ptr ds:[di],0
         clc
RozbFil9:ret

RozbFile ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr
         jc        RozbSpc2
         je        RozbSpc
         dec       si
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku
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
;        zobrazen¡ stavu (segment ES)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

         push      ax
         push      dx
         push      si
         push      es

         mov       es,ds:[RezSegm]

         mov       dx,offset StavTxt1
         call      DispTxt

         xor       ax,ax
         mov       si,es:[BuffBeg+KORIG]
DispSta1:cmp       si,es:[BuffEnd+KORIG]
         jae       DispSta2
         inc       ax
         add       si,es:[si]
         jnc       DispSta1
DispSta2:call      DispNum

         mov       dx,offset StavTxt2
         call      DispTxt

         mov       ax,es:[BuffMax+KORIG]
         sub       ax,es:[BuffEnd+KORIG]
         jnc       DispSta3
         xor       ax,ax
DispSta3:call      DispNum

         mov       dx,offset StavTxt3
         call      DispTxt

         mov       ax,es:[BuffMax+KORIG]
         sub       ax,es:[BuffBeg+KORIG]
         call      DispNum

         mov       dx,offset StavTxt4
         call      DispTxt

         mov       word ptr ds:[SoubIdnt],1
         mov       word ptr ds:[BuffNum],0
         mov       byte ptr ds:[Pozice],0
         and       byte ptr ds:[Param+KORIG],not bit5 ; zru¨en¡ m¢du ASCII textu

         mov       ax,es:[HotKey+KORIG]
         mov       dl,es:[HotSwc+KORIG]
         call      WritKey
         call      WritAsc                  ; uzav©en¡ m¢du ASCII textu
         call      WritBf                   ; vypr zdnˆn¡ bufferu

         mov       dx,offset StavTxt5
         call      DispTxt

         pop       es
         pop       si
         pop       dx
         pop       ax
         ret

DispStav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         xor       cx,cx
         mov       bx,10

DispNum1:xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       dx
         add       dl,"0"
         mov       ah,2
         int       21h
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; *****************************************************************************
;
;                            data pro instalaci
;
; *****************************************************************************
;þ
RezSegm  dw        0                        ; rezidentn¡ segment

AsciScan label     byte                     ; tabulka SCAN k¢d– ASCII znak–
         db        39h,2,28h,4,5,6,8,28h,0ah,0bh,9,0dh,33h,0ch,34h,35h            ; 20h-2fh
         db        0bh,2,3,4,5,6,7,8,9,0ah,27h,27h,33h,0dh,34h,35h                ; 30h-3fh
         db        3,1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h,18h  ; 40h-4fh
         db        19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch,1ah,2bh,1bh,7,0ch  ; 50h-5fh
         db        29h,1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h,18h; 60h-6fh
         db        19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch,1ah,2bh,1bh,29h,0eh; 70h-7fh

KodKey   label     word                     ; tabulka k¢d– kl ves
;                     -  ,Shift , Ctrl , Alt
         dw        0011Bh,0011Bh,0011Bh,00100h ; 01h:     Esc
         dw        00231h,00221h,0FFFFh,07800h ; 02h:     1 !
         dw        00332h,00340h,00300h,07900h ; 03h:     2 @
         dw        00433h,00423h,0FFFFh,07A00h ; 04h:     3 #
         dw        00534h,00524h,0FFFFh,07B00h ; 05h:     4 $
         dw        00635h,00625h,0FFFFh,07C00h ; 06h:     5 %
         dw        00736h,0075Eh,0071Eh,07D00h ; 07h:     6 ^
         dw        00837h,00826h,0FFFFh,07E00h ; 08h:     7 &
         dw        00938h,0092Ah,0FFFFh,07F00h ; 09h:     8 *
         dw        00A39h,00A28h,0FFFFh,08000h ; 0Ah:     9 (
         dw        00B30h,00B29h,0FFFFh,08100h ; 0Bh:     0 )
         dw        00C2Dh,00C5Fh,00C1Fh,08200h ; 0Ch:     - _
         dw        00D3Dh,00D2Bh,0FFFFh,08300h ; 0Dh:     = +
         dw        00E08h,00E08h,00E7Fh,00E00h ; 0Eh:  Back Space
         dw        00F09h,00F00h,09400h,0A500h ; 0Fh:     Tab
         dw        01071h,01051h,01011h,01000h ; 10h:      Q
         dw        01177h,01157h,01117h,01100h ; 11h:      W
         dw        01265h,01245h,01205h,01200h ; 12h:      E
         dw        01372h,01352h,01312h,01300h ; 13h:      R
         dw        01474h,01454h,01414h,01400h ; 14h:      T
         dw        01579h,01559h,01519h,01500h ; 15h:      Y
         dw        01675h,01655h,01615h,01600h ; 16h:      U
         dw        01769h,01749h,01709h,01700h ; 17h:      I
         dw        0186Fh,0184Fh,0180Fh,01800h ; 18h:      O
         dw        01970h,01950h,01910h,01900h ; 19h:      P
         dw        01A5Bh,01A7Bh,01A1Bh,01A00h ; 1Ah:     [ {
         dw        01B5Dh,01B7Dh,01B1Dh,01B00h ; 1Bh:     ] }
         dw        01C0Dh,01C0Dh,01C0Ah,01C00h ; 1Ch:    Enter
         dw        0E00Dh,0E00Dh,0E00Ah,0A600h ; 1Dh:   [Enter]
         dw        01E61h,01E41h,01E01h,01E00h ; 1Eh:      A
         dw        01F73h,01F53h,01F13h,01F00h ; 1Fh:      S
         dw        02064h,02044h,02004h,02000h ; 20h:      D
         dw        02166h,02146h,02106h,02100h ; 21h:      F
         dw        02267h,02247h,02207h,02200h ; 22h:      G
         dw        02368h,02348h,02308h,02300h ; 23h:      H
         dw        0246Ah,0244Ah,0240Ah,02400h ; 24h:      J
         dw        0256Bh,0254Bh,0250Bh,02500h ; 25h:      K
         dw        0266Ch,0264Ch,0260Ch,02600h ; 26h:      L
         dw        0273Bh,0273Ah,0FFFFh,02700h ; 27h:     ; :
         dw        02827h,02822h,0FFFFh,02800h ; 28h:     ' "
         dw        02960h,0297Eh,0FFFFh,02900h ; 29h:     ` ~
         dw        02B5Ch,02B7Ch,02B1Ch,02B00h ; 2Bh:     \ |
         dw        02C7Ah,02C5Ah,02C1Ah,02C00h ; 2Ch:      Z
         dw        02D78h,02D58h,02D18h,02D00h ; 2Dh:      X
         dw        02E63h,02E43h,02E03h,02E00h ; 2Eh:      C
         dw        02F76h,02F56h,02F16h,02F00h ; 2Fh:      V
         dw        03062h,03042h,03002h,03000h ; 30h:      B
         dw        0316Eh,0314Eh,0310Eh,03100h ; 31h:      N
         dw        0326Dh,0324Dh,0320Dh,03200h ; 32h:      M
         dw        0332Ch,0333Ch,0FFFFh,03300h ; 33h:     , <
         dw        0342Eh,0343Eh,0FFFFh,03400h ; 34h:     . >
         dw        0352Fh,0353Fh,0FFFFh,03500h ; 35h:     / ?
         dw        0E02Fh,0E02Fh,09500h,0A400h ; 35h:     [/]
         dw        0FFFFh,0FFFFh,07200h,0FFFFh ; 37h: Print Screen
         dw        0372Ah,0372Ah,09600h,03700h ; 37h:     [*]
         dw        03920h,03920h,03920h,03920h ; 39h:Space(mezera)
         dw        03B00h,05400h,05E00h,06800h ; 3Bh:     F1
         dw        03C00h,05500h,05F00h,06900h ; 3Ch:     F2
         dw        03D00h,05600h,06000h,06A00h ; 3Dh:     F3
         dw        03E00h,05700h,06100h,06B00h ; 3Eh:     F4
         dw        03F00h,05800h,06200h,06C00h ; 3Fh:     F5
         dw        04000h,05900h,06300h,06D00h ; 40h:     F6
         dw        04100h,05A00h,06400h,06E00h ; 41h:     F7
         dw        04200h,05B00h,06500h,06F00h ; 42h:     F8
         dw        04300h,05C00h,06600h,07000h ; 43h:     F9
         dw        04400h,05D00h,06700h,07100h ; 44h:     F10
         dw        0FFFFh,0FFFFh,00000h,0FFFFh ; 46h:    Break
         dw        04737h,04700h,07700h,0FFFFh ; 47h:     [7]
         dw        047E0h,047E0h,077E0h,09700h ; 47h:    Home
         dw        04838h,04800h,08D00h,0FFFFh ; 48h:     [8]
         dw        048E0h,048E0h,08DE0h,09800h ; 48h: Up (nahoru)
         dw        04939h,04900h,08400h,0FFFFh ; 49h:     [9]
         dw        049E0h,049E0h,084E0h,09900h ; 49h:   Page Up
         dw        04A2Dh,04A2Dh,08E00h,04A00h ; 4Ah:     [-]
         dw        04B34h,04B00h,07300h,0FFFFh ; 4Bh:     [4]
         dw        04BE0h,04BE0h,073E0h,09B00h ; 4Bh: Left (vlevo)
         dw        04C35h,04C00h,08F00h,0FFFFh ; 4Ch:     [5]
         dw        04D36h,04D00h,07400h,0FFFFh ; 4Dh:     [6]
         dw        04DE0h,04DE0h,074E0h,09D00h ; 4Dh:Right(vpravo)
         dw        04E2Bh,04E2Bh,09000h,04E00h ; 4Eh:     [+]
         dw        04F31h,04F00h,07500h,0FFFFh ; 4Fh:     [1]
         dw        04FE0h,04FE0h,075E0h,09F00h ; 4Fh:     End
         dw        05032h,05000h,09100h,0FFFFh ; 50h:     [2]
         dw        050E0h,050E0h,091E0h,0A000h ; 50h: Down (dol–)
         dw        05133h,05100h,07600h,0FFFFh ; 51h:     [3]
         dw        051E0h,051E0h,076E0h,0A100h ; 51h:  Page Down
         dw        05230h,05200h,09200h,0FFFFh ; 52h:     [0]
         dw        052E0h,052E0h,092E0h,0A200h ; 52h:   Insert
         dw        0532Eh,05300h,09300h,0FFFFh ; 53h:     [.]
         dw        053E0h,053E0h,093E0h,0A300h ; 53h:   Delete
         dw        0565Ch,0567Ch,0561Ch,0FFFFh ; 56h: \ | zdvojen 
         dw        08500h,08700h,08900h,08B00h ; 57h:     F11
         dw        08600h,08800h,08A00h,08C00h ; 58h:     F12
KodKey0  label     word


TextKey  label     byte                     ; texty n zv– kl ves
         db        6,'{ESC}'                ; 01h:     Esc
         db        5,'{1!}'                 ; 02h:     1 !
         db        5,'{2@}'                 ; 03h:     2 @
         db        5,'{3#}'                 ; 04h:     3 #
         db        5,'{4$}'                 ; 05h:     4 $
         db        5,'{5%}'                 ; 06h:     5 %
         db        5,'{6^}'                 ; 07h:     6 ^
         db        5,'{7&}'                 ; 08h:     7 &
         db        5,'{8*}'                 ; 09h:     8 *
         db        5,'{9(}'                 ; 0Ah:     9 (
         db        5,'{0)}'                 ; 0Bh:     0 )
         db        5,'{-_}'                 ; 0Ch:     - _
         db        5,'{=+}'                 ; 0Dh:     = +
         db        5,'{BS}'                 ; 0Eh:  Back Space
         db        6,'{TAB}'                ; 0Fh:     Tab
         db        4,'{Q}'                  ; 10h:      Q
         db        4,'{W}'                  ; 11h:      W
         db        4,'{E}'                  ; 12h:      E
         db        4,'{R}'                  ; 13h:      R
         db        4,'{T}'                  ; 14h:      T
         db        4,'{Y}'                  ; 15h:      Y
         db        4,'{U}'                  ; 16h:      U
         db        4,'{I}'                  ; 17h:      I
         db        4,'{O}'                  ; 18h:      O
         db        4,'{P}'                  ; 19h:      P
         db        5,'{[{}'                 ; 1Ah:     [ {
         db        5,'{]}}'                 ; 1Bh:     ] }
         db        8,'{ENTER}'              ; 1Ch:    Enter
         db        8,'[ENTER]'              ; 1Dh:   [Enter]
         db        4,'{A}'                  ; 1Eh:      A
         db        4,'{S}'                  ; 1Fh:      S
         db        4,'{D}'                  ; 20h:      D
         db        4,'{F}'                  ; 21h:      F
         db        4,'{G}'                  ; 22h:      G
         db        4,'{H}'                  ; 23h:      H
         db        4,'{J}'                  ; 24h:      J
         db        4,'{K}'                  ; 25h:      K
         db        4,'{L}'                  ; 26h:      L
         db        5,'{;:}'                 ; 27h:     ; :
         db        5,'{',39,'"}'            ; 28h:     ' "
         db        5,'{`~}'                 ; 29h:     ` ~
         db        5,'{\|}'                 ; 2Bh:     \ |
         db        4,'{Z}'                  ; 2Ch:      Z
         db        4,'{X}'                  ; 2Dh:      X
         db        4,'{C}'                  ; 2Eh:      C
         db        4,'{V}'                  ; 2Fh:      V
         db        4,'{B}'                  ; 30h:      B
         db        4,'{N}'                  ; 31h:      N
         db        4,'{M}'                  ; 32h:      M
         db        5,'{,<}'                 ; 33h:     , <
         db        5,'{.>}'                 ; 34h:     . >
         db        5,'{/?}'                 ; 35h:     / ?
         db        4,'[/]'                  ; 35h:     [/]
         db        14,'{PRINTSCREEN}'       ; 37h: Print Screen
         db        4,'[*]'                  ; 37h:     [*]
         db        8,'{SPACE}'              ; 39h:Space(mezera)
         db        5,'{F1}'                 ; 3Bh:     F1
         db        5,'{F2}'                 ; 3Ch:     F2
         db        5,'{F3}'                 ; 3Dh:     F3
         db        5,'{F4}'                 ; 3Eh:     F4
         db        5,'{F5}'                 ; 3Fh:     F5
         db        5,'{F6}'                 ; 40h:     F6
         db        5,'{F7}'                 ; 41h:     F7
         db        5,'{F8}'                 ; 42h:     F8
         db        5,'{F9}'                 ; 43h:     F9
         db        6,'{F10}'                ; 44h:     F10
         db        8,'{BREAK}'              ; 46h:    Break
         db        4,'[7]'                  ; 47h:     [7]
         db        7,'{HOME}'               ; 47h:    Home
         db        4,'[8]'                  ; 48h:     [8]
         db        5,'{UP}'                 ; 48h: Up (nahoru)
         db        4,'[9]'                  ; 49h:     [9]
         db        9,'{PAGEUP}'             ; 49h:   Page Up
         db        4,'[-]'                  ; 4Ah:     [-]
         db        4,'[4]'                  ; 4Bh:     [4]
         db        7,'{LEFT}'               ; 4Bh: Left (vlevo)
         db        4,'[5]'                  ; 4Ch:     [5]
         db        4,'[6]'                  ; 4Dh:     [6]
         db        8,'{RIGHT}'              ; 4Dh:Right(vpravo)
         db        4,'[+]'                  ; 4Eh:     [+]
         db        4,'[1]'                  ; 4Fh:     [1]
         db        6,'{END}'                ; 4Fh:     End
         db        4,'[2]'                  ; 50h:     [2]
         db        7,'{DOWN}'               ; 50h: Down (dol–)
         db        4,'[3]'                  ; 51h:     [3]
         db        11,'{PAGEDOWN}'          ; 51h:  Page Down
         db        4,'[0]'                  ; 52h:     [0]
         db        9,'{INSERT}'             ; 52h:   Insert
         db        4,'[.]'                  ; 53h:     [.]
         db        9,'{DELETE}'             ; 53h:   Delete
         db        4,'{\}'                  ; 56h: \ | zdvojen 
         db        6,'{F11}'                ; 57h:     F11
         db        6,'{F12}'                ; 58h:     F12
         db        0

TextSwc  label     byte                     ; texty p©esmyka‡–
         db        7,'SHIFT-'               ; 0:
         db        6,'CTRL-'                ; 1:
         db        5,'ALT-'                 ; 2:
         db        7,'FLAG1-'               ; 3:
         db        7,'FLAG2-'               ; 4:
         db        7,'FLAG3-'               ; 5:
         db        7,'FLAG4-'               ; 6:
         db        7,'FLAG5-'               ; 7:
         db        0

TextSet  db        7,'(SET1)'
TextRes  db        7,'(RES1)'

TextCtr  label     byte
         db        7,'(RES1)'               ; 0
         db        7,'(RES2)'               ; 1
         db        7,'(RES3)'               ; 2
         db        7,'(RES4)'               ; 3
         db        7,'(RES5)'               ; 4
         db        7,'(SET1)'               ; 5
         db        7,'(SET2)'               ; 6
         db        7,'(SET3)'               ; 7
         db        7,'(SET4)'               ; 8
         db        7,'(SET5)'               ; 9
TextOld  db        6,'(OLD)'                ; 10
TextAll  db        6,'(ALL)'                ; 11
         db        0

UvTxt    db        'MAKRO V1.03 - makroklavesy; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Instalace:B cislo ..... velikost bufferu v bajtech (napr.B1000)',13,10
         db        'Parametry:R soubor .... nacteni maker ze souboru do pameti',13,10
         db        '                        (pri vicenasobnem uvedeni parametru R',13,10
         db        '                        se buffer nuluje pouze pro prvni soubor)',13,10
         db        '          W soubor .... zapis maker z pameti do souboru',13,10
         db        '          H klavesa ... horka klavesa pro definovani maker',13,10
         db        '          M klavesa ... start makra pro zadanou klavesu',13,10
         db        '          T pocet ..... pocet ignorovanych testu znaku (impl. 10)',13,10
         db        '          ! ........... odinstalovani programu z pameti',13,10
         db        'Definice makra: horka klavesa, definovana makroklavesa, text makra,',13,10
         db        '                ukonceni definice makra opet horkou klavesou.',13,10
         db        '$'

FndTxt   db        'Zadany soubor nenalezen !',13,10,'$'
OpenTxt  db        'Chyba zadani souboru k zapisu maker !',13,10,'$'
NeniTxt  db        'Program nebyl dosud nainstalovan do pameti !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'

StavTxt1 db        ' Pocet maker $'
StavTxt2 db        ', volnych $'
StavTxt3 db        ' B, velikost bufferu $'
StavTxt4 db        ' B.',13,10,' Horka klavesa pro definici makra = $'
StavTxt5 db        '.',13,10,'$'

NutnoTxt db        'Program je nutno nejdrive nainstalovat do pameti s parametrem "B cislo",',13,10
         db        'kde cislo predstavuje velikost bufferu v bajtech (1 klavesa = 2 bajty) !',13,10,'$'
DeInsTxt db        'Program byl odinstalovan z pameti.',13,10,'$'

InstTxt  db        ' Program byl nainstalovan do pameti.',13,10,'$'
ReInsTxt db        'Ke zmene velikosti bufferu je nutno program nejdrive odinstalovat !',13,10,'$'
NelzeTxt db        'Program nelze odinstalovat - odinstalujte',13,10
         db        'nejdrive programy nainstalovane pozdeji !',13,10,'$'
NMacTxt  db        'Zadana makroklavesa nenalezena !',13,10,'$'

SyntTxt1 db        'Chyba syntaxe na radku $'
SyntTxt2 db        ' !',13,10,'$'

SoubBuff db        MaxFile dup(?)           ; buffer jm‚na souboru
SoubIdnt dw        0                        ; identifik tor souboru

CitRad   dw        1                        ; ‡¡ta‡ © dk– souboru
TopRad   dw        1                        ; © dek za‡ tku p©¡kazu

Pozice   db        0                        ; ukazatel pozice na © dku

BuffChr  db        0                        ; uschovan˜ navr cen˜ znak
BuffChr2 db        0                        ; uschovan˜ navr cen˜ znak 2

BuffRead dw        0                        ; ‡tec¡ offset z bufferu souboru
BuffNum  dw        0                        ; po‡et bajt– v datov‚m bufferu

BuffText db        16 dup(?)                ; buffer textu jm‚na kl vesy
BuffTxt0 label     byte

Buff     db        BUFFSIZE dup(?)          ; datov˜ buffer souboru

Command  db        128 dup(?)               ; buffer p©¡kazov‚ho © dku

Code     ENDS
         END       Start

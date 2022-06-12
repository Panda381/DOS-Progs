;------------------------------------------------------------------------------
;                           Zobrazen¡ BDT
;------------------------------------------------------------------------------
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:                                      ; hlavn¡ tˆlo programu

         call      Zobraz                   ; zobrazen¡ tabulky stavu BDT


         mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h

; -----------------------------------------------------------------------------
;                         Zobrazen¡ tabulky stavu BDT
; -----------------------------------------------------------------------------
public   Zobraz
Zobraz:                                   ;* zobrazen¡ tabulky BDT

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         call      InitVRAM                 ; inicializace parametr– videom¢du
         jc        Zobraz8                  ; nepovolen˜ videom¢d
                                          ;* £schova obsahu videopamˆti
         lds       si,cs:[AdrVRAM]          ; adresa videopamˆti
         push      cs
         pop       es                       ; ES <- CS
         mov       di,offset BuffVRAM       ; buffer pro £schovu videopamˆti
         call      PrenosVRAM               ; £schova obsahu videopamˆti
                                          ;* zobrazen¡ cel‚ tabulky BDT
         les       di,cs:[AdrVRAM]          ; adresa videopamˆti
         push      cs
         pop       ds                       ; DS <- CS
         call      ZobrTop                  ; zobrazen¡ horn¡ho © dku obrazovky
         call      ZobrEnd                  ; zobrazen¡ spodn¡ho © dku tabulky
Zobraz3:
         call      ZobrAll                  ; zobrazen¡ v¨ech BDT
                                          ;* ‡ek n¡ na stisk kl vesy
         mov       ah,1
         int       16h                      ; ‡ek n¡ na kl vesu
         jz        Zobraz3
                                          ;* n vrat obsahu videopamˆti
         mov       si,offset BuffVRAM       ; buffer pro £schovu videopamˆti
         call      PrenosVRAM               ; n vrat obsahu videopamˆti

Zobraz8: pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret
; -----------------------------------------------------------------------------
;                     Inicializace parametr– videom¢du
; -----------------------------------------------------------------------------
public   InitVRAM
InitVRAM:                                 ;* inicializace parametr– pro VRAM
                                            ; VSTUP: CY=nepovolen˜ videom¢d

         push      ax
         push      ds
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0 datov˜ segment BIOS
         mov       ax,ds:[44eh]             ; po‡ te‡n¡ adresa videopamˆti
         mov       word ptr cs:[AdrVRAM],ax ; offset adresy videopamˆti
         mov       word ptr cs:[AdrVRAM+2],0b800h ; segment videopamˆti pro CGA
         mov       word ptr cs:[Atrib1],300bh ; atributy pro barevnou kartu
         mov       byte ptr cs:[Atrib3],0eh ; atributy pro barevnou kartu
         mov       al,ds:[449h]             ; sou‡asn˜ videom¢d
         and       al,7fh                   ; zru¨en¡ bitu 7
         cmp       al,2                     ; je videom¢d 2 ?
         je        InitVRM2                 ; je videom¢d 2 - OK
         cmp       al,3                     ; je videom¢d 3 ?
         je        InitVRM2                 ; je videom¢d 3 - OK
         mov       word ptr cs:[AdrVRAM+2],0b000h ; segment videopamˆti pro MDA
         mov       word ptr cs:[Atrib1],7007h ; atributy pro barevnou kartu
         mov       byte ptr cs:[Atrib3],0fh ; atributy pro barevnou kartu
         cmp       al,7                     ; je videom¢d 7 ?
         je        InitVRM2                 ; je videom¢d 7 - OK
         stc                                ; p©¡znak - nepovolen˜ videom¢d
InitVRM2:pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                        P©enos obsahu videopamˆti
; -----------------------------------------------------------------------------
public   PrenosVRAM
PrenosVRAM:                               ;* p©enos VIDEORAM
                                            ; VSTUP: DS:SI=zdrojv  adresa
                                            ;        ES:DI=c¡lov  adresa

         push      ax
         push      cx
         push      si
         push      di
         xor       cx,cx
         mov       cl,cs:[PoslBDT]          ; ‡¡slo prvn¡ho BDT
         sub       cl,cs:[PrvniBDT]         ; po‡et BDT
         add       cx,8                     ; zaokrouhlen¡ na 8
         shr       cx,1
         shr       cx,1
         shr       cx,1                     ; po‡et © dk– s BDT
         mov       cs:[PocRadku],cl         ; po‡et © dk– s BDT
         add       cx,2                     ; p©i‡ten¡ horn¡ho a spodn¡ho okraje
         mov       al,80                    ; po‡et znak– na © dek
         mul       cl                       ; v˜po‡et celkov‚ho po‡tu znak–
         mov       cx,ax                    ; celkov˜ po‡et znak–
         mov       cs:[DelkVRAM],cx         ; £schova d‚lky videopamˆti
         rep       movsw                    ; p©enos videopamˆti
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                       P©enos textu do videopamˆti
; -----------------------------------------------------------------------------
public   PrenosText
PrenosText:                               ;* p©enos textu do videopamˆti
                                            ; VSTUP: ES:DI=adresa ve videopamˆti
                                            ;        DS:SI=adresa textu
                                            ;        AH=atribut barvy textu

PrenosT1:lodsb                              ; znak k zobrazen¡
         or        al,al                    ; je ji‘ konec textu ?
         jz        PrenosT2                 ; je konec textu
         stosw                              ; ulo‘en¡ do videopamˆti
         jmp       short PrenosT1           ; p©enos dal¨¡ho znaku
PrenosT2:ret
; -----------------------------------------------------------------------------
;                         Zobrazen¡ horn¡ho © dku
; -----------------------------------------------------------------------------
public   ZobrTop
ZobrTop:                                  ;* zobrazen¡ horn¡ho © dku
                                            ; VSTUP: ES:DI=adresa videopamˆti

         push      di
         mov       si,offset TopText        ; text horn¡ho © dku
         mov       ah,ds:[Atrib2]           ; atribut horn¡ho © dku
         call      PrenosText               ; zobrazen¡ horn¡ho © dku
         pop       di
         ret
; -----------------------------------------------------------------------------
;                        Zobrazen¡ spodn¡ho © dku
; -----------------------------------------------------------------------------
public   ZobrEnd
ZobrEnd:                                  ;* zobrazen¡ spodn¡ho © dku
                                            ; VSTUP: ES:DI=adresa videopamˆti

         push      di
         add       di,ds:[DelkVRAM]         ; adresa © dku konce
         add       di,ds:[DelkVRAM]         ; adresa © dku konce
         sub       di,80*2
         mov       si,offset EndText        ; text spodn¡ho © dku
         mov       ah,ds:[Atrib2]           ; atribut spodn¡ho © dku
         call      PrenosText               ; zobrazen¡ spodn¡ho © dku
         pop       di
         ret
; -----------------------------------------------------------------------------
;                         Zobrazen¡ v¨ech BDT
; -----------------------------------------------------------------------------
public   ZobrAll
ZobrAll:                                  ;* zobrazen¡ v¨ech BDT
                                            ; VSTUP: ES:DI=adresa videopamˆti
         push      di
         xor       bx,bx
         mov       bl,ds:[PrvniBDT]         ; ‡¡slo prvn¡ho BDT
         xor       cx,cx
         mov       cl,ds:[PocRadku]         ; po‡et © dk– k zobrazen¡
ZobrAll1:add       di,2*80                  ; adresa druh‚ho © dku
         call      ZobrLine                 ; zobrazen¡ jednoho © dku s BDT
         inc       bx                       ; zv˜¨en¡ ‡¡sla BDT
         loop      ZobrAll1                 ; dal¨¡ © dek s BDT
         pop       di
         ret
; -----------------------------------------------------------------------------
;                         Zobrazen¡ © dku s BDT
; -----------------------------------------------------------------------------
public   ZobrLine
ZobrLine:                                 ;* zobrazen¡ © dku BDT
                                            ; VSTUP: ES:DI=adresa ve videopam.
                                            ;        BX=‡¡slo BDT
         push      bx
         push      cx
         push      di
         mov       al," "
         mov       cx,8                     ; po‡et BDT na © dek
         mov       ah,ds:[Atrib2]           ; atribut barvy
         stosw
         stosw
         stosw
ZobrLin1:stosw
         call      ZobrBDT                  ; zobrazen¡ jednoho BDT
         add       bl,ds:[PocRadku]         ; zv˜¨en¡ ‡¡sla BDT
         mov       al," "
         loop      ZobrLin1                 ; zobrazen¡ dal¨¡ho BDT
         stosw
         mov       ah,ds:[Atrib2]           ; atribut barvy
         stosw
         stosw
         stosw
         stosw
         pop       di
         pop       cx
         pop       bx
         ret
; -----------------------------------------------------------------------------
;                         Zobrazen¡ jednoho BDT
; -----------------------------------------------------------------------------
public   ZobrBDT
ZobrBDT:                                  ;* zobrazen¡ jednoho BDT
                                            ; VSTUP: ES:DI=adresa ve videopam.
                                            ;        BX=‡¡slo BDT

         mov       ah,ds:[Atrib3]           ; atribut barvy
         cmp       bl,ds:[PoslBDT]          ; je p©ekro‡eno posledn¡ BDT ?
         jbe       ZobrBDT2                 ; nen¡ p©ekro‡eno posledn¡ BDT
         mov       al," "                   ; mazac¡ mezera
         push      cx
         mov       cx,8                     ; po‡et pozic
ZobrBDT1:stosw
         loop      ZobrBDT1
         pop       cx
         ret

ZobrBDT2:
         push      bx
         call      ZobrNum                  ; zobrazen¡ ‡¡sla BDT
         mov       al," "                   ; oddˆlovac¡ mezera
         stosw                              ; oddˆlovac¡ mezera

         mov       ah,ds:[Atrib1]           ; atribut barvy
         push      ds                       ; £schova DS
         lds       si,ds:[AdrBDT]           ; adresa tabulky BDT
         mov       bh,ds:[si+bx-64]         ; bajt BDT
         pop       ds                       ; n vrat DS
         mov       al,"G"                   ; znak atributu "G"
         call      ZobrAtr                  ; zobrazen¡ atributu "G"
         mov       al,"L"                   ; znak atributu "L"
         call      ZobrAtr                  ; zobrazen¡ atributu "L"
         mov       al,"A"                   ; znak atributu "A"
         call      ZobrAtr                  ; zobrazen¡ atributu "A"
         mov       al,"Z"                   ; znak atributu "Z"
         call      ZobrAtr                  ; zobrazen¡ atributu "Z"

         pop       bx
         ret

ZobrAtr:                                  ;* zobrazen¡ atributu BDT
                                            ; VSTUP: BH=bit 0 - test. atribut
                                            ;        AL=zobrazovan˜ atribut

         test      bh,8                     ; je atribut nastaven ?
         jnz       ZobrAtr2                 ; atribut je nastaven
         mov       al,"."                   ; n hradn¡ znak te‡ky
ZobrAtr2:stosw                              ; zobrazen¡ znaku atributu
         shl       bh,1                     ; rotace dal¨¡ho atributu
         ret
; -----------------------------------------------------------------------------
;                         Zobrazen¡ ‡¡sla
; -----------------------------------------------------------------------------
public   ZobrNum
ZobrNum:                                  ;* zobrazen¡ ‡¡sla 3 znaky (->vpravo)
                                            ; VSTUP: ES:DI=adresa ve videopam.
                                            ;        BL=‡¡slo k zobrazen¡
                                            ;        AH=atribut barvy

         push      bx
         mov       al," "                   ; p©ednastaven¡ mezery
         mov       bh,100
         call      Zobrnum5                 ; zobrazen¡ stovek
         mov       bh,10
         call      Zobrnum5                 ; zobrazen¡ des¡tek
         mov       bh,1
         call      Zobrnum5                 ; zobrazen¡ jednotek
         pop       bx
         ret

ZobrNum5:                                 ;* zobrazen¡ jedn‚ ‡¡slice
         cmp       bl,bh                    ; je vˆt¨¡ ne‘ dˆlitel ?
         jb        ZobrNum7                 ; nen¡ vˆt¨¡ ne‘ dˆlitel
         mov       al,"0"-1                 ; p©ednastaven¡ ‡¡slice 0
Zobrnum6:inc       al                       ; zv˜¨en¡ ‡¡slice
         sub       bl,bh                    ; ode‡ten¡ dˆlitele
         jnc       Zobrnum6                 ; nen¡ je¨tˆ p©ete‡en¡
         add       bl,bh                    ; n vrat zbytku po dˆlen¡
ZobrNum7:stosw                              ; z pis znaku do videopamˆti
         and       al,30h                   ; navr t¡ mezeru nebo "0"
         ret
; *****************************************************************************
;                                 D A T A
; *****************************************************************************
public   TopText,EndText,Atrib1,Atrib2,Atrib3,PrvniBDT,PoslBDT
public   AdrBDT,DelkVRAM,AdrVRAM,BuffVRAM

TopText  db        '                                    Stav'
         db        ' BDT                               00:00',0
EndText  db        '        BDT: G=generov no, L=nal dov no,'
         db        ' A=aktivn¡, Z=zav©eno                   ',0

Atrib1   db        0bh                      ; barva polo‘ek BDT
Atrib2   db        30h                      ; barva horn¡ho a spodn¡ho © dku
Atrib3   db        0eh                      ; vysv¡cen  barva v polo‘ce BDT

PrvniBDT db        64                       ; ‡¡slo prvn¡ho BDT
PoslBDT  db        125                      ; ‡¡slo posledn¡ho BDT
AdrBDT   dd        00400060h                ; adresa tabulky BDT

PocRadku db        8                        ; po‡et © dk– s BDT
DelkVRAM dw        10*80*2                  ; d‚lka videopamˆti
AdrVRAM  dd        0b8000000h               ; adresa videopamˆti
BuffVRAM label     word
;         dw        10*80*2 dup(?)           ; buffer pro ulo‘en¡ VIDEORAM

code     ENDS
         END       start               ; startovac¡ adresa

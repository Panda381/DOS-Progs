; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                        Horizont ln¡ menu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        obsluha horizont ln¡ho menu DS:SI (BX=volba 1..., CY=p©eru¨en¡,BX=0)
; -----------------------------------------------------------------------------

HMenu    PROC      NEAR

; ------ £schova okna

         mov       di,ds:[si]               ; po‡ te‡n¡ adresa okna
         mov       cx,ds:[si+2]             ; ¨¡©ka a v˜¨ka okna
         add       cx,104h                  ; korekce
         call      PushScr                  ; £schova obsahu obrazovky

; ------ nulov n¡ p©¡znak– editace

         cmp       byte ptr ds:[si+7],0
         je        HMenu015                 ; nejsou textov‚ parametry
         push      si
         mov       si,ds:[si+14]            ; textov‚ parametry
         cld
HMenu011:lodsb
         cmp       al,0
         je        HMenu014
         test      al,bit0
         jnz       HMenu011
         and       byte ptr ds:[si-1],not bit7+bit6
         mov       di,ds:[si+4-1]
         mov       byte ptr ds:[di],0       ; nulov n¡ kurzoru
         add       si,9
         lodsb
         mov       ah,0
         add       si,ax
         jmp       short HMenu011
HMenu014:pop       si

; ------ prvn¡ zobrazen¡ menu

HMenu015:mov       byte ptr ds:[si+5],1     ; aktivn¡ volba 1
         call      DispHMnu                 ; zobrazen¡ horizont ln¡ho menu

; ------ mal  prodleva

         call      FlushChr                 ; vypr zdnˆn¡ bufferu kl vesnice
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       dl,5
HMenu01: mov       ax,ds:[46ch]
         xor       cx,cx
HMenu02: mov       dh,4
HMenu03: sti
         cmp       ax,ds:[46ch]
         loope     HMenu03
         jne       HMenu04
         dec       dh
         jnz       HMenu03
HMenu04: dec       dl
         jnz       HMenu01
         pop       ds
         call      FlushChr                 ; vypr zdnˆn¡ bufferu kl vesnice

; ------ ‡ek n¡ na stisk kl vesy

HMenu1:  call      DispHMnu                 ; zobrazen¡ horizont ln¡ho menu
         call      InpChr                   ; ‡ek n¡ na stisk kl vesy

         mov       al,ds:[si+7]             ; textov˜ch parametr–
         cmp       al,ds:[si+5]             ; jsou aktivn¡ textov‚ parametry ?
         jb        HMenu11                  ; nejsou aktivn¡ textov‚ parametry
         cmp       bx,1c0dh
         je        HMenu11
         cmp       bx,11bh
         je        HMenu11
         cmp       bx,0f09h
         je        HMenu11
         jmp       HMenuT                   ; editace textov˜ch parametr–

HMenu11: mov       al,ds:[si+5]             ; aktivn¡ volba
         mov       ah,0
         call      JumpBX                   ; obsluha kl vesy BX

         dw        0f09h,HMenu3             ; TAB
         dw        0f00h,HMenu4             ; Shift-TAB
         dw        4d00h,HMenu3             ; vpravo
         dw        4b00h,HMenu4             ; vlevo
         dw        5000h,HMenu3             ; dol–
         dw        4800h,HMenu4             ; nahoru
         dw        4700h,HMenu31            ; Home
         dw        4f00h,HMenu41            ; End
         dw        11bh,HMenu7              ; ESC
         dw        1c0dh,HMenu8             ; ENTER
         dw        0,HMenu2

; ------ jin  kl vesa

HMenu2:  xchg      ax,bx
         call      UpCase                   ; p©evod na velk‚ p¡smeno
         mov       di,ds:[si+10]            ; volby
         mov       ch,0
         mov       cl,ds:[si+4]             ; po‡et voleb
HMenu21: cmp       al,ds:[di+1]             ; je to hledan  kl vesa ?
         je        HMenu24                  ; kl vesa nalezena OK
         mov       bl,ds:[di]               ; d‚lka textu polo‘ky
         inc       di
         mov       bh,0
         add       di,bx                    ; adresa dal¨¡ volby
         loop      HMenu21                  ; test dal¨¡ volby
         jmp       short HMenu1

HMenu24: sub       cl,ds:[si+4]
         neg       cx
         inc       cx                       ; nov  aktivn¡ volba
         mov       ds:[si+5],cl             ; zvolen  aktivn¡ volba
         jmp       short HMenu8

; ------ zv˜¨en¡ ‡¡sla volby

HMenu3:  inc       ax                       ; zv˜¨en¡ ‡¡sla volby
         cmp       al,ds:[si+4]             ; p©ekro‡en po‡et voleb ?
         jbe       HMenu32                  ; ‡¡slo volby je OK
HMenu31: mov       al,1                     ; omezen¡ ‡¡sla volby na za‡ tek
HMenu32: mov       ds:[si+5],al             ; nov  aktivn¡ volba
         jmp       HMenu1

; ------ sn¡‘en¡ ‡¡sla volby

HMenu4:  dec       ax                       ; sn¡‘en¡ ‡¡sla volby
         jnz       HMenu32                  ; nen¡ p©ete‡en¡ ‡¡sla volby
HMenu41: mov       al,ds:[si+4]             ; posledn¡ volba
         jmp       short HMenu32

; ------ konec volby ESC

HMenu7:  xor       bx,bx
         stc
         jmp       short HMenu9

; ------ konec volby ENTER

HMenu8:  mov       bl,ds:[si+5]             ; aktivn¡ volba
         mov       bh,0
         clc

; ------ n vrat okna

HMenu9:  pushf
         mov       di,ds:[si]               ; po‡ te‡n¡ adresa okna
         mov       cx,ds:[si+2]             ; ¨¡©ka a v˜¨ka okna
         add       cx,104h                  ; korekce
         call      PopScr                   ; n vrat obsahu obrazovky
         call      DispFn0                  ; zobrazen¡ funk‡n¡ch kl ves
         popf
         ret

; ------ nalezen¡ textov‚ho parametru

HMenuT:  mov       di,ds:[si+14]            ; textov‚ volby
         mov       cl,ds:[si+5]             ; aktivn¡ volba
         mov       ch,0
HMenuT1: inc       di
         test      byte ptr ds:[di-1],bit0  ; je pr zdn˜ © dek ?
         jnz       HMenuT1                  ; je pr zdn˜ © dek
         dec       cx
         jz        HMenuT2                  ; nalezen parametr
         add       di,10                    ; za‡ tek textu
         mov       al,ds:[di-1]             ; d‚lka textu
         mov       ah,0
         add       di,ax                    ; dal¨¡ polo‘ka
         jmp       short HMenuT1

; ------ skok na obsluhu podle kl vesy

HMenuT2: dec       di
         push      bx
         mov       bx,ds:[di+4]             ; ukazatel kurzoru
         mov       dx,ds:[bx]               ; offset kurzoru
         pop       bx

         cmp       word ptr ds:[di+8],0     ; je maska ?
         je        HMenuT22                 ; nen¡ maska
         xor       ax,ax                    ; n hradn¡ znak
         cmp       bx,1615h
         je        HMenuT31                 ; je n hradn¡ znak Ctrl-U

HMenuT22:cmp       bh,0eh
         je        HMenuT23
         cmp       bx,300h
         je        HMenuT3
         cmp       bl,0
         jne       HMenuT3
HMenuT23:call      JumpBX

         dw        4b00h,HMenT52            ; vlevo
         dw        7300h,HMenuT5            ; Ctrl-vlevo
         dw        4d00h,HMenT411           ; vpravo
         dw        7400h,HMenuT4            ; Ctrl-vpravo
         dw        5300h,HMenuT82           ; Delete
         dw        0e08h,HMenuT8            ; BS
         dw        4700h,HMenuT6            ; HOME
         dw        4f00h,HMenuT7            ; END
         dw        5200h,HMenuT9            ; Insert

         dw        0,HMenu11

; ------ vlo‘en¡ znaku do bufferu

HMenuT3: xchg      ax,bx                    ; AL <- znak k ulo‘en¡
         cmp       di,offset HledMnTP
         jne       HMenT317
         call      UpCase

         cmp       al," "
         je        HMenT317
         cmp       al,"B"
         je        HMenT317
         cmp       al,"L"
         je        HMenT317
         cmp       al,"G"
         je        HMenT317
         cmp       al,"U"
         je        HMenT317
         cmp       al,"N"
         je        HMenT317
         cmp       al,"W"
         je        HMenT317
         cmp       al,"0"
         jb        HMenT316
         cmp       al,"9"
         jbe       HMenT317
HMenT316:jmp       HMenu11

HMenT317:mov       ah,-1

HMenuT31:test      byte ptr ds:[di+0],bit7  ; je ji‘ zah jena editace ?
         jnz       HMenuT39                 ; editace je ji‘ zah jena
         push      ax
         push      si
         push      di
         push      ds
         pop       es
         mov       bx,ds:[di+4]             ; aktivn¡ ukazatel kurzoru
         mov       si,ds:[si+14]            ; texty voleb
         xor       ax,ax
         xor       cx,cx
HMenuT32:lodsb
         cmp       al,0
         je        HMenuT35
         test      al,bit0
         jnz       HMenuT32                 ; pr zdn˜ © dek
         cmp       bx,ds:[si+4-1]           ; souhlas¡ ukazatel kurzoru ?
         jne       HMenuT34                 ; ukazatel kurzoru nesouhlas¡
         or        byte ptr ds:[si-1],bit7  ; p©¡znak modifikace kurzoru
         and       byte ptr ds:[si-1],not bit6 ; sud  pozice
         mov       di,ds:[si+2-1]
         mov       byte ptr ds:[di],0       ; d‚lka textu
         mov       di,ds:[si+4-1]
         mov       byte ptr ds:[di],0       ; kurzor
         mov       di,ds:[si+6-1]           ; text
         mov       al,0
         mov       cl,ds:[si+1-1]           ; d‚lka textu
         rep       stosb
         mov       di,ds:[si+8-1]           ; maska
         or        di,di
         jz        HMenuT34
         mov       cl,ds:[si+1-1]           ; d‚lka masky
         rep       stosb
HMenuT34:add       si,10-1
         lodsb
         add       si,ax
         jmp       short HMenuT32
HMenuT35:pop       di
         pop       si
         pop       ax

HMenuT39:mov       bx,ds:[di+6]             ; buffer
         add       bx,dx                    ; kurzor
         test      byte ptr ds:[di+0],bit2  ; je m¢d HEX ?
         jz        HMenT398                 ; nen¡ m¢d HEX
         or        ax,ax
         jz        HMenT398                 ; neplatn˜ znak

         call      TestHex
         jc        HMenuT44                 ; neplatn˜ znak

         mov       ch,0f0h                  ; maska
         mov       cl,4
         test      byte ptr ds:[di+0],bit6  ; je lich˜ znak ?
         jz        HMenT392                 ; je sud˜ znak
         mov       cl,0
HMenT392:shl       al,cl
         shr       ch,cl
         and       ds:[bx],ch               ; zru¨en¡ star˜ch dat
         or        ds:[bx],al               ; nastaven¡ nov˜ch dat
         jmp       short HMenT396

HMenT398:mov       ds:[bx],al               ; ulo‘en¡ znaku
HMenT396:mov       bx,ds:[di+8]             ; maska
         or        bx,bx
         jz        HMenT399                 ; nen¡ maska
         add       bx,dx                    ; kurzor
         mov       ds:[bx],ah               ; ulo‘en¡ znaku masky

HMenT399:mov       bx,ds:[di+2]             ; ukazatel d‚lky textu
         mov       al,ds:[bx]               ; d‚lka textu
         cmp       dl,al                    ; je kurzor za textem ?
         jb        HMenT410                 ; kurzor nen¡ za textem
         cmp       al,ds:[di+1]             ; je buffer pln˜ ?
         jae       HMenT410                 ; buffer je pln˜
         inc       byte ptr ds:[bx]         ; zv˜¨en¡ d‚lky textu
HMenT410:cmp       ah,0
         je        HMenuT4                  ; neplatn˜ znak

; ------ posun kurzoru vpravo v m¢du HEX

HMenT411:test      byte ptr ds:[di+0],bit2  ; je HEX m¢d ?
         jz        HMenuT4                  ; nen¡ HEX m¢d
         test      byte ptr ds:[di+0],bit6  ; je lich  pozice ?
         jnz       HMenuT4                  ; je lich  pozice
         mov       bx,ds:[di+2]             ; ukazatel d‚lky textu
         cmp       dl,ds:[bx]               ; je kurzor na konci textu ?
         jae       HMenuT42                 ; kurzor je na konci textu
         or        byte ptr ds:[di+0],bit6  ; kurzor na lichou pozici
         jmp       short HMenuT42

; ------ posun kurzoru vpravo

HMenuT4: mov       bx,ds:[di+2]             ; ukazatel d‚lky textu
         inc       dx                       ; zv˜¨en¡ pozice kurzoru
HMenuT40:cmp       dl,ds:[di+1]             ; je na konci bufferu ?
         jae       HMenuT41                 ; je na konci bufferu
         cmp       dl,ds:[bx]               ; je kurzor na konci textu ?
         jbe       HMenT422                 ; kurzor nen¡ na konci textu
HMenuT41:dec       dx                       ; n vrat pozice kurzoru
         jmp       short HMenuT42

; ------ ulo‘en¡ nov‚ pozice kurzoru

HMenT422:and       byte ptr ds:[di+0],not bit6 ; sud˜ znak

HMenuT42:mov       bx,ds:[di+4]             ; ukazatel kurzoru
         mov       ds:[bx],dl               ; ulo‘en¡ nov‚ho kurzoru

; ------ p©¡znak zah jen¡ editace

HMenuT44:test      byte ptr ds:[di+0],bit7  ; je ji‘ zah jena editace ?
         jnz       HMenuT49                 ; editace je ji‘ zah jena
         push      si
         mov       bx,ds:[di+4]             ; aktivn¡ ukazatel kurzoru
         mov       si,ds:[si+14]            ; texty voleb
         xor       ax,ax
HMenuT45:lodsb
         cmp       al,0
         je        HMenuT47
         test      al,bit0
         jnz       HMenuT45                 ; pr zdn˜ © dek
         cmp       bx,ds:[si+4-1]           ; souhlas¡ ukazatel kurzoru ?
         jne       HMenuT46                 ; ukazatel kurzoru nesouhlas¡
         or        byte ptr ds:[si-1],bit7  ; p©¡znak modifikace kurzoru
HMenuT46:add       si,10-1
         lodsb
         add       si,ax
         jmp       short HMenuT45
HMenuT47:pop       si

HMenuT49:jmp       HMenu1


; ------ posun kurzoru vlevo v m¢du HEX

HMenT52: test      byte ptr ds:[di+0],bit2  ; je HEX m¢d ?
         jz        HMenuT5                  ; nen¡ HEX m¢d
         test      byte ptr ds:[di+0],bit6  ; je sud  pozice ?
         jz        HMenuT53                 ; je sud  pozice
         and       byte ptr ds:[di+0],not bit6 ; sud˜ znak
         jmp       short HMenuT42

HMenuT53:or        dl,dl
         jz        HMenuT44                 ; je ji‘ za‡ tek textu
         dec       dx                       ; sn¡‘en¡ ukazatele kurzoru
         or        byte ptr ds:[di+0],bit6  ; kurzor na lichou pozici
         jmp       short HMenuT42

; ------ posun kurzoru vlevo

HMenuT5: and       byte ptr ds:[di+0],not bit6 ; sud˜ znak
HMenuT55:or        dl,dl                    ; je za‡ tek textu ?
         jz        HMenuT44                 ; je ji‘ za‡ tek textu
         dec       dx                       ; sn¡‘en¡ ukazatele kurzoru
         jmp       short HMenuT42           ; nov  pozice kurzoru

; ------ za‡ tek pole

HMenuT6: mov       dl,0
         jmp       short HMenT422

; ------ konec pole

HMenuT7: mov       bx,ds:[di+2]             ; ukazatel d‚lky textu
         mov       dl,ds:[bx]               ; konec textu
HMenuT72:and       byte ptr ds:[di+0],not bit6 ; sud˜ znak
HMenuT73:jmp       short HMenuT40

; ------ zru¨en¡ znaku p©ed kurzorem

HMenuT8: or        dl,dl
         jz        HMenuT44                 ; je ji‘ za‡ tek © dku
         dec       dx                       ; sn¡‘en¡ pozice kurzoru
         mov       bx,ds:[di+4]             ; ukazatel kurzoru
         mov       ds:[bx],dl               ; ulo‘en¡ nov‚ho kurzoru

; ------ zru¨en¡ znaku za kurzorem

HMenuT82:mov       bx,ds:[di+2]             ; d‚lka textu
         cmp       dl,ds:[bx]               ; je kurzor na konci textu ?
         jae       HMenuT73                 ; je na konci textu
         dec       byte ptr ds:[bx]         ; sn¡‘en¡ d‚lky textu

         push      ds
         pop       es
         push      si
         push      di

         mov       ch,0
         mov       cl,ds:[di+1]             ; d‚lka bufferu
         sub       cl,dl                    ; zbytek bufferu
         mov       si,ds:[di+6]             ; buffer
         add       si,dx                    ; kurzor
         mov       di,si
         inc       si
         push      cx
         cld
         rep       movsb                    ; p©¡sun dat
         pop       cx

         pop       di
         push      di
         mov       si,ds:[di+8]             ; maska
         or        si,si
         jz        HMenuT87                 ; nen¡ maska
         add       si,dx                    ; kurzor
         mov       di,si
         inc       si
         rep       movsb                    ; p©¡sun dat

HMenuT87:pop       di
         pop       si

HMenuT88:jmp       short HMenuT72

; ------ vlo‘en¡ mezery Insert

HMenuT9: mov       bx,ds:[di+2]             ; d‚lka textu
         mov       al,ds:[bx]               ; d‚lka textu
         cmp       al,ds:[di+1]             ; je buffer pln˜ ?
         jae       HMenuT73                 ; buffer je ji‘ pln˜
         inc       byte ptr ds:[bx]         ; zv˜¨en¡ d‚lky textu

         push      ds
         pop       es
         push      si
         push      di

         mov       ah,0
         mov       cx,ax                    ; d‚lka bufferu
         sub       cl,dl                    ; zbytek bufferu
         mov       si,ds:[di+6]             ; buffer
         add       si,ax                    ; konec bufferu
         mov       di,si
         dec       si
         push      cx
         std
         rep       movsb                    ; p©¡sun dat
         mov       byte ptr ds:[di]," "
         pop       cx

         pop       di
         push      di
         mov       si,ds:[di+8]             ; maska
         or        si,si
         jz        HMenuT92                 ; nen¡ maska
         add       si,ax                    ; konec bufferu
         mov       di,si
         dec       si
         rep       movsb                    ; p©¡sun dat
         mov       byte ptr ds:[di],-1

HMenuT92:pop       di
         pop       si
         jmp       short HMenuT88

HMenu    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ horizont ln¡ho menu DS:SI
; -----------------------------------------------------------------------------

DispHMnu PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©¡prava registr–

         mov       bp,si                    ; za‡ tek menu
         mov       di,ds:[si]               ; po‡ te‡n¡ adresa okna
         mov       cx,ds:[si+2]             ; ¨¡©ka a v˜¨ka okna
         add       cl,2                     ; korekce
         call      StinWin                  ; zobrazen¡ st¡nu pod oknem

         cld
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       di,ds:[bp+0]             ; po‡ te‡n¡ adresa k ulo‘en¡ okna
         mov       ch,0
         mov       cl,ds:[bp+2]             ; vnit©n¡ ¨¡©ka okna
         mov       ah,ds:[ColMnu1]          ; barva okna

; ------ zobrazen¡ horn¡ho okraje

         push      di
         push      cx
         mov       al,"Ú"
         stosw
         mov       al,"Ä"
         rep       stosw
         mov       al,"¿"
         stosw
         pop       cx
         pop       di
         add       di,160

; ------ zobrazen¡ horn¡ho pr zdn‚ho © dku

         push      di
         push      cx
         mov       al,"³"
         stosw
         mov       al," "
         rep       stosw
         mov       al,"³"
         stosw
         pop       cx
         pop       di
         add       di,160

; ------ zobrazen¡ © dk– nadpisu

         mov       si,ds:[bp+8]             ; nadpis
         lodsb
         mov       dl,al                    ; po‡et © dk– nadpisu
DispHMn1:push      di
         push      cx
         lodsb                              ; d‚lka textu
         mov       dh,al                    ; d‚lka textu
         sub       cl,dh                    ; zbytek na okraje
         shr       cl,1                     ; polovina na lev˜ okraj
         mov       bl,cl                    ; £schova pro prav˜ okraj
         adc       bl,0                     ; lich  mezera vpravo
         mov       al,"³"
         stosw
         mov       al," "
         rep       stosw                    ; lev˜ okraj
         mov       cl,dh                    ; d‚lka textu
DispHMn2:lodsb
         stosw
         loop      DispHMn2                 ; zobrazen¡ textu
         mov       cl,bl                    ; prav˜ okraj
         mov       al," "
         rep       stosw                    ; prav˜ okraj
         mov       al,"³"
         stosw
         pop       cx
         pop       di
         add       di,160
         dec       dl
         jnz       DispHMn1                 ; dal¨¡ © dek nadpisu

; ------ zobrazen¡ st©edn¡ho pr zdn‚ho © dku

         push      di
         push      cx
         mov       al,"³"
         stosw
         mov       al," "
         rep       stosw
         mov       al,"³"
         stosw
         pop       cx
         pop       di
         add       di,160

; ------ p©¡prava k zobrazen¡ editovan˜ch © dk– voleb

         mov       si,ds:[bp+14]            ; definice voleb
         cmp       byte ptr ds:[bp+7],0     ; jsou textov‚ parametry ?
         jne       DispHM21                 ; jsou nˆjak‚ textov‚ parametry
         jmp       DispHMn3                 ; nejsou ‘ dn‚ textov‚ © dky

; ------ pr zdn˜ © dek

DispHM21:push      di
         push      cx
         mov       ah,ds:[ColMnu1]          ; barva okna
         mov       al,"³"
         stosw
         test      byte ptr ds:[si],bit0    ; je pr zdn˜ © dek ?
         jz        DispH211                 ; nen¡ pr zdn˜ © dek
         inc       si                       ; adresa dal¨¡ polo‘ky
         jmp       DispHM28                 ; je pr zdn˜ © dek

; ------ £vodn¡ text volby

DispH211:push      si
         add       si,10
         lodsb                              ; d‚lka textu
         sub       cl,al                    ; ode‡ten¡ d‚lky textu
         push      cx
         mov       cl,al
         jcxz      DispHM23
DispHM22:lodsb
         stosw
         loop      DispHM22
DispHM23:pop       cx
         pop       si

; ------ zobrazen¡ textu ASCII

         test      byte ptr ds:[si],bit1    ; je bˆ‘n˜ text ?
         jz        DispHM25                 ; nen¡ bˆ‘n˜ text
         mov       dl,ds:[si+1]             ; celkov  d‚lka textu
         sub       cl,dl                    ; ode‡ten¡ d‚lky textu
         push      si
         push      cx
         mov       bx,ds:[si+2]             ; ukazatel d‚lky textu
         mov       cx,ds:[bx]               ; d‚lka textu
         sub       dl,cl                    ; zbytek textu
         mov       bx,ds:[si+8]             ; maska textu
         mov       si,ds:[si+6]             ; zad van˜ text
         jcxz      DispH246                 ; nen¡ ‘ dn˜ text
DispH242:or        bx,bx                    ; je zadan  maska ?
         jz        DispH244                 ; nen¡ zadan  maska
         inc       bx
         mov       ah,ds:[ColMnu4]          ; vysv¡cen  barva
         inc       si
         mov       al,"?"
         cmp       byte ptr ds:[bx-1],0     ; je platn˜ znak ?
         je        DispH245                 ; nen¡ platn˜ znak
         dec       si
DispH244:mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva
         lodsb                              ; znak textu
DispH245:stosw
         loop      DispH242                 ; dal¨¡ znak
DispH246:mov       cl,dl                    ; d‚lka zbytku textu
         mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva
         mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku © dku
         pop       cx
         pop       si
         jmp       short DispHM27

; ------ zobrazen¡ textu HEX

DispHM25:mov       dl,ds:[si+1]             ; celkov  d‚lka textu
         mov       al,dl
         shl       al,1
         add       dl,al
         dec       dx                       ; celkov  d‚lka pole
         sub       cl,dl                    ; ode‡ten¡ d‚lky textu
         push      si
         push      cx
         mov       bx,ds:[si+2]             ; ukazatel d‚lky textu
         mov       cx,ds:[bx]               ; d‚lka textu
         mov       bx,ds:[si+8]             ; maska textu
         mov       si,ds:[si+6]             ; zad van˜ text
         jcxz      DispH256                 ; nen¡ ‘ dn˜ text
         sub       dl,cl
         sub       dl,cl
         sub       dl,cl                    ; zbytek textu
         inc       dx
         jmp       short DispH252
DispH251:mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
DispH252:or        bx,bx                    ; je zadan  maska ?
         jz        DispH254                 ; nen¡ zadan  maska
         inc       bx
         cmp       byte ptr ds:[bx-1],0     ; je platn˜ znak ?
         jne       DispH254                 ; je platn˜ znak
         lodsb
         mov       al,"?"
         mov       ah,ds:[ColMnu4]          ; vysv¡cen  barva
         stosw
         stosw                              ; n hradn¡ znak
         jmp       short DispH255
DispH254:mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva
         lodsb                              ; znak textu
         push      dx
         mov       dl,al                    ; bajt
         call      DekHexB                  ; dek¢dov n¡ bajtu HEX
         pop       dx
DispH255:loop      DispH251                 ; dal¨¡ znak
DispH256:mov       cl,dl                    ; d‚lka zbytku textu
         mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva
         mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku © dku
         pop       cx
         pop       si

; ------ p©¡prava pro dal¨¡ © dek

DispHM27:add       si,10
         lodsb
         mov       ah,0
         add       si,ax
DispHM28:mov       ah,ds:[ColMnu1]          ; barva okna
         mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku © dku
         mov       al,"³"
         stosw
         pop       cx
         pop       di
         add       di,160
         cmp       byte ptr ds:[si],0
         je        DispHMn3
         jmp       DispHM21                 ; dal¨¡ © dek

; ------ horn¡ okraj voleb

DispHMn3:push      di
         push      cx
         mov       ch,0
         mov       ah,ds:[ColMnu1]
         mov       al,"³"
         stosw
         mov       bl,ds:[bp+2]             ; vnit©n¡ ¨¡©ka okna
         mov       dx,ds:[bp+4]             ; DH=aktivn¡ volba, DL=po‡et voleb
         sub       dh,ds:[bp+7]             ; ode‡ten¡ textov˜ch parametr–
         sub       dl,ds:[bp+7]             ; ode‡ten¡ textov˜ch parametr–
         mov       si,ds:[bp+10]            ; volby

DispHM32:mov       cl,ds:[bp+6]             ; po‡et mezer mezi volbami
         sub       bl,cl                    ; ode‡ten¡ mezery
         mov       al," "
         mov       ah,ds:[ColMnu1]
         rep       stosw                    ; oddˆlovac¡ mezera

         lodsb                              ; d‚lka textu volby
         mov       ah,0
         add       si,ax                    ; adresa dal¨¡ volby
         add       al,2
         sub       bl,al                    ; ode‡ten¡ d‚lky volby
         sub       bl,2                     ; ode‡ten¡ okraj–
         xchg      ax,cx                    ; d‚lka textu volby
         dec       dh                       ; ‡¡ta‡ aktivn¡ volby
         jnz       DispHM34                 ; nen¡ aktivn¡ volba
         mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva kurzoru
DispHM33:mov       al,"É"
         stosw
         mov       al,"Í"
         rep       stosw
         mov       al,"»"
         jmp       short DispHM36

DispHM34:mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva okna
         mov       al,ds:[bp+7]             ; textov‚ volby
         cmp       al,ds:[bp+5]             ; jsou aktivn¡ textov‚ volby ?
         jb        DispHM35                 ; nejsou aktivn¡ textov‚ volby
         add       al,dl                    ; celkov˜ po‡et voleb
         cmp       al,ds:[bp+4]             ; je prvn¡ volba ?
         je        DispHM33                 ; je prvn¡ volba
DispHM35:mov       al,"Ú"
         stosw
         mov       al,"Ä"
         rep       stosw
         mov       al,"¿"
DispHM36:stosw

         dec       dl
         jnz       DispHM32

         mov       ah,ds:[ColMnu1]
         mov       al," "
         mov       cl,bl                    ; z vˆre‡n  mezera
         rep       stosw                    ; z vˆre‡n  mezera

         mov       al,"³"
         stosw

         pop       cx
         pop       di
         add       di,160

; ------ st©edn¡ © dek voleb

         push      di
         push      cx
         mov       ch,0
         mov       ah,ds:[ColMnu1]
         mov       al,"³"
         stosw
         mov       dx,ds:[bp+4]             ; DH=aktivn¡ volba, DL=po‡et voleb
         sub       dh,ds:[bp+7]             ; ode‡ten¡ textov˜ch parametr–
         sub       dl,ds:[bp+7]             ; ode‡ten¡ textov˜ch parametr–
         mov       si,ds:[bp+10]            ; volby

DispHM42:
         mov       ah,ds:[ColMnu1]
         mov       cl,ds:[bp+6]
         mov       al," "
         rep       stosw                    ; £vodn¡ mezery

         lodsb                              ; d‚lka textu volby
         mov       cl,al                    ; d‚lka textu volby
         dec       dh                       ; ‡¡ta‡ aktivn¡ volby
         jnz       DispHM44                 ; nen¡ aktivn¡ volba
         mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva kurzoru
         mov       al,"º"
         stosw
         mov       al," "
         stosw
         mov       ah,ds:[ColMnu4]          ; vysv¡cen  barva kurzoru
         lodsb
         stosw                              ; vysv¡cen˜ znak
         dec       cx
         mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva kurzoru
DispHM43:lodsb
         stosw
         loop      DispHM43
         mov       al," "
         stosw
         mov       al,"º"
         jmp       short DispHM46

DispHM44:mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva okna
         mov       al,ds:[bp+7]             ; textov‚ volby
         cmp       al,ds:[bp+5]             ; jsou aktivn¡ textov‚ volby ?
         jb        DispH442                 ; nejsou aktivn¡ textov‚ volby
         add       al,dl                    ; celkov˜ po‡et voleb
         cmp       al,ds:[bp+4]             ; je prvn¡ volba ?
         jne       DispH442                 ; nen¡ prvn¡ volba

         mov       al,"º"
         stosw
         mov       al," "
         stosw
         mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva kurzoru
         jmp       short DispHM43

DispH442:mov       al,"³"
         stosw
         mov       al," "
         stosw
         mov       al,ds:[bp+7]             ; textov‚ volby
         cmp       al,ds:[bp+5]             ; jsou aktivn¡ textov‚ volby ?
         jae       DispH452                 ; jsou aktivn¡ textov‚ volby
         mov       ah,ds:[ColMnu3]          ; vysv¡cen  barva volby
         lodsb
         stosw
         dec       cx
DispH452:mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva okna
DispHM45:lodsb
         stosw
         loop      DispHM45
         mov       al," "
         stosw
         mov       al,"³"
DispHM46:stosw

         dec       dl
         jnz       DispHM42

         mov       ah,ds:[ColMnu1]
         mov       cl,bl                    ; z vˆre‡n  mezera
         mov       al," "
         rep       stosw                    ; z vˆre‡n  mezera

         mov       al,"³"
         stosw

         pop       cx
         pop       di
         add       di,160

; ------ doln¡ okraj voleb

         push      di
         push      cx
         mov       ch,0
         mov       ah,ds:[ColMnu1]
         mov       al,"³"
         stosw
         mov       dx,ds:[bp+4]             ; DH=aktivn¡ volba, DL=po‡et voleb
         sub       dh,ds:[bp+7]             ; ode‡ten¡ textov˜ch parametr–
         sub       dl,ds:[bp+7]             ; ode‡ten¡ textov˜ch parametr–
         mov       si,ds:[bp+10]            ; volby
DispHM52:
         mov       cl,ds:[bp+6]
         mov       al," "
         mov       ah,ds:[ColMnu1]
         rep       stosw                    ; £vodn¡ mezery

         lodsb                              ; d‚lka textu volby
         mov       ah,0
         add       si,ax                    ; adresa dal¨¡ volby
         add       al,2
         xchg      ax,cx                    ; d‚lka textu volby
         dec       dh                       ; ‡¡ta‡ aktivn¡ volby
         jnz       DispHM54                 ; nen¡ aktivn¡ volba
         mov       ah,ds:[ColMnu2]          ; bˆ‘n  barva kurzoru
DispHM53:mov       al,"È"
         stosw
         mov       al,"Í"
         rep       stosw
         mov       al,"¼"
         jmp       short DispHM56

DispHM54:mov       ah,ds:[ColMnu1]          ; bˆ‘n  barva okna
         mov       al,ds:[bp+7]             ; textov‚ volby
         cmp       al,ds:[bp+5]             ; jsou aktivn¡ textov‚ volby ?
         jb        DispHM55                 ; nejsou aktivn¡ textov‚ volby
         add       al,dl                    ; celkov˜ po‡et voleb
         cmp       al,ds:[bp+4]             ; je prvn¡ volba ?
         je        DispHM53                 ; je prvn¡ volba

DispHM55:mov       al,"À"
         stosw
         mov       al,"Ä"
         rep       stosw
         mov       al,"Ù"
DispHM56:stosw

         dec       dl
         jnz       DispHM52

         mov       ah,ds:[ColMnu1]
         mov       cl,bl                    ; z vˆre‡n  mezera
         mov       al," "
         rep       stosw                    ; £vodn¡ mezery

         mov       al,"³"
         stosw

         pop       cx
         pop       di
         add       di,160

; ------ zobrazen¡ doln¡ho okraje

         push      di
         push      cx
         mov       al,"À"
         stosw
         mov       al,"Ä"
         rep       stosw
         mov       al,"Ù"
         stosw
         pop       cx
         pop       di
         add       di,160+2*2

; ------ zobrazen¡ n povˆdy k menu

         mov       ah,0
         mov       cl,ds:[bp+5]             ; aktivn¡ volba
         mov       ch,0
         mov       si,ds:[bp+12]            ; n povˆdy
         dec       cx
         jz        DispHM94                 ; je volba 1
DispHM92:lodsb
         add       si,ax
         loop      DispHM92                 ; dal¨¡ n povˆda
DispHM94:mov       di,24*160                ; adresa k ulo‘en¡ n povˆdy
         lodsb
         xchg      ax,cx                    ; CX <- d‚lka textu n povˆdy
         mov       dl,79
         sub       dl,cl                    ; zbytek na okraj
         mov       ah,ds:[ColMnuH]          ; barva n povˆdy menu
         mov       al," "
         stosw
DispHM95:lodsb
         stosw
         loop      DispHM95
         mov       cl,dl
         mov       al," "
         rep       stosw

; ------ ur‡en¡ adresy kurzoru

         mov       dx,25*HI
         mov       bl,ds:[bp+5]             ; aktivn¡ volba
         mov       bh,ds:[bp+7]             ; po‡et voleb textov˜ch parametr–
         cmp       bh,ds:[bp+5]             ; je zobrazen kurzor ?
         jb        DispHM99                 ; kurzor nen¡ zobrazen
         mov       ax,ds:[bp+0]             ; po‡ te‡n¡ adresa okna
         mov       dl,160                   ; po‡et bajt– na © dek
         div       dl                       ; v˜po‡et pozice a © dku
         xchg      ah,al
         shr       al,1                     ; pozice na © dku
         xchg      ax,dx                    ; DX <- pozice po‡ tku okna
         add       dh,2                     ; korekce
         mov       si,ds:[bp+8]             ; nadpis
         add       dh,ds:[si]               ; p©i‡ten¡ © dk– nadpisu
         mov       si,ds:[bp+14]            ; texty voleb
DispHM96:inc       si
         inc       dh
         test      byte ptr ds:[si-1],bit0  ; je pr zdn˜ © dek ?
         jnz       DispHM96                 ; je pr zdn˜ © dek
         dec       bl
         jz        DispHM97                 ; nalezen aktivn¡ © dek
         add       si,10
         mov       al,ds:[si-1]
         mov       ah,0
         add       si,ax
         jmp       short DispHM96

DispHM97:add       dl,1                     ; korekce
         add       dl,ds:[si+10-1]          ; po‡ tek
         test      byte ptr ds:[si-1],bit6  ; je lich  pozice kurzoru ?
         jz        DispH972                 ; nen¡ lich  pozice kurzoru
         inc       dx                       ; korekce pozice kurzoru
DispH972:test      byte ptr ds:[si-1],bit2  ; je HEX m¢d ?
         mov       si,ds:[si+4-1]           ; ukazatel kurzoru
         jz        DispHM98
         add       dl,ds:[si]               ; p©i‡ten¡ kurzoru
         add       dl,ds:[si]               ; p©i‡ten¡ kurzoru
DispHM98:add       dl,ds:[si]               ; p©i‡ten¡ kurzoru

DispHM99:call      SetKurz                  ; nastaven¡ pozice kurzoru

; ------ n vrat registr–

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispHMnu ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ st¡nu pod oknem (adresa DI, ¨¡©ka CL, v˜¨ka CH)
; -----------------------------------------------------------------------------

StinWin  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ zobrazen¡ st¡nu za oknem

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       al,ch
         mov       ch,0
         add       di,cx
         add       di,cx                    ; adresa za‡ tku st¡nu
         inc       di
StinWin1:add       di,160                   ; dal¨¡ © dek
         mov       byte ptr es:[di],7
         mov       byte ptr es:[di+2],7
         dec       al
         jnz       StinWin1

; ------ zobrazen¡ st¡nu pod oknem

         dec       cx
StinWin2:mov       byte ptr es:[di],7
         dec       di
         dec       di
         loop      StinWin2

; ------ n vrat registr–

         pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

StinWin  ENDP

; -----------------------------------------------------------------------------
;        £schova v˜©ezu obrazovky (adresa DI, ¨¡©ka CL, v˜¨ka CH)
; -----------------------------------------------------------------------------

PushScr  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         mov       si,di
         xor       di,di
         mov       es,ds:[BuffVRAM]         ; buffer pro £schovu videopamˆti
         mov       ds,ds:[SegmVRAM]         ; segment videopamˆti

; ------ £schova v˜©ezu obrazovky

PushScr2:push      cx
         push      si
         mov       ch,0
         rep       movsw
         pop       si
         pop       cx
         add       si,160
         dec       ch
         jnz       PushScr2

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

PushScr  ENDP

; -----------------------------------------------------------------------------
;        n vrat v˜©ezu obrazovky (adresa DI, ¨¡©ka CL, v˜¨ka CH)
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         mov       es,ds:[SegmVRAM]         ; segment videopamˆti
         mov       ds,ds:[BuffVRAM]         ; buffer pro £schovu videopamˆti
         xor       si,si

; ------ n vrat v˜©ezu obrazovky

PopScr2: push      cx
         push      di
         mov       ch,0
         rep       movsw
         pop       di
         pop       cx
         add       di,160
         dec       ch
         jnz       PopScr2

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

PopScr   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                  Obsluha zobrazen¡ editovan‚ho objektu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ editovan‚ho objektu
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho bloku
;                   SS:[BP-20] (1) barva ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1 = nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;
;                   SS:[BP-28] (2) - ukazatel ‡¡sla aloka‡n¡ho bloku FAT
;                                  - ukazatel adresy Assembleru
;                   SS:[BP-29] (1) editovan‚ pole
;                   SS:[BP-30] (1) £schova d‚lky instrukce Assembleru
;                   SS:[BP-32] (2) stavov‚ slovo instrukce Assembleru
; Vy‘aduje rezervu za daty 4 bajty do p©elomu 64 KB !
; -----------------------------------------------------------------------------
;þ
Disp     PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp
         sub       sp,32                    ; m¡sto pro lok ln¡ promˆnn‚

; ------ offset po‡ tku © dku

         mov       ax,word ptr ds:[EditTop+2] ; offset po‡ tku str nky HIGH
         mov       ss:[bp-2],ax
         mov       ax,word ptr ds:[EditTop] ; offset po‡ tku str nky LOW
         mov       ss:[bp-4],ax

; ------ adresa © dku v bufferu

         sub       ax,word ptr ds:[EditBeg] ; offset v bufferu
         mov       dx,ax                    ; £schova offsetu v bufferu
         add       ax,ds:[BuffOff1]         ; adresa v bufferu
         mov       word ptr ss:[bp-6],ax    ; adresa © dku v bufferu
         xchg      ax,si                    ; SI <- ukazatel dat v bufferu

; ------ adresa po‡ tku © dku ve videopamˆti

         mov       di,3*160+2               ; po‡ te‡n¡ adresa ve videopamˆti
         mov       ss:[bp-8],di             ; po‡ te‡n¡ adresa ve videopamˆti
         mov       es,ds:[SegmVRAM]         ; segment videopamˆti

; ------ ‡¡ta‡ zbyl˜ch znak– v bufferu

         mov       cx,word ptr ds:[EditNum] ; po‡et bajt– v bufferu
         sub       cx,dx                    ; zbyl˜ po‡et bajt– k zobrazen¡
         jnc       Disp02
         xor       cx,cx                    ; po‡et bajt– p©i p©ete‡en¡ za‡ tku
Disp02:  mov       ss:[bp-10],cx            ; po‡et zbyl˜ch znak– v bufferu

; ------ adresa za‡ tku bloku v bufferu

         mov       ax,word ptr ds:[EditBBeg] ; offset za‡ tku bloku LOW
         mov       dx,word ptr ds:[EditBBeg+2] ; offset za‡ tku bloku HIGH
         sub       ax,word ptr ds:[EditBeg] ; offset za‡ tku bloku v bufferu
         sbb       dx,word ptr ds:[EditBeg+2] ; p©enos HIGH
         jz        Disp03                   ; nen¡ > 64 KB
         jnc       Disp04                   ; offset je > 64 KB
         xor       ax,ax                    ; je p©ed za‡ tkem bufferu
Disp03:  add       ax,ds:[BuffOff1]         ; adresa v bufferu
         jnc       Disp05                   ; je OK
Disp04:  mov       ax,-1                    ; adresa neplatn 
Disp05:  mov       ss:[bp-24],ax            ; adresa za‡ tku bloku v bufferu

; ------ adresa konce bloku v bufferu

         mov       ax,word ptr ds:[EditBEnd] ; offset konce bloku LOW
         mov       dx,word ptr ds:[EditBEnd+2] ; offset konce bloku HIGH
         sub       ax,word ptr ds:[EditBeg] ; offset konce bloku v bufferu
         sbb       dx,word ptr ds:[EditBeg+2] ; p©enos HIGH
         jz        Disp06                   ; nen¡ > 64 KB
         jnc       Disp07                   ; offset je > 64 KB
         xor       ax,ax                    ; je p©ed za‡ tkem bufferu
Disp06:  add       ax,ds:[BuffOff1]         ; adresa v bufferu
         jnc       Disp08                   ; je OK
Disp07:  mov       ax,-1                    ; adresa neplatn 
Disp08:  cmp       ax,ss:[bp-24]            ; je konec za za‡ tkem ?
         ja        Disp09                   ; po©ad¡ za‡ tku a konce je OK
Disp082: mov       ax,-1                    ; korekce
         mov       ss:[bp-24],ax            ; zru¨en¡ za‡ tku
Disp09:  mov       ss:[bp-26],ax            ; adresa konce bloku v bufferu

; ------ adresa kurzoru v bufferu

         mov       ax,word ptr ds:[EditAkt] ; poloha kurzoru v objektu
         sub       ax,word ptr ds:[EditBeg] ; offset kurzoru v bufferu
         add       ax,ds:[BuffOff1]         ; adresa kurzoru v bufferu
         inc       ax                       ; korekce adresy kurzoru
         mov       ss:[bp-12],ax            ; adresa kurzoru v bufferu
         xchg      ax,dx                    ; DX <- adresa kurzoru v bufferu + 1

; ------ korekce adresy referen‡n¡ho bufferu

         mov       bx,7fffh                 ; korekce mezi buffery
         mov       ss:[bp-14],bx            ; korekce adres mezi buffery - 1

; ------ barvy

         mov       ax,word ptr ds:[ColEd3]  ; barva kurzoru a zv˜raz. kurzoru
         mov       ss:[bp-16],ax            ; barva kurzoru, ‡¡ta‡ © dk–
         mov       ax,word ptr ds:[ColEd1]  ; bˆ‘n  a vysv¡cen  barva
         mov       ss:[bp-18],ax            ; bˆ‘n  a vysv¡cen  barva
         mov       ax,word ptr ds:[ColEd5]  ; barva ozna‡en‚ho bloku
         mov       ss:[bp-20],ax            ; barva ozna‡en‚ho bloku

; ------ editovan‚ pole

         mov       al,ds:[EditPole]         ; editovan‚ pole
         mov       ss:[bp-29],al

; ------ p©¡prava k obsluze zobrazen¡

         mov       ax,ds:[DispMod]          ; m¢d zobrazen¡
         mov       ds,ds:[BuffSegm]         ; segment bufferu s daty
         cld

; Zde je: DS:SI=data, ES:DI=videopamˆŸ, CX=zbyl˜ch dat, BX=korekce, DX=kurzor

; ------ zobrazen¡ HEX

         shr       ax,1                     ; HEX ?
         jnc       Disp11
         call      DispH                    ; zobrazen¡ Hex
         jmp       short DispX

; ------ zobrazen¡ BIT

Disp11:  shr       ax,1                     ; Binar ?
         jnc       Disp1
         call      DispI                    ; zobrazen¡ Binar
         jmp       short DispX

; ------ zobrazen¡ BYTE

Disp1:   shr       ax,1                     ; BYTE ?
         jnc       Disp2
         call      DispB                    ; zobrazen¡ BYTE
         jmp       short DispX

; ------ zobrazen¡ WORD

Disp2:   shr       ax,1                     ; WORD ?
         jnc       Disp3
         call      DispW                    ; zobrazen¡ WORD
         jmp       short DispX

; ------ zobrazen¡ TEXT

Disp3:   shr       ax,1                     ; TEXT ?
         jnc       Disp4
         call      DispT                    ; zobrazen¡ TEXT
         jmp       short DispX

; ------ zobrazen¡ ADRESž

Disp4:   shr       ax,1                     ; ADRESž ?
         jnc       Disp5
         call      DispD                    ; zobrazen¡ adres ©e
         jmp       short DispX

; ------ zobrazen¡ FAT

Disp5:   shr       ax,1                     ; FAT ?
         jnc       Disp6
         mov       ax,cs:[FatTop]
         mov       ss:[bp-28],ax            ; ukazatel ‡¡sla alok. bloku FAT
         test      byte ptr cs:[Param2],bit0 ; je FAT 12 ?
         jz        Disp52                   ; je FAT 12
         call      Disp6F                   ; zobrazen¡ FAT 16
         jmp       short DispX
Disp52:  call      Disp2F                   ; zobrazen¡ FAT12
         jmp       short DispX

; ------ zobrazen¡ PARTITION

Disp6:   shr       ax,1                     ; PARTITION ?
         jnc       Disp7
         sub       cx,1beh
         jnc       Disp62
         xor       cx,cx
Disp62:  add       si,1beh
         call      DispP                    ; zobrazen¡ PARTITION
         jmp       short DispX

; ------ zobrazen¡ ASSEMBLER

Disp7:   shr       ax,1                     ; ASSEMBLER ?
         jnc       Disp8
         mov       ax,cs:[KorAsm]           ; korekce adresy assembleru
         sub       ax,word ptr cs:[EditTop]
         mov       ss:[bp-20],ax
         call      DispA                    ; zobrazen¡ ASSEMBLER
         jmp       short DispX

; ------ zobrazen¡ CMOS

Disp8:   call      DispC                    ; zobrazen¡ CMOS

; ------ n vrat registr–

DispX:   mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Disp     ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v HEX m¢du
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispH    PROC      NEAR

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

DispH1:  or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       DispH2                   ; jsou dal¨¡ data

         mov       ax,offset DispHC         ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       DispH8                   ; zobrazen¡ dal¨¡ho © dku

DispHC   db        9,51,16,0

; ------ zobrazen¡ offsetu po‡ tku © dku

DispH2:  mov       ah,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       dx,ss:[bp-2]             ; offset v objektu HIGH
         call      DekHexW                  ; dek¢dov n¡ vy¨¨¡ho slova offsetu
         mov       al,":"                   ; oddˆlovac¡ znak
         stosw                              ; oddˆlova‡ adresy HIGH a LOW
         mov       dx,ss:[bp-4]             ; offset v objektu LOW
         call      DekHexW                  ; dek¢dov n¡ ni‘¨¡ho slova offsetu
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw


; ====== zobrazen¡ pole HEX

; ------ p©¡prava barvy na za‡ tku © dku (podle bloku)

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispH3                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispH3                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispH3:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ p©¡prava k zobrazen¡ ‡ sti HEX

         push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         push      si                       ; ukazatel dat
         mov       dh,0                     ; ‡¡ta‡ bajt– k zobrazen¡

; ------ korekce barvy, je-li za‡ tek bloku

DispH4:  cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispH42                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ bajt k zobrazen¡

DispH42: lodsb                              ; bajt k zobrazen¡
         mov       dl,al                    ; bajt k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat
         inc       dh                       ; zv˜¨en¡ ‡¡ta‡e bajt–

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispH44                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispH44: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispH45                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu

; ------ zobrazen¡ znaku HEX

DispH45: call      DekHexB                  ; dek¢dov n¡ bajtu HEX

; ------ test, zda jsou ji‘ v¨echny znaky

         cmp       dh,16                    ; jsou ji‘ v¨echny bajty ?
         je        DispH55                  ; jsou ji‘ v¨echny znaky
         jcxz      DispH54                  ; konec dat - vymaz n¡ zbytku © dku

; ------ korekce barev, je-li konec bloku

DispH5:  cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispH51                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ oddˆlovac¡ mezera

DispH51: mov       ah,ss:[bp-22]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera

; ------ je-li osmice, oddˆlovac¡ poml‡ka

         test      dh,7                     ; je osmice ?
         jnz       DispH52                  ; nen¡ osmice
         mov       al,"-"                   ; oddˆlovac¡ poml‡ka
         stosw                              ; ulo‘en¡ poml‡ky
         mov       al," "                   ; mezera

; ------ je-li ‡tve©ice, dal¨¡ oddˆlovac¡ mezera

DispH52: test      dh,3                     ; je ‡tve©ice ?
         jnz       DispH4                   ; nen¡ ‡tve©ice
         stosw                              ; ulo‘en¡ oddˆlovac¡ mezery
         jmp       short DispH4

; ------ vymaz n¡ zbytku © dku, je-li konec dat

DispH54: mov       cl,16                    ; po‡et bajt– na © dek
         sub       cl,dh                    ; po‡et zbyl˜ch bajt–
         mov       al,3                     ; po‡et pozic na bajt
         mul       cl                       ; zbyl˜ po‡et pozic
         xchg      ax,cx                    ; CX <- po‡et pozic k vymaz n¡
         shr       ax,1
         shr       ax,1                     ; po‡et zbyl˜ch ‡tve©ic
         add       cx,ax                    ; mezery pro ‡tve©ice
         shr       ax,1                     ; po‡et zbyl˜ch osmic
         add       cx,ax                    ; mezery pro osmice
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ konec zobrazen¡ © dku HEX

DispH55: pop       si                       ; ukazatel dat
         pop       cx                       ; ‡¡ta‡ zbyl˜ch dat


; ====== zobrazen¡ pole ASCII

; ------ oddˆlovac¡ ‡ ra

         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         stosw                              ; ulo‘en¡ oddˆlovac¡ ‡ ry

; ------ p©¡prava barvy podle bloku pro zobrazen¡ dat ASCII

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispH6                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispH6                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispH6:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ korekce barvy, je-li za‡ tek bloku

         mov       dh,16                    ; ‡¡ta‡ bajt– k zobrazen¡
DispH7:  cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispH74                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ znak k zobrazen¡

DispH74: lodsb                              ; znak k zobrazen¡
         mov       dl,al                    ; znak k zobrazen¡
         dec       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispH75                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispH75: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispH76                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu
DispH76: mov       al,dl                    ; znak k zobrazen¡
         stosw                              ; zobrazen¡ znaku

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispH77                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ je-li konec dat, vymaz n¡ zbytku textu

DispH77: jcxz      DispH78                  ; konec dat - vymaz n¡ zbytku textu
         dec       dh                       ; ‡¡ta‡ dat
         jnz       DispH7                   ; zobrazen¡ dal¨¡ho znaku
         jmp       short DispH8

; ------ konec dat - vymaz n¡ zbytku textu

DispH78: mov       cl,dh                    ; po‡et zbyl˜ch pozic
         dec       cx                       ; korekce
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ p©¡prava pro dal¨¡ © dek

DispH8:  add       word ptr ss:[bp-4],16    ; zv˜¨en¡ offsetu v objektu
         adc       word ptr ss:[bp-2],0     ; p©enos HIGH
         add       di,4                     ; adresa dal¨¡ho © dku
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       DispH9                   ; jsou ji‘ v¨echny © dky
         jmp       DispH1                   ; zobrazen¡ dal¨¡ho © dku
DispH9:  ret

DispH    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v BIT m¢du
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispI    PROC      NEAR

; ====== zobrazen¡ pr zdn‚ho © dku

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

DispI1:  or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       DispI2                   ; jsou dal¨¡ data

         mov       ax,offset DispIC         ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       DispI8                   ; zobrazen¡ dal¨¡ho © dku

DispIC   db        9,35,11,15,4,0

; ------ zobrazen¡ offsetu po‡ tku © dku

DispI2:  mov       ah,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       dx,ss:[bp-2]             ; offset v objektu HIGH
         call      DekHexW                  ; dek¢dov n¡ vy¨¨¡ho slova offsetu
         mov       al,":"                   ; oddˆlovac¡ znak
         stosw                              ; oddˆlova‡ adresy HIGH a LOW
         mov       dx,ss:[bp-4]             ; offset v objektu LOW
         call      DekHexW                  ; dek¢dov n¡ ni‘¨¡ho slova offsetu
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw


; ====== zobrazen¡ pole BIT

; ------ p©¡prava barvy na za‡ tku © dku (podle bloku)

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispI3                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispI3                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispI3:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ p©¡prava k zobrazen¡ ‡ sti BIT

         push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         push      si                       ; ukazatel dat
         mov       dh,4                     ; ‡¡ta‡ bajt– k zobrazen¡

; ------ korekce barvy, je-li za‡ tek bloku

DispI31: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispI32                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ bajt k zobrazen¡

DispI32: lodsb                              ; bajt k zobrazen¡
         mov       dl,al                    ; bajt k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispI33                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispI33: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispI34                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu

; ------ zobrazen¡ znaku BIT

DispI34: call      DekBit                   ; dek¢dov n¡ bajtu BIT

; ------ test, zda jsou ji‘ v¨echny znaky

         dec       dh                       ; jsou ji‘ v¨echny bajty ?
         jz        DispI38                  ; jsou ji‘ v¨echny znaky
         jcxz      DispI37                  ; konec dat - vymaz n¡ zbytku © dku

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispI36                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ oddˆlovac¡ mezera

DispI36: mov       ah,ss:[bp-22]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         jmp       short DispI31

; ------ vymaz n¡ zbytku © dku, je-li konec dat

DispI37: mov       al,9                     ; po‡et pozic na bajt
         mul       dh                       ; zbyl˜ po‡et pozic
         xchg      ax,cx                    ; CX <- po‡et pozic k vymaz n¡
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ konec zobrazen¡ © dku BIT

DispI38: pop       si                       ; ukazatel dat
         pop       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ oddˆlovac¡ ‡ ra

         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         stosw                              ; ulo‘en¡ oddˆlovac¡ ‡ ry


; ====== zobrazen¡ pole HEX

; ------ p©¡prava barvy na za‡ tku © dku (podle bloku)

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispI4                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispI4                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispI4:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ p©¡prava k zobrazen¡ ‡ sti HEX

         push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         push      si                       ; ukazatel dat
         mov       dh,4                     ; ‡¡ta‡ bajt– k zobrazen¡

; ------ korekce barvy, je-li za‡ tek bloku

DispI41: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispI42                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ bajt k zobrazen¡

DispI42: lodsb                              ; bajt k zobrazen¡
         mov       dl,al                    ; bajt k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispI43                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispI43: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispI44                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu

; ------ zobrazen¡ znaku HEX

DispI44: call      DekHexB                  ; dek¢dov n¡ bajtu HEX

; ------ test, zda jsou ji‘ v¨echny znaky

         dec       dh                       ; jsou ji‘ v¨echny bajty ?
         jz        DispI48                  ; jsou ji‘ v¨echny znaky
         jcxz      DispI47                  ; konec dat - vymaz n¡ zbytku © dku

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispI46                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ oddˆlovac¡ mezera

DispI46: mov       ah,ss:[bp-22]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         jmp       short DispI41

; ------ vymaz n¡ zbytku © dku, je-li konec dat

DispI47: mov       al,3                     ; po‡et pozic na bajt
         mul       dh                       ; zbyl˜ po‡et pozic
         xchg      ax,cx                    ; CX <- po‡et pozic k vymaz n¡
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ konec zobrazen¡ © dku HEX

DispI48: pop       si                       ; ukazatel dat
         pop       cx                       ; ‡¡ta‡ zbyl˜ch dat


; ------ oddˆlovac¡ ‡ ra

         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         stosw                              ; ulo‘en¡ oddˆlovac¡ ‡ ry


; ====== zobrazen¡ pole DEK

; ------ p©¡prava barvy na za‡ tku © dku (podle bloku)

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispI5                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispI5                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispI5:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ p©¡prava k zobrazen¡ ‡ sti DEK

         push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         push      si                       ; ukazatel dat
         mov       dh,4                     ; ‡¡ta‡ bajt– k zobrazen¡

; ------ korekce barvy, je-li za‡ tek bloku

DispI51: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispI52                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ bajt k zobrazen¡

DispI52: lodsb                              ; bajt k zobrazen¡
         mov       dl,al                    ; bajt k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispI53                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispI53: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispI54                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu

; ------ zobrazen¡ znaku DEK

DispI54: push      dx
         mov       dh,ah                    ; barva bajtu
         mov       al,dl                    ; hodnota bajtu
         mov       dl,3                     ; po‡et pozic
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispI55                  ; nen¡ to kurzor
         cmp       byte ptr ss:[bp-29],2    ; editov no dekadick‚ pole ?
         jne       DispI55                  ; nen¡ dekadick‚ pole
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispI552
DispI55: add       di,2*3                   ; zv˜¨en¡ pozice
         call      DekByte                  ; dek¢dov n¡ bajtu Byte
DispI552:pop       dx

; ------ test, zda jsou ji‘ v¨echny znaky

         dec       dh                       ; jsou ji‘ v¨echny bajty ?
         jz        DispI58                  ; jsou ji‘ v¨echny znaky
         jcxz      DispI57                  ; konec dat - vymaz n¡ zbytku © dku

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispI56                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ oddˆlovac¡ mezera

DispI56: mov       ah,ss:[bp-22]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         jmp       short DispI51

; ------ vymaz n¡ zbytku © dku, je-li konec dat

DispI57: mov       al,4                     ; po‡et pozic na bajt
         mul       dh                       ; zbyl˜ po‡et pozic
         xchg      ax,cx                    ; CX <- po‡et pozic k vymaz n¡
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ konec zobrazen¡ © dku DEK

DispI58: pop       si                       ; ukazatel dat
         pop       cx                       ; ‡¡ta‡ zbyl˜ch dat


; ====== zobrazen¡ pole ASCII

; ------ oddˆlovac¡ ‡ ra

         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         stosw                              ; ulo‘en¡ oddˆlovac¡ ‡ ry

; ------ p©¡prava barvy podle bloku pro zobrazen¡ dat ASCII

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispI6                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispI6                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispI6:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ korekce barvy, je-li za‡ tek bloku

         mov       dh,4                     ; ‡¡ta‡ bajt– k zobrazen¡
DispI62: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispI64                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ znak k zobrazen¡

DispI64: lodsb                              ; znak k zobrazen¡
         mov       dl,al                    ; znak k zobrazen¡
         dec       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispI65                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispI65: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispI66                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu
DispI66: mov       al,dl                    ; znak k zobrazen¡
         stosw                              ; zobrazen¡ znaku

; ------ test, je-li konec dat

         dec       dh                       ; ‡¡ta‡ dat
         jz        DispI8                   ; nen¡ dal¨¡ bajt
         jcxz      DispI68                  ; konec dat - vymaz n¡ zbytku textu

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispI62                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu
         jmp       short DispI62            ; zobrazen¡ dal¨¡ho znaku

; ------ konec dat - vymaz n¡ zbytku textu

DispI68: mov       cl,dh                    ; po‡et zbyl˜ch pozic
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ p©¡prava pro dal¨¡ © dek

DispI8:  add       word ptr ss:[bp-4],4     ; zv˜¨en¡ offsetu v objektu
         adc       word ptr ss:[bp-2],0     ; p©enos HIGH
         add       di,4                     ; adresa dal¨¡ho © dku
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       DispI9                   ; jsou ji‘ v¨echny © dky
         jmp       DispI1                   ; zobrazen¡ dal¨¡ho © dku

DispI9:  ret

DispI    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du BYTE
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispB    PROC      NEAR

; ====== zobrazen¡ pr zdn‚ho © dku

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

DispB1:  or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       DispB2                   ; jsou dal¨¡ data

         mov       ax,offset DispBC         ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       DispB8                   ; zobrazen¡ dal¨¡ho © dku

DispBC   db        13,53,10,0

; ------ zobrazen¡ adresy po‡ tku © dku

DispB2:  push      bx
         mov       ax,ss:[bp-4]             ; offset © dku LOW
         mov       dx,ss:[bp-2]             ; offset © dku HIGH
         mov       bh,ss:[bp-18]            ; bˆ‘n  barva
         add       di,2*13                  ; konec pole k zobrazen¡
         call      DekDWrd                  ; dek¢dov n¡ dvojslova
         pop       bx

; ------ oddˆlova‡

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw
         mov       al," "
         stosw                              ; mezera


; ====== zobrazen¡ pole DEK

; ------ p©¡prava barvy na za‡ tku © dku (podle bloku)

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispB3                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispB3                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispB3:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ p©¡prava k zobrazen¡ ‡ sti DEK

         push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         push      si                       ; ukazatel dat
         mov       dh,10                    ; ‡¡ta‡ bajt– k zobrazen¡

; ------ korekce barvy, je-li za‡ tek bloku

DispB31: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispB32                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ bajt k zobrazen¡

DispB32: lodsb                              ; bajt k zobrazen¡
         mov       dl,al                    ; bajt k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispB33                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispB33: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispB34                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu

; ------ zobrazen¡ znaku DEK

DispB34: push      dx
         mov       dh,ah                    ; barva bajtu
         mov       al,dl                    ; hodnota bajtu
         mov       dl,3                     ; po‡et pozic
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispB35                  ; nen¡ to kurzor
         cmp       byte ptr ss:[bp-29],0    ; editov no dekadick‚ pole ?
         jne       DispB35                  ; nen¡ dekadick‚ pole
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispB352
DispB35: add       di,2*3                   ; zv˜¨en¡ pozice
         call      DekByte                  ; dek¢dov n¡ bajtu Byte
DispB352:pop       dx

; ------ test, zda jsou ji‘ v¨echny znaky

         dec       dh                       ; jsou ji‘ v¨echny bajty ?
         jz        DispB39                  ; jsou ji‘ v¨echny znaky
         jcxz      DispB37                  ; konec dat - vymaz n¡ zbytku © dku

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispB36                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ oddˆlovac¡ mezera

DispB36: mov       ah,ss:[bp-22]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         stosw
         cmp       dh,5
         jne       DispB31
         mov       al,"-"
         stosw
         mov       al," "
         stosw
         stosw
         jmp       short DispB31

; ------ vymaz n¡ zbytku © dku, je-li konec dat

DispB37: mov       al,5                     ; po‡et pozic na bajt
         mul       dh                       ; zbyl˜ po‡et pozic
         cmp       dh,5
         jb        DispB38
         add       al,3                     ; korekce pro vnit©n¡ oddˆlova‡
DispB38: xchg      ax,cx                    ; CX <- po‡et pozic k vymaz n¡
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ konec zobrazen¡ © dku DEK

DispB39: pop       si                       ; ukazatel dat
         pop       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ oddˆlova‡

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "                   ; mezera
         stosw
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw



; ====== zobrazen¡ pole ASCII

; ------ p©¡prava barvy podle bloku pro zobrazen¡ dat ASCII

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispB6                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispB6                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispB6:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ korekce barvy, je-li za‡ tek bloku

         mov       dh,10                    ; ‡¡ta‡ bajt– k zobrazen¡
DispB62: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispB64                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ znak k zobrazen¡

DispB64: lodsb                              ; znak k zobrazen¡
         mov       dl,al                    ; znak k zobrazen¡
         dec       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispB65                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispB65: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispB66                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu
DispB66: mov       al,dl                    ; znak k zobrazen¡
         stosw                              ; zobrazen¡ znaku

; ------ test, je-li konec dat

         dec       dh                       ; ‡¡ta‡ dat
         jz        DispB8                   ; nen¡ dal¨¡ bajt
         jcxz      DispB68                  ; konec dat - vymaz n¡ zbytku textu

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispB62                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu
         jmp       short DispB62            ; zobrazen¡ dal¨¡ho znaku

; ------ konec dat - vymaz n¡ zbytku textu

DispB68: mov       cl,dh                    ; po‡et zbyl˜ch pozic
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ p©¡prava pro dal¨¡ © dek

DispB8:  add       word ptr ss:[bp-4],10    ; zv˜¨en¡ offsetu v objektu
         adc       word ptr ss:[bp-2],0     ; p©enos HIGH
         add       di,4                     ; adresa dal¨¡ho © dku
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       DispB9                   ; jsou ji‘ v¨echny © dky
         jmp       DispB1                   ; zobrazen¡ dal¨¡ho © dku

DispB9:  ret

DispB    ENDP


; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du BYTE
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispW    PROC      NEAR

         mov       ax,word ptr cs:[EditAkt] ; poloha kurzoru v objektu
         sub       ax,word ptr cs:[EditBeg] ; offset kurzoru v bufferu
         and       ax,not 1
         add       ax,cs:[BuffOff1]         ; adresa kurzoru v bufferu
         inc       ax                       ; korekce adresy kurzoru
         mov       ss:[bp-12],ax            ; adresa kurzoru v bufferu

; ====== zobrazen¡ pr zdn‚ho © dku

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

DispW1:  or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       DispW2                   ; jsou dal¨¡ data

         mov       ax,offset DispWC         ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       DispW8                   ; zobrazen¡ dal¨¡ho © dku

DispWC   db        13,53,10,0

; ------ zobrazen¡ adresy po‡ tku © dku

DispW2:  push      bx
         mov       ax,ss:[bp-4]             ; offset © dku LOW
         mov       dx,ss:[bp-2]             ; offset © dku HIGH
         mov       bh,ss:[bp-18]            ; bˆ‘n  barva
         add       di,2*13                  ; konec pole k zobrazen¡
         call      DekDWrd                  ; dek¢dov n¡ dvojslova
         pop       bx

; ------ oddˆlova‡

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw
         mov       al," "
         stosw                              ; mezera
         stosw
         stosw


; ====== zobrazen¡ pole DEK

; ------ p©¡prava k zobrazen¡ ‡ sti DEK

         push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         push      si                       ; ukazatel dat
         mov       dh,5                     ; ‡¡ta‡ slov k zobrazen¡

; ------ slovo k zobrazen¡

DispW31: lodsb                              ; slovo LOW k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat
         mov       ah,0                     ; slovo HIGH, nen¡-li dal¨¡ bajt
         jcxz      DispW322                 ; nen¡ dal¨¡ bajt
         mov       ah,ds:[si]               ; slovo HIGH k zobrazen¡

; ------ ur‡en¡ barvy znaku

DispW322:push      dx                       ; ‡¡ta‡ polo‘ek na © dku
         mov       dx,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispW33                  ; je to kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispW321                 ; je to kurzor
         mov       dx,ss:[bp-18]            ; bˆ‘n  barva textu
DispW321:dec       si                       ; n vrat ukazatele dat
DispW33: cmp       al,ds:[si+bx]            ; je zmˆnˆn‚ slovo LOW ?
         jne       DispW34                  ; slovo je zmˆnˆn‚
         jcxz      DispW332                 ; nen¡ dal¨¡ bajt
         cmp       ah,ds:[si+bx+1]          ; je zmˆnˆn‚ slovo HIGH ?
         jne       DispW34                  ; slovo je zmˆnˆn‚
DispW332:mov       dh,dl                    ; barva bˆ‘n‚ho textu

; ------ zobrazen¡ znaku DEK

DispW34: mov       dl,6                     ; po‡et pozic
         cmp       byte ptr ss:[bp-29],0    ; editov no dekadick‚ pole ?
         jne       DispW35                  ; nen¡ dekadick‚ pole
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispW350                 ; je to kurzor
         dec       si
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispW351                 ; nen¡ to kurzor
         inc       si                       ; n vrat ukazatele SI
DispW350:mov       ah,dh                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispW352

DispW351:inc       si                       ; n vrat ukazatele SI
DispW35: add       di,2*6                   ; zv˜¨en¡ pozice
         call      DekWord                  ; dek¢dov n¡ slova WORD
DispW352:pop       dx

; ------ oddˆlovac¡ mezera

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; mezera
         stosw
         stosw
         stosw

; ------ zv˜¨en¡ ukazatele dat

         jcxz      DispW354                 ; nejsou dal¨¡ data
         inc       si                       ; zv˜¨en¡ ukazatele dat
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

; ------ test, zda jsou ji‘ v¨echny znaky

DispW354:dec       dh                       ; jsou ji‘ v¨echny bajty ?
         jz        DispW39                  ; jsou ji‘ v¨echny znaky
         or        cx,cx                    ; je ji‘ konec dat ?
         jnz       DispW31                  ; jsou je¨tˆ dal¨¡ data

; ------ vymaz n¡ zbytku © dku, je-li konec dat

         mov       al,10                    ; po‡et pozic na bajt
         mul       dh                       ; zbyl˜ po‡et pozic
         xchg      ax,cx                    ; CX <- po‡et pozic k vymaz n¡
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ konec zobrazen¡ © dku DEK

DispW39: pop       si                       ; ukazatel dat
         pop       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ oddˆlova‡

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw


; ====== zobrazen¡ pole ASCII

; ------ p©¡prava barvy podle bloku pro zobrazen¡ dat ASCII

         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispW6                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispW6                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispW6:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ korekce barvy, je-li za‡ tek bloku

         mov       dh,10                    ; ‡¡ta‡ bajt– k zobrazen¡
DispW62: cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispW64                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ znak k zobrazen¡

DispW64: lodsb                              ; znak k zobrazen¡
         mov       dl,al                    ; znak k zobrazen¡
         dec       cx                       ; ‡¡ta‡ zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-22]            ; barva textu
         test      dh,bit0                  ; je lich˜ bajt ?
         jz        DispW643                 ; je lich˜ bajt
         dec       si
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispW642                 ; nen¡ kurzor
         mov       ax,ss:[bp-16]            ; barva kurzoru
DispW642:inc       si
DispW643:cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispW65                  ; nen¡ kurzor
DispW644:mov       ax,ss:[bp-16]            ; barva kurzoru
DispW65: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispW66                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu
DispW66: mov       al,dl                    ; znak k zobrazen¡
         stosw                              ; zobrazen¡ znaku

; ------ test, je-li konec dat

         dec       dh                       ; ‡¡ta‡ dat
         jz        DispW8                   ; nen¡ dal¨¡ bajt
         jcxz      DispW68                  ; konec dat - vymaz n¡ zbytku textu

; ------ korekce barev, je-li konec bloku

         cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispW62                  ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu
         jmp       short DispW62            ; zobrazen¡ dal¨¡ho znaku

; ------ konec dat - vymaz n¡ zbytku textu

DispW68: mov       cl,dh                    ; po‡et zbyl˜ch pozic
         mov       al," "                   ; mezera k vymaz n¡
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ p©¡prava pro dal¨¡ © dek

DispW8:  add       word ptr ss:[bp-4],10    ; zv˜¨en¡ offsetu v objektu
         adc       word ptr ss:[bp-2],0     ; p©enos HIGH
         add       di,4                     ; adresa dal¨¡ho © dku
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       DispW9                   ; jsou ji‘ v¨echny © dky
         jmp       DispW1                   ; zobrazen¡ dal¨¡ho © dku

DispW9:  ret

DispW    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du TEXT
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispT    PROC      NEAR

; ------ p©ednastaven¡ bˆ‘n‚ barvy textu podle bloku

DispT1:  mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         cmp       si,ss:[bp-24]            ; je nad za‡ tkem bloku ?
         jb        DispT2                   ; nen¡ nad za‡ tkem bloku
         cmp       si,ss:[bp-26]            ; je pod koncem bloku ?
         jae       DispT2                   ; nen¡ pod koncem bloku
         mov       ax,ss:[bp-20]            ; barva bloku
DispT2:  mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ p©¡prava k zobrazen¡ © dku

         mov       dh,78                    ; ‡¡ta‡ znak– k zobrazen¡

; ------ korekce barvy podle za‡ tku bloku

DispT3:  jcxz      DispT6                   ; je konec dat
         cmp       si,ss:[bp-24]            ; je za‡ tek bloku ?
         jne       DispT32                  ; nen¡ za‡ tek bloku
         mov       ax,ss:[bp-20]            ; barva bloku
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ znak k zobrazen¡

DispT32: lodsb                              ; znak k zobrazen¡
         mov       dl,al                    ; £schova bajtu k zobrazen¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch dat

; ------ ur‡en¡ barvy znaku

         mov       ax,ss:[bp-16]            ; barva kurzoru
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        DispT42                  ; je to kurzor
         mov       ax,ss:[bp-22]            ; barva textu
DispT42: cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispT43                  ; bajt je zmˆnˆn˜
         mov       ah,al                    ; barva bˆ‘n‚ho textu
DispT43: mov       al,dl                    ; znak k zobrazen¡

; ------ konec © dku CRLF, LFCR, CR nebo LF

         cmp       al,13                    ; je CR ?
         je        DispT44                  ; je znak konce © dku
         cmp       al,10                    ; je LF ?
         jne       DispT46                  ; nen¡ konec © dku
DispT44: jcxz      DispT45                  ; nen¡ dal¨¡ znak
         xor       al,10 XOR 13             ; p rov˜ znak
         cmp       ds:[si],al               ; je druh˜ znak ?
         jne       DispT45                  ; konec © dku jenom CR nebo LF
         inc       si                       ; p©esko‡en¡ znaku CR nebo LF
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispT45                  ; nen¡ to kurzor
         mov       ah,ss:[bp-16]            ; barva kurzoru
DispT45: mov       al," "                   ; n hradn¡ znak mezery
         stosw                              ; zobrazen¡ znaku
         dec       dh                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       short DispT7             ; konec © dku LFCR nebo CRLF

; ------ zobrazen¡ tabel toru

DispT46: cmp       al,9                     ; je to tabel tor ?
         jne       DispT48                  ; nen¡ to tabel tor
         push      cx
         mov       ch,0
         mov       cl,dh                    ; po‡et zbyl˜ch pozic
         inc       cx                       ; korekce
         and       cl,7                     ; po‡et zbyl˜ch pozic
         cmp       cl,dh
         jb        DispT47                  ; po‡et pozic je OK
         mov       cl,dh                    ; omezen¡ po‡tu zbyl˜ch pozic
         dec       cx                       ; korekce
DispT47: mov       al," "                   ; znak mezery
         sub       dh,cl                    ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         rep       stosw                    ; zobrazen¡ tabel toru
         pop       cx

; ------ zobrazen¡ bˆ‘n‚ho znaku (nebo posledn¡ mezery tabel toru)

DispT48: stosw                              ; zobrazen¡ znaku

; ------ korekce barev, je-li konec bloku

DispT49: cmp       si,ss:[bp-26]            ; je konec bloku ?
         jne       DispT5                   ; nen¡ konec bloku
         mov       ax,ss:[bp-18]            ; bˆ‘n  a zv˜raznˆn  barva
         mov       ss:[bp-22],ax            ; pracovn¡ barva textu

; ------ sn¡‘en¡ ‡¡ta‡e znak–

DispT5:  dec       dh                       ; ‡¡ta‡ bajt– k zobrazen¡
         jcxz      DispT7                   ; nen¡ dal¨¡ znak
         jnz       DispT3                   ; nen¡ je¨tˆ cel˜ © dek
         jmp       short DispT8             ; konec © dku

; ------ vymaz n¡ zbytku © dku

DispT6:  mov       al,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       ss:[bp-22],al
DispT7:  push      cx                       ; ‡¡ta‡ zbyl˜ch dat
         mov       ch,0
         mov       cl,dh                    ; po‡et zbyl˜ch znak– na © dku
         mov       ah,ss:[bp-22]            ; barva bˆ‘n‚ho textu
         mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku © dku
         pop       cx

; ------ p©¡prava pro dal¨¡ © dek

DispT8:  add       di,4                     ; adresa ve videopamˆti
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       DispT9                   ; jsou ji‘ v¨echny © dky
         jmp       DispT1                   ; zobrazen¡ dal¨¡ho © dku

DispT9:  ret

DispT    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du adres ©e
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispD    PROC      NEAR

; ====== zobrazen¡ pr zdn‚ho © dku

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

DispD1:  or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       DispD2                   ; jsou dal¨¡ data

         mov       ax,offset DispDC         ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       DispD98                  ; zobrazen¡ dal¨¡ho © dku

DispDC   db        8,12,13,10,8,15,6,0

; ------ zobrazen¡ adresy po‡ tku © dku

DispD2:  mov       ah,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       dx,ss:[bp-2]             ; 1. slovo adresy
         call      DekHexW
         mov       dx,ss:[bp-4]             ; 2. slovo adresy
         call      DekHexW
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw


; ====== jm‚no souboru

; ------ zobrazen¡ jm‚na souboru

         mov       dh,8                     ; 8 znak– jm‚na souboru
         mov       dl," "                   ; n hradn¡ 1. znak jm‚na
         jcxz      DispD3                   ; nen¡ jm‚no
         mov       dl,ds:[si]               ; £schova 1. znaku jm‚na
DispD3:  mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho znaku
         mov       al," "                   ; n hrada, nen¡-li dal¨¡ znak
         jcxz      DispD32                  ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispD31                  ; nen¡ to kurzor
         mov       ah,ss:[bp-16]            ; barva kurzoru
         cmp       al,ds:[si+bx]            ; je shodn˜ znak ?
         je        DispD32                  ; je shodn˜ znak
         mov       ah,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jmp       short DispD32
DispD31: cmp       al,ds:[si+bx]            ; je shodn˜ znak ?
         je        DispD32                  ; je shodn˜ znak
         mov       ah,ss:[bp-17]            ; barva zv˜raznˆn‚ho znaku
DispD32: stosw                              ; ulo‘en¡ znaku
         dec       dh                       ; ‡¡ta‡ d‚lky jm‚na souboru
         jnz       DispD3                   ; dal¨¡ znak jm‚na

; ------ oddˆlova‡ mezi jm‚nem a p©¡ponou

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"?"                   ; ozna‡en¡ nepou‘it‚ polo‘ky
         or        dl,dl                    ; je nepou‘it  polo‘ka ?
         jz        DispD36                  ; nepou‘it  polo‘ka (=0)
         mov       al," "                   ; bˆ‘n  polo‘ka
         cmp       cx,0bh-8                 ; jsou atributy souboru ?
         jbe       DispD36                  ; nejsou atributy souboru
         test      byte ptr ds:[si+0bh-8],DIR+RO+HID+SYS ; jsou atributy ?
         jz        DispD36                  ; nejsou atributy
         mov       al,"þ"                   ; ozna‡en¡ adres ©e
         test      byte ptr ds:[si+0bh-8],DIR ; je to adres © ?
         jnz       DispD36                  ; je to adres ©
         mov       al,"°"                   ; soubor HID nebo SYS
         test      byte ptr ds:[si+0bh-8],HID+SYS ; je soubor HID nebo SYS ?
         jnz       DispD36                  ; je soubor HID nebo SYS
         mov       al,"*"                   ; jinak soubor R/O
DispD36: stosw                              ; oddˆlovac¡ mezera

; ------ zobrazen¡ p©¡pony jm‚na souboru

         mov       dh,3                     ; 3 znaky p©¡pony jm‚na souboru
DispD4:  mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho znaku
         mov       al," "                   ; n hrada, nen¡-li dal¨¡ znak
         jcxz      DispD42                  ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       si,ss:[bp-12]            ; je to kurzor ?
         jne       DispD41                  ; nen¡ to kurzor
         mov       ah,ss:[bp-16]            ; barva kurzoru
         cmp       al,ds:[si+bx]            ; je shodn˜ znak ?
         je        DispD42                  ; je shodn˜ znak
         mov       ah,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jmp       short DispD42
DispD41: cmp       al,ds:[si+bx]            ; je shodn˜ znak ?
         je        DispD42                  ; je shodn˜ znak
         mov       ah,ss:[bp-17]            ; barva zv˜raznˆn‚ho znaku
DispD42: stosw                              ; ulo‘en¡ znaku
         dec       dh                       ; ‡¡ta‡ d‚lky p©¡pony jm‚na souboru
         jnz       DispD4                   ; dal¨¡ znak p©¡pony jm‚na

; ------ oddˆlovac¡ ‡ ra

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw                              ; oddˆlovac¡ ‡ ra


; ====== velikost souboru

; ------ vymaz n¡ pole velikosti, je-li velikost neplatn 

         cmp       cx,1ch-0bh               ; je velikost ?
         ja        DispD51                  ; je velikost
         mov       al,13
         call      DispPCl
         jmp       short DispD59

; ------ stanoven¡ polo‘ky velikosti souboru

DispD51: push      si
         push      bx
         push      di

         add       si,1ch-0bh               ; korekce
         mov       di,ds:[si]               ; velikost LOW
         mov       dx,ds:[si+2]             ; velikost HIGH
         cmp       cx,1ch-0bh+4
         jae       DispD52                  ; dostatek dat

         mov       dh,0
         cmp       cl,1ch-0bh+3
         jae       DispD52                  ; jsou 3 bajty

         mov       dl,0
         cmp       cl,1ch-0bh+2
         jae       DispD52                  ; jsou 2 bajty

         and       di,0ffh                  ; je 1 bajt

; ------ rozli¨en¡, je-li polo‘ka zmˆnˆn 

DispD52: mov       ax,di                    ; velikost LOW
         cmp       al,ds:[si+bx+1]          ; souhlas¡ bajt 1 ?
         mov       ah,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       al,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jne       DispD54                  ; nesouhlas¡
         cmp       cx,1ch-0bh+1
         jbe       DispD53                  ; je jen 1 bajt a ten souhlas¡

         cmp       di,ds:[si+bx+1]          ; souhlas¡ bajty 1 a 2 ?
         jne       DispD54                  ; nesouhlas¡
         cmp       cx,1ch-0bh+2
         jbe       DispD53                  ; jsou 2 bajty a ty souhlas¡

         cmp       dl,ds:[si+bx+3]          ; souhlas¡ bajt 3 ?
         jne       DispD54                  ; nesouhlas¡
         cmp       cx,1ch-0bh+3
         jbe       DispD53                  ; jsou 3 bajty a ty souhlas¡

         cmp       dh,ds:[si+bx+4]          ; souhlas¡ bajt 4 ?
         jne       DispD54                  ; nesouhlas¡

DispD53: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,ss:[bp-16]            ; bˆ‘n˜ kurzor

; ------ rozli¨en¡ barvy, je-li kurzor

DispD54: xchg      ax,bx                    ; BX <- barvy
         xchg      ax,di                    ; AX <- velikost LOW
         pop       di
         inc       si                       ; oprava ukazatele dat
         cmp       si,ss:[bp-12]            ; doln¡ hranice kurzoru
         ja        DispD55                  ; nen¡ kurzor
         add       si,4
         cmp       si,ss:[bp-12]            ; horn¡ hranice kurzoru
         jbe       DispD55                  ; nen¡ kurzor

         mov       ah,bl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD56

DispD55: add       di,2*13
         call      DekDWrd                  ; dek¢dov n¡ dvojslova
DispD56: pop       bx
         pop       si

; ------ oddˆlovac¡ ‡ ra

DispD59: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== datum souboru

; ------ vymaz n¡ pole data, je-li datum neplatn‚

         cmp       cx,18h-0bh               ; je datum ?
         ja        DispD61                  ; je datum
         push      cx
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         mov       cl,10                    ; d‚lka pole
         rep       stosw                    ; vymaz n¡ pole
         pop       cx
         jmp       DispD69

; ------ stanoven¡ data souboru

DispD61: push      si
         add       si,18h-0bh+1
         mov       ax,ds:[si-1]             ; datum souboru
         mov       dx,ds:[si+bx]            ; referen‡n¡ datum souboru
         cmp       cx,18h-0bh+1
         ja        DispD62                  ; je dostate‡n  velikost
         mov       ah,0
         mov       dh,0

; ------ zobrazen¡ dne data souboru

DispD62: push      ax
         push      dx
         and       al,1fh                   ; den data
         and       dl,1fh                   ; referen‡n¡ den data
         cmp       al,dl                    ; je zmˆna dne ?
         mov       dl,ss:[bp-16]            ; bˆ‘n  barva kurzoru
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva polo‘ky
         je        DispD622                 ; den se nezmˆnil
         mov       dl,ss:[bp-15]            ; zv˜raznˆn  barva kurzoru
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva polo‘ky
DispD622:cmp       si,ss:[bp-12]            ; je kurzor ?
         je        DispD624                 ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispD625                 ; nen¡ kurzor
         dec       si
DispD624:cmp       byte ptr ss:[bp-29],0    ; je editov no pole dne ?
         jne       DispD626                 ; nen¡ kurzor
         mov       ah,dl                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD627

DispD625:dec       si
DispD626:mov       dl,2                     ; po‡et pozic
         add       di,2*2
         call      DekByte                  ; zobrazen¡ dne data

; ------ oddˆlovac¡ znak

DispD627:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"."
         stosw
         pop       dx
         pop       ax


; ------ zobrazen¡ mˆs¡ce data souboru

DispD63: push      ax
         push      dx
         and       ax,bit8+bit7+bit6+bit5
         and       dx,bit8+bit7+bit6+bit5
         cmp       ax,dx                    ; je zmˆna mˆs¡ce ?
         mov       dl,ss:[bp-16]            ; bˆ‘n  barva kurzoru
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva polo‘ky
         je        DispD632                 ; mˆs¡c se nezmˆnil
         mov       dl,ss:[bp-15]            ; zv˜raznˆn  barva kurzoru
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva polo‘ky
DispD632:shr       ax,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; AL <- mˆs¡c
         cmp       si,ss:[bp-12]            ; je kurzor ?
         je        DispD634                 ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispD635                 ; nen¡ kurzor
         dec       si
DispD634:cmp       byte ptr ss:[bp-29],1    ; je editov no pole mˆs¡ce ?
         jne       DispD636                 ; nen¡ kurzor
         mov       ah,dl                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD637

DispD635:dec       si
DispD636:mov       dl,2                     ; po‡et pozic
         add       di,2*2
         call      DekByt0                  ; zobrazen¡ mˆs¡ce data (s nulami)

; ------ oddˆlovac¡ znak

DispD637:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"."
         stosw
         pop       dx
         pop       ax


; ------ zobrazen¡ roku data souboru

DispD64:
         mov       al,ah
         mov       dl,dh
         shr       al,1
         shr       dl,1
         cmp       al,dl                    ; je zmˆna roku ?
         mov       dl,ss:[bp-16]            ; bˆ‘n  barva kurzoru
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva polo‘ky
         je        DispD642                 ; rok se nezmˆnil
         mov       dl,ss:[bp-15]            ; zv˜raznˆn  barva kurzoru
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva polo‘ky
DispD642:cmp       si,ss:[bp-12]            ; je kurzor ?
         je        DispD644                 ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispD645                 ; nen¡ kurzor
         dec       si
DispD644:cmp       byte ptr ss:[bp-29],2    ; je editov no pole roku ?
         jne       DispD646                 ; nen¡ kurzor
         mov       ah,dl                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD68

DispD645:dec       si
DispD646:mov       ah,0
         add       ax,1980
         mov       dl,4                     ; po‡et pozic
         add       di,4*2
         call      DekWrd                   ; dek¢dov n¡ slova bez te‡ky

; ------ oddˆlovac¡ ‡ ra

DispD68: pop       si
DispD69: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡as souboru

; ------ vymaz n¡ pole ‡asu, je-li ‡as neplatn˜

         cmp       cx,16h-0bh               ; je ‡as ?
         ja        DispD71                  ; je ‡as
         push      cx
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         mov       cl,8                     ; d‚lka pole
         rep       stosw                    ; vymaz n¡ pole
         pop       cx
         jmp       DispD79

; ------ stanoven¡ ‡asu souboru

DispD71: push      si
         add       si,16h-0bh+1
         mov       ax,ds:[si-1]             ; ‡as souboru
         mov       dx,ds:[si+bx]            ; referen‡n¡ ‡as souboru
         cmp       cx,16h-0bh+1
         ja        DispD72                  ; je dostate‡n  velikost
         mov       ah,0
         mov       dh,0

; ------ zobrazen¡ hodiny ‡asu souboru

DispD72: push      ax
         push      dx
         mov       al,ah
         mov       dl,dh
         shr       al,1
         shr       al,1
         shr       al,1
         shr       dl,1
         shr       dl,1
         shr       dl,1
         cmp       al,dl                    ; je zmˆna hodiny ?
         mov       dl,ss:[bp-16]            ; bˆ‘n  barva kurzoru
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva polo‘ky
         je        DispD722                 ; hodina se nezmˆnila
         mov       dl,ss:[bp-15]            ; zv˜raznˆn  barva kurzoru
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva polo‘ky
DispD722:cmp       si,ss:[bp-12]            ; je kurzor ?
         je        DispD724                 ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispD725                 ; nen¡ kurzor
         dec       si
DispD724:cmp       byte ptr ss:[bp-29],0    ; je editov no pole hodiny ?
         jne       DispD726                 ; nen¡ kurzor
         mov       ah,dl                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD727

DispD725:dec       si
DispD726:mov       dl,2                     ; po‡et pozic
         add       di,2*2
         call      DekByte                  ; zobrazen¡ hodiny ‡asu

; ------ oddˆlovac¡ znak

DispD727:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,":"
         stosw
         pop       dx
         pop       ax


; ------ zobrazen¡ minuty ‡asu souboru

DispD73: push      ax
         push      dx
         and       ax,7e0h
         and       dx,7e0h
         cmp       ax,dx                    ; je zmˆna minuty ?
         mov       dl,ss:[bp-16]            ; bˆ‘n  barva kurzoru
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva polo‘ky
         je        DispD732                 ; minuta se nezmˆnila
         mov       dl,ss:[bp-15]            ; zv˜raznˆn  barva kurzoru
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva polo‘ky
DispD732:shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         cmp       si,ss:[bp-12]            ; je kurzor ?
         je        DispD734                 ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispD735                 ; nen¡ kurzor
         dec       si
DispD734:cmp       byte ptr ss:[bp-29],1    ; je editov no pole minuty ?
         jne       DispD736                 ; nen¡ kurzor
         mov       ah,dl                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD737

DispD735:dec       si
DispD736:mov       dl,2                     ; po‡et pozic
         add       di,2*2
         call      DekByt0                  ; zobrazen¡ minuty ‡asu (s nulami)

; ------ oddˆlovac¡ znak

DispD737:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,":"
         stosw
         pop       dx
         pop       ax


; ------ zobrazen¡ sekundy ‡asu souboru

DispD74:
         and       al,1fh
         and       dl,1fh
         cmp       al,dl                    ; je zmˆna sekundy ?
         mov       dl,ss:[bp-16]            ; bˆ‘n  barva kurzoru
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva polo‘ky
         je        DispD742                 ; rok se nezmˆnil
         mov       dl,ss:[bp-15]            ; zv˜raznˆn  barva kurzoru
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva polo‘ky
DispD742:shl       al,1                     ; korekce sekundy
         cmp       si,ss:[bp-12]            ; je kurzor ?
         je        DispD744                 ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispD745                 ; nen¡ kurzor
         dec       si
DispD744:cmp       byte ptr ss:[bp-29],2    ; je editov no pole sekundy ?
         jne       DispD746                 ; nen¡ kurzor
         mov       ah,dl                    ; barva textu
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD78

DispD745:dec       si
DispD746:mov       dl,2                     ; po‡et pozic
         add       di,2*2
         call      DekByt0                  ; zobrazen¡ minuty ‡asu (s nulami)

; ------ oddˆlovac¡ ‡ ra

DispD78: pop       si
DispD79: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== zobrazen¡ atribut– souboru

; ------ vymaz n¡ pole atribut–, nejsou-li atributy definov ny

         or        cx,cx                    ; jsou atributy platn‚ ?
         jnz       DispD81                  ; atributy jsou platn‚
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         mov       cl,15                    ; d‚lka pole
         rep       stosw                    ; vymaz n¡ pole
         jmp       short DispD82

; ------ stanoven¡ atribut– souboru

DispD81: push      cx
         mov       dl,ds:[si]               ; atributy souboru
         inc       si
         mov       dh,ds:[si+bx]            ; referen‡n¡ atributy
         xor       dh,dl                    ; p©¡znaky zmˆn
         mov       ch,ss:[bp-29]            ; editovan‚ pole
         inc       ch                       ; p©ednastaven¡

         mov       al,"R"
         call      DispDAt1
         mov       al,"H"
         call      DispDAt
         mov       al,"S"
         call      DispDAt
         mov       al,"V"
         call      DispDAt
         mov       al,"D"
         call      DispDAt
         mov       al,"A"
         call      DispDAt
         mov       al,"X"
         call      DispDAt
         mov       al,"Y"
         call      DispDAt
         dec       si
         pop       cx

DispD82: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw                              ; oddˆlovac¡ ‡ ra


; ====== aloka‡n¡ blok souboru

; ------ vymaz n¡ pole ‡¡sla bloku, je-li aloka‡n¡ blok neplatn˜

         cmp       cx,1ah-0bh               ; je blok ?
         ja        DispD83                  ; je blok
         push      cx
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         mov       cl,6                     ; d‚lka pole
         rep       stosw                    ; vymaz n¡ pole
         pop       cx
         jmp       short DispD9

; ------ stanoven¡ polo‘ky aloka‡n¡ho bloku souboru

DispD83: push      si

         add       si,1ah-0bh               ; korekce ukazatele dat
         mov       ax,ds:[si]               ; aloka‡n¡ blok
         inc       si                       ; korekce
         cmp       cx,1ah-0bh+1
         ja        DispD84                  ; dostatek dat
         mov       ah,0                     ; bajt HIGH je neplatn˜

; ------ rozli¨en¡, je-li polo‘ka zmˆnˆn 

DispD84: mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       dl,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         cmp       al,ds:[si+bx]            ; souhlas¡ bajt 1 ?
         jne       DispD86                  ; nesouhlas¡
         cmp       cx,1ah-0bh+1
         jbe       DispD85
         cmp       ah,ds:[si+bx+1]
         jne       DispD86
DispD85: mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       dl,ss:[bp-16]            ; bˆ‘n˜ kurzor

; ------ rozli¨en¡ barvy, je-li kurzor

DispD86: cmp       si,ss:[bp-12]            ; doln¡ hranice kurzoru
         je        DispD87                  ; je kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; horn¡ hranice kurzoru
         jne       DispD88                  ; nen¡ kurzor

DispD87: mov       ah,dl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispD89

DispD88: mov       dl,6                     ; d‚lka polo‘ky
         add       di,2*6
         call      DekWord                  ; dek¢dov n¡ ‡¡sla bloku
DispD89: pop       si

; ------ zv˜¨en¡ ukazatele

DispD9:  add       si,32-11
         sub       cx,32-11
         jnc       DispD98
         xor       cx,cx

; ------ p©¡prava pro dal¨¡ © dek

DispD98: add       word ptr ss:[bp-4],20h   ; zv˜¨en¡ offsetu v objektu
         adc       word ptr ss:[bp-2],0     ; p©enos HIGH
         add       di,4                     ; adresa ve videopamˆti
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       DispD99                  ; jsou ji‘ v¨echny © dky
         jmp       DispD1

DispD99: ret

DispD    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ atributu AL
; -----------------------------------------------------------------------------

DispDAt  PROC      NEAR

; ------ zobrazen¡ oddˆlovac¡ mezery

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         push      ax
         mov       al," "
         stosw
         pop       ax

; ------ rozli¨en¡, zda je kurzor

DispDAt1:mov       cl,ss:[bp-17]            ; bˆ‘n˜ zv˜raznˆn˜ text
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispDAt2                 ; nen¡ kurzor
         dec       ch                       ; ‡¡ta‡ editovan‚ho pole
         jnz       DispDAt2                 ; nen¡ editovan‚ pole
         mov       ah,ss:[bp-16]            ; bˆ‘n˜ kurzor
         mov       cl,ss:[bp-15]            ; bˆ‘n˜ zv˜raznˆn˜ kurzor

; ------ rozli¨en¡, zda je polo‘ka zmˆnˆn 

DispDAt2:shr       dh,1                     ; p©¡znak zmˆn
         jnc       DispDAt3                 ; polo‘ka nen¡ zmˆnˆn 
         mov       ah,cl                    ; zv˜raznˆn  barva

; ------ zobrazen¡ polo‘ky

DispDAt3:shr       dl,1                     ; atribut
         jc        DispDAt4                 ; je nastaven
         mov       al,"-"                   ; je nulov n
DispDAt4:stosw
         ret

DispDAt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du FAT 12
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-28] (2) - ukazatel ‡¡sla aloka‡n¡ho bloku FAT
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
Disp2F   PROC      NEAR

; ====== vymaz n¡ pr zdn‚ho © dku

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

Disp2F1: or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       Disp2F2                  ; jsou dal¨¡ data

         mov       ax,offset Disp2FC        ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       Disp2F8                  ; zobrazen¡ dal¨¡ho © dku

Disp2FC  db        6,71,0


; ====== zobrazen¡ ‡¡sla po‡ te‡n¡ho aloka‡n¡ho bloku na © dku

Disp2F2: mov       dh,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       dl,6                     ; po‡et pozice
         add       di,6*2                   ; konec bufferu
         mov       ax,ss:[bp-28]            ; ‡¡slo aloka‡n¡ho bloku
         call      DekWord                  ; dek¢dov n¡ ‡¡sla bloku

; ------ oddˆlovac¡ ‡ ra

         mov       ah,ss:[bp-18]
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw


; ====== zobrazen¡ aloka‡n¡ho bloku

         mov       dh,10                    ; po‡et aloka‡n¡ch blok– na © dek
Disp2F3: push      dx

; ------ vymaz n¡ polo‘ky, nejsou-li dal¨¡ data

         or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       Disp2F4                  ; jsou dal¨¡ data
         mov       cl,6
         mov       al," "
         rep       stosw                    ; vymaz n¡ polo‘ky
         jmp       short Disp2F67

; ------ p©¡prava 2 bajt– dat

Disp2F4: mov       ax,ds:[si]               ; datov‚ slovo
         inc       si                       ; zv˜¨en¡ ukazatele dat
         mov       dx,ds:[si+bx]            ; referen‡n¡ slovo
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat
         jnz       Disp2F5                  ; je dal¨¡ bajt
         mov       ah,0
         mov       dh,0

; ------ p©¡prava ‡¡sla aloka‡n¡ho bloku

Disp2F5: test      byte ptr ss:[bp-28],1    ; je lich˜ aloka‡n¡ blok ?
         jz        Disp2F52                 ; je sud˜ aloka‡n¡ blok
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1
Disp2F52:and       ax,0fffh
         and       dx,0fffh

; ------ rozli¨en¡ barvy, je-li polo‘ka zmˆnˆn 

         cmp       ax,dx                    ; je polo‘ka zmˆnˆn  ?
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       dl,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jne       Disp2F6                  ; ‡¡slo zmˆnˆno
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       dl,ss:[bp-16]            ; bˆ‘n˜ kurzor

; ------ rozli¨en¡, je-li kurzor

Disp2F6: cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        Disp2F62                 ; je to kurzor
         test      byte ptr ss:[bp-28],1    ; je sud˜ blok ?
         jz        Disp2F64                 ; je sud˜ blok - je jen 1 adresa
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       Disp2F63                 ; nen¡ kurzor
         dec       si
Disp2F62:mov       ah,dl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short Disp2F67

; ------ zobrazen¡ ‡¡sla aloka‡n¡ho bloku

Disp2F63:dec       si
Disp2F64:mov       dl,6
         cmp       ax,0ff7h
         jb        Disp2F66                 ; je bˆ‘n‚ ‡¡slo bloku
         push      si
         mov       ah,dh                    ; barva textu
         mov       si,offset BadTxt         ; vadn˜ blok
         je        Disp2F65
         mov       si,offset EofTxt         ; konec
Disp2F65:mov       al,cs:[si]
         inc       si
         stosw
         dec       dl
         jnz       Disp2F65
         pop       si
         jmp       short Disp2F67

Disp2F66:add       di,2*6
         call      DekWord                  ; ‡¡slo aloka‡n¡ho bloku

; ------ zv˜¨en¡ adresy pro lich˜ aloka‡n¡ blok

Disp2F67:test      byte ptr ss:[bp-28],1    ; je lich˜ aloka‡n¡ blok ?
         jz        Disp2F7                  ; je sud˜ aloka‡n¡ blok
         jcxz      Disp2F7                  ; nejsou dal¨¡ data
         inc       si                       ; zv˜¨en¡ ukazatele dat
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat

; ------ p©¡prava pro dal¨¡ aloka‡n¡ blok

Disp2F7: pop       dx
         inc       word ptr ss:[bp-28]      ; zv˜¨en¡ ‡¡sla aloka‡n¡ho bloku
         dec       dh                       ; ‡¡ta‡ polo‘ek
         jz        Disp2F8                  ; jsou ji‘ v¨echny aloka‡n¡ bloky

; ------ oddˆlovac¡ mezera

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         cmp       dh,5
         jne       Disp2F72
         mov       al,"-"
         stosw
         mov       al," "
         stosw
Disp2F72:jmp       Disp2F3

; ------ p©¡prava pro dal¨¡ © dek

Disp2F8: add       di,4
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       Disp2F9                  ; jsou ji‘ v¨echny © dky
         jmp       Disp2F1                  ; dal¨¡ © dek

Disp2F9: ret

Disp2F   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du FAT 16
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-28] (2) - ukazatel ‡¡sla aloka‡n¡ho bloku FAT
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
Disp6F   PROC      NEAR

; ====== vymaz n¡ pr zdn‚ho © dku

; ------ konec dat - zobrazen¡ pr zdn‚ho © dku

Disp6F1: or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       Disp6F2                  ; jsou dal¨¡ data

         mov       ax,offset Disp6FC        ; definice pr zdn‚ho © dku
         call      DekClr                   ; vymaz n¡ pr zdn‚ho © dku
         jmp       Disp6F8                  ; zobrazen¡ dal¨¡ho © dku

Disp6FC  db        6,71,0


; ====== zobrazen¡ ‡¡sla po‡ te‡n¡ho aloka‡n¡ho bloku na © dku

Disp6F2: mov       dh,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       dl,6                     ; po‡et pozice
         add       di,6*2                   ; konec bufferu
         mov       ax,ss:[bp-28]            ; ‡¡slo aloka‡n¡ho bloku
         call      DekWord                  ; dek¢dov n¡ ‡¡sla bloku

; ------ oddˆlovac¡ ‡ ra

         mov       ah,ss:[bp-18]
         mov       al,"³"                   ; oddˆlovac¡ ‡ ra
         stosw


; ====== zobrazen¡ aloka‡n¡ho bloku

         mov       dh,10                    ; po‡et aloka‡n¡ch blok– na © dek
Disp6F3: push      dx

; ------ vymaz n¡ polo‘ky, nejsou-li dal¨¡ data

         or        cx,cx                    ; jsou dal¨¡ data ?
         jnz       Disp6F4                  ; jsou dal¨¡ data
         mov       cl,6
         mov       al," "
         rep       stosw                    ; vymaz n¡ polo‘ky
         jmp       short Disp6F7

; ------ p©¡prava ‡¡sla aloka‡n¡ho bloku

Disp6F4: mov       ax,ds:[si]               ; datov‚ slovo
         inc       si                       ; zv˜¨en¡ ukazatele dat
         mov       dx,ds:[si+bx]            ; referen‡n¡ slovo
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat
         jnz       Disp6F5                  ; je dal¨¡ bajt
         mov       ah,0
         mov       dh,0

; ------ rozli¨en¡ barvy, je-li polo‘ka zmˆnˆn 

Disp6F5: cmp       ax,dx                    ; je polo‘ka zmˆnˆn  ?
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       dl,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jne       Disp6F6                  ; ‡¡slo zmˆnˆno
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       dl,ss:[bp-16]            ; bˆ‘n˜ kurzor

; ------ rozli¨en¡, je-li kurzor

Disp6F6: cmp       si,ss:[bp-12]            ; je to kurzor ?
         je        Disp6F62                 ; je to kurzor
         inc       si
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       Disp6F63                 ; nen¡ kurzor
         dec       si
Disp6F62:mov       ah,dl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short Disp6F67

; ------ zobrazen¡ ‡¡sla aloka‡n¡ho bloku

Disp6F63:dec       si
Disp6F64:mov       dl,6
         cmp       ax,0fff7h
         jb        Disp6F66                 ; je bˆ‘n‚ ‡¡slo bloku
         push      si
         mov       ah,dh                    ; barva textu
         mov       si,offset BadTxt         ; vadn˜ blok
         je        Disp6F65
         mov       si,offset EofTxt         ; konec
Disp6F65:mov       al,cs:[si]
         inc       si
         stosw
         dec       dl
         jnz       Disp6F65
         pop       si
         jmp       short Disp6F67

Disp6F66:add       di,2*6
         call      DekWord                  ; ‡¡slo aloka‡n¡ho bloku

; ------ zv˜¨en¡ adresy

Disp6F67:jcxz      Disp6F7                  ; nejsou dal¨¡ data
         inc       si                       ; zv˜¨en¡ ukazatele dat
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat

; ------ p©¡prava pro dal¨¡ aloka‡n¡ blok

Disp6F7: pop       dx
         inc       word ptr ss:[bp-28]      ; zv˜¨en¡ ‡¡sla aloka‡n¡ho bloku
         dec       dh                       ; ‡¡ta‡ polo‘ek
         jz        Disp6F8                  ; jsou ji‘ v¨echny aloka‡n¡ bloky

; ------ oddˆlovac¡ mezera

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         cmp       dh,5
         jne       Disp6F72
         mov       al,"-"
         stosw
         mov       al," "
         stosw
Disp6F72:jmp       Disp6F3

; ------ p©¡prava pro dal¨¡ © dek

Disp6F8: add       di,4
         cmp       di,24*160                ; jsou ji‘ v¨echny © dky ?
         jae       Disp6F9                  ; jsou ji‘ v¨echny © dky
         jmp       Disp6F1                  ; dal¨¡ © dek

Disp6F9: ret

Disp6F   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du PARTITION
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-28] (2)
;                   SS:[BP-29] (1) editovan‚ pole
; -----------------------------------------------------------------------------
;þ
DispP    PROC      NEAR

; ====== z hlav¡ tabulky

; ------ vymaz n¡ horn¡ch voln˜ch © dk–

         mov       dl,5                     ; po‡et © dk– k vymaz n¡
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva textu
         push      cx
DispP11: mov       cx,78                    ; d‚lka © dku
         mov       al," "
         rep       stosw                    ; vymaz n¡ © dku
         add       di,4
         dec       dl
         jnz       DispP11                  ; dal¨¡ © dek

; ------ zobrazen¡ hlavi‡ky tabulky

         mov       dl,5                     ; po‡et © dk– k zobrazen¡
         push      si
         mov       si,offset PartTxt1
DispP12: mov       cl,78
DispP13: mov       al,cs:[si]
         inc       si
         stosw
         loop      DispP13
         add       di,4
         dec       dl                       ; ‡¡ta‡ © dk–
         jnz       DispP12                  ; dal¨¡ © dek
         pop       si
         pop       cx

; ------ p©¡prava k zobrazen¡ © dk– tabulky

         mov       dl,4                     ; ‡¡ta‡ © dk– k zobrazen¡

; ------ lev˜ okraj tabulky

DispP2:  push      dx
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo syst‚mu

; ------ vymaz n¡ polo‘ky, pokud nen¡ definovan 

         cmp       cx,4                     ; je polo‘ka definovan  ?
         ja        DispP20                  ; polo‘ka je definovan 
         mov       al,6
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP3

; ------ stanoven¡ ‡¡sla syst‚mu a barvy polo‘ky

DispP20: push      si
         add       si,5
         mov       dh,ss:[bp-18]            ; barva bˆ‘n 
         mov       ah,ss:[bp-16]            ; barva kurzoru bˆ‘n 
         mov       al,ds:[si-1]             ; ‡¡slo opera‡n¡ho syst‚mu
         cmp       al,ds:[si+bx]            ; je zmˆna ?
         je        DispP21                  ; polo‘ka nezmˆnˆna
         mov       dh,ss:[bp-17]            ; barva zv˜raznˆn 
         mov       ah,ss:[bp-15]            ; barva kurzoru zv˜raznˆn 

; ------ zobrazen¡ kurzoru

DispP21: cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP22                  ; nen¡ kurzor
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP28

; ------ nalezen¡ syst‚mu v tabulce

DispP22: mov       si,offset TabSys         ; tabulka syst‚m–
         mov       dl,6                     ; po‡et pozic
DispP23: cmp       al,cs:[si]               ; nalezen syst‚m ?
         je        DispP24                  ; syst‚m nalezen OK
         add       si,7                     ; zv˜¨en¡ adresy v tabulce
         cmp       si,offset TabSys0        ; je konec tabulky ?
         jb        DispP23                  ; nen¡ je¨tˆ konec

; ------ zobrazen¡ ‡¡sla nezn m‚ho syst‚mu

         add       di,2*6
         call      DekByte                  ; zobrazen¡ ‡¡sla syst‚mu
         jmp       short DispP28

; ------ zobrazen¡ textu syst‚mu

DispP24: mov       ah,dh                    ; barva textu
DispP25: inc       si
         mov       al,cs:[si]
         stosw
         dec       dl
         jnz       DispP25
DispP28: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP3:  mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== p©¡znak aktivity odd¡lu

; ------ vymaz n¡ p©¡znaku aktivity, pokud nen¡ definovan˜

         or        cx,cx                    ; je p©¡znak aktivity definovan˜ ?
         jnz       DispP31                  ; je definovan˜
         mov       al,3
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP4

; ------ p©¡znak aktivity

DispP31: push      si
         mov       dl,ds:[si]               ; zav dˆc¡ indik tor
         inc       si
         mov       dh,ds:[si+bx]            ; referen‡n¡ indik tor

; ------ barva polo‘ky, pokud byla zmˆnˆna

         mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,ss:[bp-16]            ; bˆ‘n˜ kurzor
         xor       dh,dl                    ; je zmˆna polo‘ky ?
         jns       DispP32                  ; nen¡ zmˆna polo‘ky
         mov       ah,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       al,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ textu polo‘ky

DispP32: mov       si,offset AnoTxt         ; text "Ano"
         or        dl,dl                    ; je odd¡l aktivn¡ ?
         js        DispP33                  ; odd¡l je aktivn¡
         mov       si,offset NeTxt          ; text "Ne"
DispP33: mov       dl,3
DispP34: mov       al,cs:[si]
         inc       si
         stosw
         dec       dl
         jnz       DispP34
         pop       si

; ------ oddˆlovac¡ ‡ ra

DispP4:  mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo hlavy po‡ tku odd¡lu

; ------ vymaz n¡ ‡¡sla hlavy po‡ te‡n¡ho sektoru, pokud nen¡ definov na

         cmp       cx,1
         ja        DispP57
         mov       al,5
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP5c

; ------ p©¡prava ‡¡sla hlavy

DispP57: push      si
         inc       si
         lodsb                              ; ‡¡slo hlavy
         mov       ah,ds:[si+bx]            ; referen‡n¡ ‡¡slo hlavy

; ------ rozli¨en¡, zda byla polo‘ka zmˆnˆna

         cmp       al,ah                    ; byla polo‘ka zmˆnˆna ?
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       ah,ss:[bp-16]            ; bˆ‘n˜ kurzor
         je        DispP58                  ; nen¡ zmˆna polo‘ky
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       ah,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ polo‘ky

DispP58: cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP59                  ; nen¡ kurzor
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP5b
DispP59: mov       dl,5                     ; po‡et pozic
         add       di,2*5
         call      DekByte                  ; zobrazen¡ ‡¡sla
DispP5b: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP5c: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo v lce po‡ tku odd¡lu

; ------ vymaz n¡ ‡¡sla v lce po‡ te‡n¡ho sektoru, pokud nen¡ definov n

         cmp       cx,2
         ja        DispP51
         mov       al,5
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP56

; ------ p©¡prava ‡¡sla v lce

DispP51: push      si
         inc       si
         inc       si                       ; za‡ tek dat + 2
         lodsw                              ; ‡¡slo v lce
         mov       dx,ds:[si+bx-1]          ; referen‡n¡ ‡¡slo v lce
         and       al,0c0h
         and       dl,0c0h                  ; ponech  horn¡ 2 bity
         cmp       cx,3                     ; je pouze vy¨¨¡ bajt ?
         ja        DispP52                  ; jsou oba bajty OK
         mov       ah,0                     ; ni‘¨¡ bajt neplat¡
         mov       dh,0

; ------ rozli¨en¡, zda byla polo‘ka zmˆnˆna

DispP52: cmp       ax,dx                    ; byla polo‘ka zmˆnˆna ?
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       dl,ss:[bp-16]            ; bˆ‘n˜ kurzor
         je        DispP53                  ; nen¡ zmˆna polo‘ky
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       dl,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ polo‘ky

DispP53:
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP54                  ; nen¡ kurzor
         mov       ah,dl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP55
DispP54: mov       dl,5                     ; po‡et pozic
         rol       al,1
         rol       al,1
         xchg      ah,al                    ; oprava po©ad¡ bajt– ‡¡sla
         add       di,2*5
         call      DekWord                  ; zobrazen¡ ‡¡sla
DispP55: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP56: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo sektoru po‡ tku odd¡lu

; ------ vymaz n¡ ‡¡sla sektoru po‡ tku, pokud nen¡ definov n

         cmp       cx,2
         ja        DispP61
         mov       al,6
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP66

; ------ p©¡prava ‡¡sla sektoru

DispP61: push      si
         inc       si
         inc       si                       ; za‡ tek dat
         lodsb                              ; ‡¡slo sektoru
         mov       ah,ds:[si+bx]            ; referen‡n¡ ‡¡slo sektoru
         and       ax,3f3fh                 ; maskov n¡ ‡¡sla sektoru

; ------ rozli¨en¡, zda byla polo‘ka zmˆnˆna

         cmp       al,ah                    ; byla polo‘ka zmˆnˆna ?
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       ah,ss:[bp-16]            ; bˆ‘n˜ kurzor
         je        DispP63                  ; nen¡ zmˆna polo‘ky
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       ah,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ polo‘ky

DispP63:
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP64                  ; nen¡ kurzor
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP65
DispP64: mov       dl,6                     ; po‡et pozic
         add       di,2*6
         call      DekByte                  ; zobrazen¡ ‡¡sla
DispP65: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP66: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo hlavy konce odd¡lu

; ------ vymaz n¡ ‡¡sla hlavy koncov‚ho sektoru, pokud nen¡ definov na

         cmp       cx,5
         ja        DispP77
         mov       al,5
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP7c

; ------ p©¡prava ‡¡sla hlavy

DispP77: push      si
         add       si,5
         lodsb                              ; ‡¡slo hlavy
         mov       ah,ds:[si+bx]            ; referen‡n¡ ‡¡slo hlavy

; ------ rozli¨en¡, zda byla polo‘ka zmˆnˆna

         cmp       al,ah                    ; byla polo‘ka zmˆnˆna ?
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       ah,ss:[bp-16]            ; bˆ‘n˜ kurzor
         je        DispP78                  ; nen¡ zmˆna polo‘ky
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       ah,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ polo‘ky

DispP78:
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP79                  ; nen¡ kurzor
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP7b
DispP79: mov       dl,5                     ; po‡et pozic
         add       di,2*5
         call      DekByte                  ; zobrazen¡ ‡¡sla
DispP7b: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP7c: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo v lce konce odd¡lu

; ------ vymaz n¡ ‡¡sla v lce koncov‚ho sektoru, pokud nen¡ definov n

         cmp       cx,6
         ja        DispP71
         mov       al,5
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP76

; ------ p©¡prava ‡¡sla v lce

DispP71: push      si
         add       si,6                     ; za‡ tek dat
         lodsw                              ; ‡¡slo v lce
         mov       dx,ds:[si+bx-1]          ; referen‡n¡ ‡¡slo v lce
         and       al,0c0h
         and       dl,0c0h                  ; ponech  horn¡ 2 bity
         cmp       cx,7                     ; je pouze vy¨¨¡ bajt ?
         ja        DispP72                  ; jsou oba bajty OK
         mov       ah,0                     ; ni‘¨¡ bajt neplat¡
         mov       dh,0

; ------ rozli¨en¡, zda byla polo‘ka zmˆnˆna

DispP72: cmp       ax,dx                    ; byla polo‘ka zmˆnˆna ?
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       dl,ss:[bp-16]            ; bˆ‘n˜ kurzor
         je        DispP73                  ; nen¡ zmˆna polo‘ky
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       dl,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ polo‘ky

DispP73:
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP74                  ; nen¡ kurzor
         mov       ah,dl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP75
DispP74: mov       dl,5                     ; po‡et pozic
         rol       al,1
         rol       al,1
         xchg      ah,al                    ; oprava po©ad¡ bajt– ‡¡sla
         add       di,2*5
         call      DekWord                  ; zobrazen¡ ‡¡sla
DispP75: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP76: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== ‡¡slo sektoru konce odd¡lu

; ------ vymaz n¡ ‡¡sla sektoru konce, pokud nen¡ definov n

         cmp       cx,6
         ja        DispP81
         mov       al,6
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP86

; ------ p©¡prava ‡¡sla sektoru

DispP81: push      si
         add       si,6                     ; za‡ tek dat
         lodsb                              ; ‡¡slo sektoru
         mov       ah,ds:[si+bx]            ; referen‡n¡ ‡¡slo sektoru
         and       ax,3f3fh                 ; maskov n¡ ‡¡sla sektoru

; ------ rozli¨en¡, zda byla polo‘ka zmˆnˆna

         cmp       al,ah                    ; byla polo‘ka zmˆnˆna ?
         mov       dh,ss:[bp-18]            ; bˆ‘n  barva
         mov       ah,ss:[bp-16]            ; bˆ‘n˜ kurzor
         je        DispP83                  ; nen¡ zmˆna polo‘ky
         mov       dh,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       ah,ss:[bp-15]            ; zv˜raznˆn˜ kurzor

; ------ zobrazen¡ polo‘ky

DispP83:
         cmp       si,ss:[bp-12]            ; je kurzor ?
         jne       DispP84                  ; nen¡ kurzor
         call      DispDB                   ; zobrazen¡ kurzoru
         jmp       short DispP85
DispP84: mov       dl,6                     ; po‡et pozic
         add       di,2*6
         call      DekByte                  ; zobrazen¡ ‡¡sla
DispP85: pop       si

; ------ oddˆlovac¡ ‡ ra

DispP86: mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== relativn¡ sektor po‡ tku odd¡lu

; ------ vymaz n¡ polo‘ky, nen¡-li definovan 

         cmp       cx,8                     ; je po‡ te‡n¡ sektor ?
         ja        DispP871                 ; je po‡ te‡n¡ sektor
         mov       al,13
         call      DispPCl                  ; vymaz n¡ polo‘ky
         jmp       short DispP879

; ------ stanoven¡ polo‘ky po‡ te‡n¡ho sektoru

DispP871:push      si
         push      bx
         push      di

         add       si,8                     ; korekce
         mov       di,ds:[si]               ; sektor LOW
         mov       dx,ds:[si+2]             ; sektor HIGH
         cmp       cx,8+4
         jae       DispP872                 ; dostatek dat

         mov       dh,0
         cmp       cl,8+3
         jae       DispP872                 ; jsou 3 bajty

         mov       dl,0
         cmp       cl,8+2
         jae       DispP872                 ; jsou 2 bajty

         and       di,0ffh                  ; je 1 bajt

; ------ rozli¨en¡, je-li polo‘ka zmˆnˆn 

DispP872:mov       ax,di                    ; velikost LOW
         cmp       al,ds:[si+bx+1]          ; souhlas¡ bajt 1 ?
         mov       ah,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       al,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jne       DispP874                 ; nesouhlas¡
         cmp       cx,8+1
         jbe       DispP873                 ; je jen 1 bajt a ten souhlas¡

         cmp       di,ds:[si+bx+1]          ; souhlas¡ bajty 1 a 2 ?
         jne       DispP874                 ; nesouhlas¡
         cmp       cx,8+2
         jbe       DispP873                 ; jsou 2 bajty a ty souhlas¡

         cmp       dl,ds:[si+bx+3]          ; souhlas¡ bajt 3 ?
         jne       DispP874                 ; nesouhlas¡
         cmp       cx,8+3
         jbe       DispP873                 ; jsou 3 bajty a ty souhlas¡

         cmp       dh,ds:[si+bx+4]          ; souhlas¡ bajt 4 ?
         jne       DispP874                 ; nesouhlas¡

DispP873:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,ss:[bp-16]            ; bˆ‘n˜ kurzor

; ------ rozli¨en¡ barvy, je-li kurzor

DispP874:xchg      ax,bx                    ; BX <- barvy
         xchg      ax,di                    ; AX <- velikost LOW
         pop       di
         inc       si                       ; oprava ukazatele dat
         cmp       si,ss:[bp-12]            ; doln¡ hranice kurzoru
         ja        DispP875                 ; nen¡ kurzor
         add       si,4
         cmp       si,ss:[bp-12]            ; horn¡ hranice kurzoru
         jbe       DispP875                 ; nen¡ kurzor

         mov       ah,bl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispP876

DispP875:
         add       di,2*13
         call      DekDWrd                  ; dek¢dov n¡ dvojslova
DispP876:pop       bx
         pop       si

; ------ oddˆlovac¡ ‡ ra

DispP879:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ====== celkov˜ po‡et sektor– odd¡lu

; ------ vymaz n¡ polo‘ky, nen¡-li definovan 

         cmp       cx,12                    ; je po‡et sektor– ?
         ja        DispP881                 ; je polo‘ka OK
         mov       al,13
         call      DispPCl
         jmp       short DispP889

; ------ stanoven¡ polo‘ky po‡tu sektor–

DispP881:push      si
         push      bx
         push      di

         add       si,12                    ; korekce - po‡ tek polo‘ky
         mov       di,ds:[si]               ; sektor LOW
         mov       dx,ds:[si+2]             ; sektor HIGH
         cmp       cx,12+4
         jae       DispP882                 ; dostatek dat

         mov       dh,0
         cmp       cl,12+3
         jae       DispP882                 ; jsou 3 bajty

         mov       dl,0
         cmp       cl,12+2
         jae       DispP882                 ; jsou 2 bajty

         and       di,0ffh                  ; je 1 bajt

; ------ rozli¨en¡, je-li polo‘ka zmˆnˆn 

DispP882:mov       ax,di                    ; velikost LOW
         cmp       al,ds:[si+bx+1]          ; souhlas¡ bajt 1 ?
         mov       ah,ss:[bp-17]            ; zv˜raznˆn  barva
         mov       al,ss:[bp-15]            ; zv˜raznˆn˜ kurzor
         jne       DispP884                 ; nesouhlas¡
         cmp       cx,12+1
         jbe       DispP883                 ; je jen 1 bajt a ten souhlas¡

         cmp       di,ds:[si+bx+1]          ; souhlas¡ bajty 1 a 2 ?
         jne       DispP884                 ; nesouhlas¡
         cmp       cx,12+2
         jbe       DispP883                 ; jsou 2 bajty a ty souhlas¡

         cmp       dl,ds:[si+bx+3]          ; souhlas¡ bajt 3 ?
         jne       DispP884                 ; nesouhlas¡
         cmp       cx,12+3
         jbe       DispP883                 ; jsou 3 bajty a ty souhlas¡

         cmp       dh,ds:[si+bx+4]          ; souhlas¡ bajt 4 ?
         jne       DispP884                 ; nesouhlas¡

DispP883:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,ss:[bp-16]            ; bˆ‘n˜ kurzor

; ------ rozli¨en¡ barvy, je-li kurzor

DispP884:xchg      ax,bx                    ; BX <- barvy
         xchg      ax,di                    ; AX <- velikost LOW
         pop       di
         inc       si                       ; oprava ukazatele dat
         cmp       si,ss:[bp-12]            ; doln¡ hranice kurzoru
         ja        DispP885                 ; nen¡ kurzor
         add       si,4
         cmp       si,ss:[bp-12]            ; horn¡ hranice kurzoru
         jbe       DispP885                 ; nen¡ kurzor

         mov       ah,bl                    ; barva kurzoru
         call      DispDB                   ; zobrazen¡ editovan‚ polo‘ky
         jmp       short DispP886

DispP885:
         add       di,2*13
         call      DekDWrd                  ; dek¢dov n¡ dvojslova
DispP886:pop       bx
         pop       si

; ------ oddˆlovac¡ ‡ ra

DispP889:mov       ah,ss:[bp-18]            ; bˆ‘n  barva
         mov       al,"³"
         stosw


; ------ p©¡prava pro dal¨¡ © dek

         pop       dx
         add       di,4                     ; p©esko‡en¡ okraj–
         add       si,16
         sub       cx,16
         jnc       DispP96
         add       si,cx
         xor       cx,cx
DispP96: dec       dl
         jz        DispP97
         jmp       DispP2                   ; dal¨¡ © dek

; ------ zobrazen¡ spodn¡ ‡ sti tabulky

DispP97: mov       si,offset PartTxt2
         mov       cx,78
DispP98: mov       al,cs:[si]
         inc       si
         stosw
         loop      DispP98
         add       di,4

; ------ vymaz n¡ spodn¡ch voln˜ch © dk–

         mov       dl,6                     ; po‡et © dk– k vymaz n¡
DispP99: mov       cl,78                    ; d‚lka © dku
         mov       al," "
         rep       stosw                    ; vymaz n¡ © dku
         add       di,4
         dec       dl
         jnz       DispP99                  ; dal¨¡ © dek
         ret

DispP    ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ pole o d‚lce AL (barva AH)
; -----------------------------------------------------------------------------

DispPCl  PROC      NEAR

         push      cx
         mov       ch,0
         mov       cl,al                    ; d‚lka pole
         mov       al," "
         rep       stosw
         pop       cx
         ret

DispPCl  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du ASSEMBLER
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer– - 1 (=[BP-14])
;        CX=‡¡ta‡ zbyl˜ch dat (=[BP-10])
;        DX=adresa kurzoru v bufferu + 1 (=[BP-12])
;        DS:SI=ukazatel dat (=[BP-6])
;        ES:DI=ukl dac¡ adresa do videopamˆti (=[BP-8])
; lok ln¡ promˆnn‚: SS:[BP-2] (2) offset za‡ tku © dku v objektu HIGH
;                   SS:[BP-4] (2) offset za‡ tku © dku v objektu LOW
;                   SS:[BP-6] (2) adresa za‡ tku © dku v bufferu
;                   SS:[BP-8] (2) adresa po‡ tku © dku ve videopamˆti
;                   SS:[BP-10] (2) ‡¡ta‡ zbyl˜ch znak– v bufferu
;                   SS:[BP-12] (2) adresa kurzoru v bufferu + 1
;                   SS:[BP-14] (2) korekce adresy referen‡n¡ho bufferu - 1
;
;                   SS:[BP-15] (1) barva zv˜raznˆn‚ho kurzoru
;                   SS:[BP-16] (1) barva kurzoru
;                   SS:[BP-17] (1) barva zv˜raznˆn‚ho textu
;                   SS:[BP-18] (1) barva bˆ‘n‚ho textu
;                   SS:[BP-19] (1) barva zv˜raznˆn‚ho ozna‡en‚ho bloku
;                   SS:[BP-20] (1) barva bˆ‘n‚ho ozna‡en‚ho bloku
;                   SS:[BP-21] (1) barva zv˜raznˆn‚ho textu ovlivnˆn  blokem
;                   SS:[BP-22] (1) barva bˆ‘n‚ho textu ovlivnˆn  blokem
;
;                   SS:[BP-24] (2) adresa za‡ tku bloku v bufferu (-1=nen¡)
;                   SS:[BP-26] (2) adresa konce bloku v bufferu (-1=nen¡)
;                   SS:[BP-28] (2) ukazatel adresy Assembleru
;                   SS:[BP-29] (1) editovan‚ pole
;                   SS:[BP-30] (1) £schova d‚lky instrukce Assembleru
;                   SS:[BP-32] (2) stavov‚ slovo instrukce Assembleru
; -----------------------------------------------------------------------------
;þ
DispA    PROC      NEAR

DispA1:

; ------ zobrazen¡ adresy po‡ tku © dku a adresy instrukce

DispA3:  mov       di,ss:[bp-8]             ; adresa © dku ve videopamˆti
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       dx,ss:[bp-2]             ; 1. slovo adresy
         call      DekHexW
         mov       al,":"
         stosw                              ; oddˆlova‡ adresy HIGH a LOW
         mov       dx,ss:[bp-4]             ; 2. slovo adresy
         call      DekHexW
         mov       al,179                   ; oddˆlovac¡ ‡ ra
         stosw

         mov       dx,ss:[bp-20]            ; adresa instrukce
         call      DekHexW

         mov       al," "
         stosw


; ------ p©¡prava k zobrazen¡

         mov       si,ss:[bp-6]             ; adresa © dku v bufferu

; ------ stanoven¡ d‚lky instrukce

         mov       bl,ds:[si]               ; prvn¡ bajt instrukce
         mov       bh,0
         mov       bl,cs:[bx+DelkIns]       ; d‚lka instrukce
         cmp       bl,9
         jb        DispA35
         sub       bl,7
         mov       al,ds:[si+1]             ; druh˜ bajt instrukce
         and       al,11000111b
         cmp       al,6
         je        DispA34
         and       al,0c0h
         jz        DispA35
DispA34: cmp       al,0c0h
         je        DispA35
         add       bl,1
         cmp       al,40h
         je        DispA35
         add       bl,1
DispA35: mov       byte ptr ss:[bp-22],bl   ; d‚lka instrukce

; ------ zobrazen¡ bajt– instrukce HEX

         mov       bx,ss:[bp-14]            ; korekce adresy refer. bufferu
         xor       cx,cx
         mov       cl,ss:[bp-22]            ; po‡et bajt– instrukce
DispA4:  lodsb
         mov       dl,al
         mov       ah,ss:[bp-17]            ; barva zv˜raznˆn‚ho textu
         cmp       dl,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispA5                   ; bajt je zmˆnˆn˜
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
DispA5:  call      DekHexB                  ; dek¢dov n¡ bajtu HEX
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         loop      DispA4

; ------ vymaz n¡ zbytku textu po za‡ tek instrukce

         mov       cl,7
         sub       cl,ss:[bp-22]            ; po‡et zbyl˜ch pozic
         mov       al,cl
         shl       al,1
         add       cl,al                    ; po‡et mezer
         mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku © dku po instrukci

; ------ stavov‚ slovo instrukce

         mov       si,ss:[bp-6]             ; adresa © dku v bufferu
         mov       bl,ds:[si]               ; prvn¡ bajt instrukce
         mov       bh,0
         shl       bx,1                     ; offset v tabulce
         mov       bx,word ptr cs:[bx+TabInst] ; stavov‚ slovo instrukce
         cmp       bl,0f0h
         jb        DispA61

         push      si
         mov       al,ds:[si+1]
         mov       si,offset TabInst1
         je        DispA60

         mov       si,offset TabInst2

DispA60: shr       ax,1
         shr       ax,1
         shr       ax,1
         and       ax,7
         add       si,ax
         mov       bl,cs:[si]
         pop       si

DispA61: mov       ss:[bp-24],bx            ; stavov‚ slovo instrukce

; ------ adresa textu instrukce

         mov       bl,ss:[bp-24]
         mov       bh,8
         mov       si,offset TextInst       ; tabulka text– instrukc¡
DispA62: mov       cx,cs:[si]               ; parametry sekce tabulky
         inc       si
         inc       si
         jcxz      DispA65                  ; konec tabulky
         cmp       bl,ch                    ; je ‡¡slo OK ?
         jb        DispA63                  ; text nalezen
         sub       bl,ch                    ; sn¡‘en¡ offsetu v tabulce
         mov       ax,cx
         mul       ah                       ; d‚lka sekce tabulky
         add       si,ax                    ; adresa dal¨¡ sekce tabulky
         jmp       short DispA62

; ------ dek¢dov n¡ textu instrukce

DispA63: mov       ax,cx
         mul       bl                       ; offset textu v tabulce
         add       si,ax                    ; adresa textu v tabulce
         mov       ch,0                     ; CX=d‚lka textu
         sub       bh,cl                    ; zbytek na mezeru
         mov       ah,ss:[bp-18]
DispA64: mov       al,cs:[si]
         inc       si
         stosw
         loop      DispA64

; ------ dek¢dov n¡ mezery

DispA65: mov       cl,bh
         mov       ch,0
         mov       ah,ss:[bp-18]
         mov       al," "
         rep       stosw

; ------ dek¢dov n¡ parametru instrukce

         mov       ah,ss:[bp-18]
         mov       si,ss:[bp-6]             ; adresa © dku v bufferu
         mov       bl,26
         mov       al,ss:[bp-23]            ; typ parametru
         call      ParDek                   ; dek¢dov n¡ parametru

; ------ dek¢dov n¡ mezery

         mov       cl,bl
         mov       ch,0
         mov       ah,ss:[bp-18]
         mov       al," "
         rep       stosw

         mov       al,179
         stosw

; ------ zobrazen¡ bajt– instrukce ASCII

         mov       bx,ss:[bp-14]            ; korekce adresy refer. bufferu
         xor       cx,cx
         mov       cl,ss:[bp-22]            ; po‡et bajt– instrukce
DispA71: lodsb
         mov       ah,ss:[bp-17]            ; barva zv˜raznˆn‚ho textu
         cmp       al,ds:[si+bx]            ; je zmˆnˆn˜ bajt ?
         jne       DispA72                  ; bajt je zmˆnˆn˜
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
DispA72: stosw
         loop      DispA71

; ------ vymaz n¡ zbytku textu

         mov       cl,7
         sub       cl,ss:[bp-22]            ; po‡et zbyl˜ch pozic
         mov       al," "
         mov       ah,ss:[bp-18]            ; barva bˆ‘n‚ho textu
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ p©¡prava pro dal¨¡ © dek

         xor       ax,ax
         mov       al,ss:[bp-22]            ; d‚lka instrukce
         add       word ptr ss:[bp-4],ax    ; zv˜¨en¡ offsetu v objektu
         adc       word ptr ss:[bp-2],0     ; p©enos HIGH
         add       word ptr ss:[bp-6],ax    ; adresa © dku v bufferu
         add       word ptr ss:[bp-8],160   ; zv˜¨en¡ adresy ve videopamˆti
         add       word ptr ss:[bp-20],ax   ; adresa instrukce
         cmp       word ptr ss:[bp-8],24*160
         jae       DispA9
         jmp       DispA1
DispA9:  ret

DispA    ENDP

; -----------------------------------------------------------------------------
;                      Dek¢dov n¡ parametru instrukce
; -----------------------------------------------------------------------------
; VSTUP: AH=barva k dek¢dov n¡ parametru
;        AL=typ parametru
;        BL=‡¡ta‡ zbyl˜ch pozic na © dku
;        DS:SI=ukazatel instrukce
;        ES:DI=adresa ve videopamˆti
; -----------------------------------------------------------------------------

ParDek   PROC      NEAR

         push      bx
         mov       bl,al
         mov       bh,0
         shl       bx,1
         mov       dx,cs:[bx+ParTab]        ; adresa skoku
         pop       bx
         jmp       dx                       ; skok na obsluhu

ParDek   ENDP

ParTab   label     word                     ; tabulka parametr–
         dw        Par0                     ; 0: nic
         dw        Par1                     ; 1: pamˆŸ, registr 8
         dw        Par2                     ; 2: pamˆŸ, registr 16
         dw        Par3                     ; 3: registr 8, pamˆŸ
         dw        Par4                     ; 4: registr 16, pamˆŸ
         dw        Par5                     ; 5: AL, data 8
         dw        Par6                     ; 6: AX, data 16
         dw        Par7                     ; 7: segment. registr PUSH, POP
         dw        Par8                     ; 8: registr 16 INC, DEC, PUSH, POP
         dw        Par9                     ; 9: adresa kr tk‚ho skoku
         dw        Par10                    ; 10: adresa bl¡zk‚ho skoku
         dw        Par11                    ; 11: AX, registr 16
         dw        Par12                    ; 12: registr 8, data 8
         dw        Par13                    ; 13: registr 16, data 16
         dw        Par14                    ; 14: data 8
         dw        Par15                    ; 15: data 16
         dw        Par16                    ; 16: ‡¡slo ESC
         dw        Par17                    ; 17: pamˆŸ, data 8
         dw        Par18                    ; 18: pamˆŸ, data 16
         dw        Par19                    ; 19: pamˆŸ 8, data 8
         dw        Par20                    ; 20: pamˆŸ 16, data 8
         dw        Par21                    ; 21: pamˆŸ 8, rotace 1
         dw        Par22                    ; 22: pamˆŸ 16, rotace 1
         dw        Par23                    ; 23: pamˆŸ 8, rotace CL
         dw        Par24                    ; 24: pamˆŸ 16, rotace CL
         dw        Par25                    ; 25: pamˆŸ 8, rotace data 8
         dw        Par26                    ; 26: pamˆŸ 16, rotace data 8
         dw        Par27                    ; 27: AL/AX, pamˆŸ
         dw        Par28                    ; 28: pamˆŸ, AL/AX
         dw        Par29                    ; 29: AL/AX, port
         dw        Par30                    ; 30: port, AL/AX
         dw        Par31                    ; 31: AL/AX, DX
         dw        Par32                    ; 32: DX, AL/AX
         dw        Par33                    ; 33: adresa FAR
         dw        Par34                    ; 34: pamˆŸ, segment
         dw        Par35                    ; 35: segment, pamˆŸ

; -----------------------------------------------------------------------------
;        0 - nen¡ parametr
; -----------------------------------------------------------------------------

Par0     PROC      NEAR

         ret

Par0     ENDP

; -----------------------------------------------------------------------------
;        1 - pamˆŸ, registr 8
; -----------------------------------------------------------------------------

Par1     PROC      NEAR

         call      DekBInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka
         call      Dek1Reg0                 ; dek¢dov n¡ registru BAJT
         ret

Par1     ENDP

; -----------------------------------------------------------------------------
;        2 - pamˆŸ, registr 16
; -----------------------------------------------------------------------------

Par2     PROC      NEAR

         call      DekWInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka
         call      Dek2Reg0                 ; dek¢dov n¡ registru SLOVO
         ret

Par2     ENDP

; -----------------------------------------------------------------------------
;        3 - registr 8, pamˆŸ
; -----------------------------------------------------------------------------

Par3     PROC      NEAR

         call      Dek1Reg0                 ; dek¢dov n¡ registru BAJT
         call      DekCar                   ; oddˆlovac¡ ‡ rka
         call      DekBInd0                 ; dek¢dov n¡ indexu
         ret

Par3     ENDP

; -----------------------------------------------------------------------------
;        4 - registr 16, pamˆŸ
; -----------------------------------------------------------------------------

Par4     PROC      NEAR

         call      Dek2Reg0                 ; dek¢dov n¡ registru SLOVO
         call      DekCar                   ; oddˆlovac¡ ‡ rka
         call      DekWInd0                 ; dek¢dov n¡ indexu
         ret

Par4     ENDP

; -----------------------------------------------------------------------------
;        5 - AL, data 8
; -----------------------------------------------------------------------------

Par5     PROC      NEAR

         mov       al,0
         call      Dek1Reg
         call      DekCar
Par14:
         mov       dl,ds:[si+1]
         call      DekHexB
         sub       bl,2
         ret

Par5     ENDP

; -----------------------------------------------------------------------------
;        6 - AX, data 16
; -----------------------------------------------------------------------------

Par6     PROC      NEAR

         mov       al,0
         call      Dek2Reg
         call      DekCar
Par15:
         mov       dx,ds:[si+1]
         call      DekHexW
         sub       bl,4
         ret

Par6     ENDP

; -----------------------------------------------------------------------------
;        7 - segment. registr PUSH, POP
; -----------------------------------------------------------------------------

Par7     PROC      NEAR

         call      Dek4Reg0
         ret

Par7     ENDP

; -----------------------------------------------------------------------------
;        11 - AX, registr 16
; -----------------------------------------------------------------------------

Par11    PROC      NEAR

         mov       al,0
         call      Dek2Reg
         call      DekCar

Par11    ENDP

; -----------------------------------------------------------------------------
;        8 - registr 16 INC, DEC, PUSH, POP
; -----------------------------------------------------------------------------

Par8     PROC      NEAR

         mov       al,ds:[si]
         call      Dek2Reg
         ret

Par8     ENDP

; -----------------------------------------------------------------------------
;        9 - adresa kr tk‚ho skoku
; -----------------------------------------------------------------------------

Par9     PROC      NEAR

         cmp       byte ptr ds:[si],0ebh    ; je JMP SHORT ?
         jne       Par90
         mov       al,3
         call      DekPtr                   ; text "Short ptr"

Par90:   mov       dl,ds:[si+1]             ; offset skoku
         mov       dh,0
         cmp       dl,80h
         jb        Par91
         mov       dh,0ffh
Par91:   add       dx,ss:[bp-20]            ; p©i‡ten¡ adresy instrukce
         inc       dx
         inc       dx
         call      DekHexW
         sub       bl,4
         ret

Par9     ENDP

; -----------------------------------------------------------------------------
;        10 - adresa bl¡zk‚ho skoku
; -----------------------------------------------------------------------------

Par10    PROC      NEAR

         mov       dx,ds:[si+1]
         inc       dx
         jmp       short Par91

Par10    ENDP

; -----------------------------------------------------------------------------
;        12 - registr 8, data 8
; -----------------------------------------------------------------------------

Par12    PROC      NEAR

         mov       al,ds:[si]
         call      Dek1Reg
         call      DekCar
         mov       dl,ds:[si+1]
         call      DekHexB
         sub       bl,2
         ret

Par12    ENDP

; -----------------------------------------------------------------------------
;        13 - registr 16, data 16
; -----------------------------------------------------------------------------

Par13    PROC      NEAR

         mov       al,ds:[si]
         call      Dek2Reg
         call      DekCar
         mov       dx,ds:[si+1]
         call      DekHexW
         sub       bl,4
         ret

Par13    ENDP

; -----------------------------------------------------------------------------
;        16 - ‡¡slo ESC
; -----------------------------------------------------------------------------

Par16    PROC      NEAR

         mov       dl,ds:[si]
         and       dl,7
         call      DekHexB
         sub       bl,2
         ret

Par16    ENDP

; -----------------------------------------------------------------------------
;        17 - pamˆŸ, data 8
; -----------------------------------------------------------------------------

Par17    PROC      NEAR

         mov       al,0                     ; BYTE
         call      DekIndP                  ; PTR pro index
         call      DekBInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka

         call      KorAdrP                  ; korekce adresy

         mov       dl,ds:[si+2]
         call      DekHexB
         sub       bl,2
         ret

Par17    ENDP

; -----------------------------------------------------------------------------
;        18 - pamˆŸ, data 16
; -----------------------------------------------------------------------------

Par18    PROC      NEAR

         mov       al,1                     ; WORD
         call      DekIndP                  ; PTR pro index
         call      DekWInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka

         call      KorAdrP                  ; korekce adresy

         mov       dx,ds:[si+2]
         call      DekHexW
         sub       bl,4
         ret

Par18    ENDP

; -----------------------------------------------------------------------------
;        19 - pamˆŸ 8, data 8
; -----------------------------------------------------------------------------

Par19    PROC      NEAR

         mov       al,0                     ; BYTE
         call      DekIndP                  ; PTR pro index
         call      DekBInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka

         call      KorAdrP                  ; korekce adresy

         mov       dl,ds:[si+2]
         call      KorDLDX
         call      DekHexW
         sub       bl,4
         ret

Par19    ENDP

; -----------------------------------------------------------------------------
;        20 - pamˆŸ 16, data 8
; -----------------------------------------------------------------------------

Par20    PROC      NEAR

         mov       al,1                     ; WORD
         call      DekIndP                  ; PTR pro index
         call      DekWInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka

         call      KorAdrP                  ; korekce adresy

         mov       dl,ds:[si+2]
         call      KorDLDX
         call      DekHexW
         sub       bl,4
         ret

Par20    ENDP

; -----------------------------------------------------------------------------
;        21 - pamˆŸ 8, rotace 1
; -----------------------------------------------------------------------------

Par21    PROC      NEAR

         mov       al,0                     ; BYTE
         call      DekIndP                  ; PTR pro index
         call      DekBInd0                 ; dek¢dov n¡ indexu

Par213:
         call      DekCar                   ; oddˆlovac¡ ‡ rka

         mov       al,"1"
         stosw
         sub       bl,1
         ret

Par21    ENDP

; -----------------------------------------------------------------------------
;        22 - pamˆŸ 16, rotace 1
; -----------------------------------------------------------------------------

Par22    PROC      NEAR

         mov       al,1                     ; WORD
         call      DekIndP                  ; PTR pro index
         call      DekWInd0                 ; dek¢dov n¡ indexu

         jmp       short Par213

Par22    ENDP

; -----------------------------------------------------------------------------
;        23 - pamˆŸ 8, rotace CL
; -----------------------------------------------------------------------------

Par23    PROC      NEAR

         mov       al,0                     ; BYTE
         call      DekIndP                  ; PTR pro index
         call      DekBInd0                 ; dek¢dov n¡ indexu

Par233:  call      DekCar                   ; oddˆlovac¡ ‡ rka
         mov       al,1
         call      Dek1Reg                  ; dek¢dov n¡ textu "CL"
         ret

Par23    ENDP

; -----------------------------------------------------------------------------
;        24 - pamˆŸ 16, rotace CL
; -----------------------------------------------------------------------------

Par24    PROC      NEAR

         mov       al,1                     ; WORD
         call      DekIndP                  ; PTR pro index
         call      DekWInd0                 ; dek¢dov n¡ indexu
         jmp       short Par233

Par24    ENDP

; -----------------------------------------------------------------------------
;        25 - pamˆŸ 8, rotace data 8
; -----------------------------------------------------------------------------

Par25    PROC      NEAR

         mov       al,0                     ; BYTE
         call      DekIndP                  ; PTR pro index
         call      DekBInd0                 ; dek¢dov n¡ indexu

Par253:  call      DekCar                   ; oddˆlovac¡ ‡ rka
         call      KorAdrP
         mov       dl,ds:[si+2]
         call      DekHexB
         sub       bl,2
         ret

Par25    ENDP

; -----------------------------------------------------------------------------
;        26 - pamˆŸ 16, rotace data 8
; -----------------------------------------------------------------------------

Par26    PROC      NEAR

         mov       al,1                     ; WORD
         call      DekIndP                  ; PTR pro index
         call      DekWInd0                 ; dek¢dov n¡ indexu
         jmp       short Par253

Par26    ENDP

; -----------------------------------------------------------------------------
;        27 - AL/AX, pamˆŸ
; -----------------------------------------------------------------------------

Par27    PROC      NEAR

         call      DekALAX                  ; registr AL/AX
         call      DekCar
         call      DekAMem0
         ret

Par27    ENDP

; -----------------------------------------------------------------------------
;        28 - pamˆŸ, AL/AX
; -----------------------------------------------------------------------------

Par28    PROC      NEAR

         call      DekAMem0
         call      DekCar
         call      DekALAX                  ; registr AL/AX
         ret

Par28    ENDP

; -----------------------------------------------------------------------------
;        29 - AL/AX, port
; -----------------------------------------------------------------------------

Par29    PROC      NEAR

         call      DekALAX                  ; AL/AX
         call      DekCar
         mov       al,"["
         stosw
         mov       dl,ds:[si+1]
         call      DekHexB
         mov       al,"]"
         stosw
         sub       bl,4
         ret

Par29    ENDP

; -----------------------------------------------------------------------------
;        30 - port, AL/AX
; -----------------------------------------------------------------------------

Par30    PROC      NEAR

         mov       al,"["
         stosw
         mov       dl,ds:[si+1]
         call      DekHexB
         mov       al,"]"
         stosw
         sub       bl,4
         call      DekCar
         call      DekALAX                  ; AL/AX
         ret

Par30    ENDP

; -----------------------------------------------------------------------------
;        31 - AL/AX, DX
; -----------------------------------------------------------------------------

Par31    PROC      NEAR

         call      DekALAX
         call      DekCar
         mov       al,2
         call      Dek2Reg
         ret

Par31    ENDP

; -----------------------------------------------------------------------------
;        32 - DX, AL/AX
; -----------------------------------------------------------------------------

Par32    PROC      NEAR

         mov       al,2
         call      Dek2Reg
         call      DekCar
         call      DekALAX
         ret

Par32    ENDP

; -----------------------------------------------------------------------------
;        32 - adresa FAR
; -----------------------------------------------------------------------------

Par33    PROC      NEAR

         mov       dx,ds:[si+3]
         call      DekHexW
         mov       al,":"
         stosw
         mov       dx,ds:[si+1]
         call      DekHexW
         sub       bl,9
         ret

Par33    ENDP

; -----------------------------------------------------------------------------
;        34 - pamˆŸ, segment
; -----------------------------------------------------------------------------

Par34    PROC      NEAR

         call      DekWInd0                 ; dek¢dov n¡ indexu
         call      DekCar                   ; oddˆlovac¡ ‡ rka
         mov       al,ds:[si+1]
         shr       al,1
         shr       al,1
         shr       al,1
         call      Dek4Reg                  ; dek¢dov n¡ segmentu
         ret

Par34    ENDP

; -----------------------------------------------------------------------------
;        35 - segment, pamˆŸ
; -----------------------------------------------------------------------------

Par35    PROC      NEAR

         mov       al,ds:[si+1]
         shr       al,1
         shr       al,1
         shr       al,1
         call      Dek4Reg                  ; dek¢dov n¡ segmentu
         call      DekCar                   ; oddˆlovac¡ ‡ rka
         call      DekWInd0                 ; dek¢dov n¡ indexu
         ret

Par35    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ AL nebo AX
; -----------------------------------------------------------------------------

DekALAX  PROC      NEAR

         mov       al,0
         test      byte ptr ds:[si],1
         jz        DekALAX1
         call      Dek2Reg
         ret

DekALAX1:call      Dek1Reg
         ret

DekALAX  ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

KorAdrP  PROC      NEAR

         mov       al,ds:[si+1]
         and       al,11000111b
         cmp       al,6
         je        KorAdrP1
         and       al,0c0h
         jz        KorAdrP2
         cmp       al,0c0h
         je        KorAdrP2
KorAdrP1:inc       si
         cmp       al,40h
         je        KorAdrP2
         inc       si
KorAdrP2:ret

KorAdrP  ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

KorDLDX  PROC      NEAR

         mov       dh,0
         cmp       dl,80h
         jb        KorDLDX2
         mov       dh,0ffh
KorDLDX2:ret

KorDLDX  ENDP


; -----------------------------------------------------------------------------
;        dek¢dov n¡ adresy
; -----------------------------------------------------------------------------

DekAMem0:mov       dx,ds:[si+1]

DekAMem  PROC      NEAR

         mov       al,"["
         stosw
         call      DekHexW
         mov       al,"]"
         stosw
         sub       bl,6
         ret

DekAMem  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ indexu - BYTE
; -----------------------------------------------------------------------------

DekBInd0:mov       al,ds:[si+1]             ; 2. bajt instrukce
         mov       dx,ds:[si+2]             ; 3. a 4. bajt instrukce

DekBInd  PROC      NEAR

; ------ £schova registr–

         push      ax

         and       al,not 38h               ; nulov n¡ nepot©ebn˜ch bit–
         mov       cl,al                    ; £schova instrukce

; ------ operandem je p©¡m˜ registr

         and       al,0c0h
         cmp       al,0c0h
         jne       DekBInd2                 ; nen¡ registr
         mov       al,cl
         call      Dek1Reg                  ; dek¢dov n¡ registru BYTE
         jmp       short DekBInd9

; ------ lev  z vorka

DekBInd2:mov       al,"["
         stosw                              ; lev  z vorka
         sub       bl,1

; ------ nam¡sto registru BP je absolutn¡ adresa

         cmp       cl,6
         je        DekBInd7                 ; absolutn¡ adresa

; ------ dek¢dov n¡ b ze, indexu

         mov       al,cl                    ; b ze, index
         call      DekRInd                  ; dek¢dov n¡ registr– b ze, indexu
         test      cl,0c0h                  ; je offset ?
         jz        DekBInd8                 ; nen¡ offset

; ------ dek¢dov n¡ offsetu

         test      cl,80h                   ; je adresa ?
         jnz       DekBInd6                 ; je adresa

         mov       al,"+"
         test      dl,80h
         jz        DekBInd3
         mov       al,"-"
         neg       dl
DekBInd3:stosw
         call      DekHexB                  ; dek¢dov n¡ offsetu
         sub       bl,3
         jmp       short DekBInd8

; ------ dek¢dov n¡ adresy

DekBInd6:mov       al,"+"
         stosw
         sub       bl,1
DekBInd7:call      DekHexW                  ; dek¢dov n¡ adresy v DX
         sub       bl,4

; ------ prav  z vorka

DekBInd8:mov       al,"]"
         stosw                              ; prav  z vorka
         sub       bl,1                     ; ‡¡ta‡

; ------ n vrat registr–

DekBInd9:pop       ax
         ret

DekBInd  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ indexu - WORD
; -----------------------------------------------------------------------------

DekWInd0:mov       al,ds:[si+1]             ; 2. bajt instrukce
         mov       dx,ds:[si+2]             ; 3. a 4. bajt instrukce

DekWInd  PROC      NEAR

; ------ £schova registr–

         push      ax

         and       al,not 38h               ; nulov n¡ nepot©ebn˜ch bit–
         mov       cl,al                    ; £schova instrukce

; ------ operandem je p©¡m˜ registr

         and       al,0c0h
         cmp       al,0c0h
         jne       DekWInd2                 ; nen¡ registr
         mov       al,cl
         call      Dek2Reg                  ; dek¢dov n¡ registru WORD
         jmp       short DekBInd9

DekWInd2:jmp       DekBInd2

DekWInd  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ registr– b ze, indexu
; -----------------------------------------------------------------------------

DekRInd  PROC      NEAR

         push      cx
         push      bx

         push      ax
         mov       al,cl
         and       al,7
         mov       ah,6
         mul       ah
         mov       bx,ax
         pop       ax

         mov       cl,cs:[bx+TabReg5]       ; d‚lka textu
         push      cx
DekRInd2:inc       bx
         mov       al,cs:[bx+TabReg5]
         stosw
         loop      DekRInd2

         pop       cx

         pop       bx
         sub       bl,cl
         pop       cx
         ret

DekRInd  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ oddˆlovac¡ ‡ rky
; -----------------------------------------------------------------------------

DekCar   PROC      NEAR

         push      ax
         mov       al,","
         stosw
         sub       bl,1
         pop       ax
         ret

DekCar   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ PTR pro index
; -----------------------------------------------------------------------------

DekIndP  PROC      NEAR

         mov       cl,ds:[si+1]
         and       cl,0c0h
         cmp       cl,0c0h
         je        DekIndP8                 ; registry - nen¡ PTR

         call      DekPtr

DekIndP8:ret

DekIndP  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ typu PTR
; -----------------------------------------------------------------------------
; VSTUP: AL=typ PTR, AH=barva, ES:DI=videopamˆŸ, BL=‡¡ta‡ zbyl˜ch pozic
; -----------------------------------------------------------------------------

DekPTR   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si

; ------ adresa textu

         push      ax
         mov       ah,6
         mul       ah
         mov       si,ax
         add       si,offset TabPtr+1
         pop       ax

; ------ dek¢dov n¡ textu

         mov       cl,cs:[si-1]
         sub       bl,cl                    ; sn¡‘en¡ ‡¡ta‡e znak–
         mov       ch,0
DekPtr1: mov       al,cs:[si]
         inc       si
         stosw
         loop      DekPtr1

; ------ dek¢dov n¡ textu "PTR"

         mov       al," "
         stosw
         mov       al,"p"
         stosw
         mov       al,"t"
         stosw
         mov       al,"r"
         stosw
         mov       al," "
         stosw
         sub       bl,5

; ------ n vrat registr–

         pop       si
         pop       cx
         pop       ax
         ret

DekPTR   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ registru (1 bajt)
; -----------------------------------------------------------------------------
; VSTUP: AL=registr, AH=barva, ES:DI=videopamˆŸ, BL=‡¡ta‡ zbyl˜ch pozic
; -----------------------------------------------------------------------------

Dek1Reg0:mov       al,ds:[si+1]             ; 2. bajt instrukce
         shr       al,1
         shr       al,1
         shr       al,1

Dek1Reg  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx

; ------ adresa textu registru

         mov       bl,al
         and       bx,7
         shl       bx,1                     ; offset v tabulce

; ------ dek¢dov n¡ prvn¡ho znaku

         mov       al,cs:[bx+TabReg1]       ; prvn¡ znak
         stosw
         mov       al,cs:[bx+TabReg1+1]     ; druh˜ znak
         stosw

; ------ n vrat registr–

         pop       bx
         pop       ax
         sub       bl,2                     ; sn¡‘en¡ ‡¡ta‡e znak–
         ret

Dek1Reg  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ dvojregistru (1 slovo)
; -----------------------------------------------------------------------------
; VSTUP: AL=registr, AH=barva, ES:DI=videopamˆŸ, BL=‡¡ta‡ zbyl˜ch pozic
; -----------------------------------------------------------------------------

Dek2Reg0:mov       al,ds:[si+1]             ; 2. bajt instrukce
         shr       al,1
         shr       al,1
         shr       al,1

Dek2Reg  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx

; ------ adresa textu registru

         mov       bl,al
         and       bx,7
         shl       bx,1                     ; offset v tabulce

; ------ dek¢dov n¡ prvn¡ho znaku

         mov       al,cs:[bx+TabReg2]       ; prvn¡ znak
         stosw
         mov       al,cs:[bx+TabReg2+1]     ; druh˜ znak
         stosw

; ------ n vrat registr–

         pop       bx
         pop       ax
         sub       bl,2                     ; sn¡‘en¡ ‡¡ta‡e znak–
         ret

Dek2Reg  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ segmentov‚ho registru
; -----------------------------------------------------------------------------
; VSTUP: AL=registr, AH=barva, ES:DI=videopamˆŸ, BL=‡¡ta‡ zbyl˜ch pozic
; -----------------------------------------------------------------------------

Dek4Reg0:mov       al,ds:[si]
         shr       al,1
         shr       al,1
         shr       al,1
         and       al,3

Dek4Reg  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx

; ------ adresa textu registru

         mov       bl,al
         and       bx,7
         shl       bx,1                     ; offset v tabulce

; ------ dek¢dov n¡ prvn¡ho znaku

         mov       al,cs:[bx+TabReg4]       ; prvn¡ znak
         stosw
         mov       al,cs:[bx+TabReg4+1]     ; druh˜ znak
         stosw

; ------ n vrat registr–

         pop       bx
         pop       ax
         sub       bl,2                     ; sn¡‘en¡ ‡¡ta‡e znak–
         ret

Dek4Reg  ENDP










; -----------------------------------------------------------------------------
;        zobrazen¡ objektu v m¢du CMOS
; -----------------------------------------------------------------------------
; VSTUP: BX=korekce adres buffer–
;        CX=‡¡ta‡ zbyl˜ch dat
;        DX=adresa kurzoru v bufferu
;        DS:SI=ukazatel dat
;        ES:DI=ukl dac¡ adresa do videopamˆti
; -----------------------------------------------------------------------------

DispC    PROC      NEAR

         ret

DispC    ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                        Univerz ln¡ procedury
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu v DL bitovˆ
; -----------------------------------------------------------------------------

DekBit   PROC      NEAR

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw

         mov       al,"0"
         shl       dl,1
         adc       al,0
         stosw
         ret

DekBit   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu v DL HEX (barva AH, ni‡¡ AL)
; -----------------------------------------------------------------------------

DekHexB  PROC      NEAR

; ------ zobrazen¡ vy¨¨¡ tetr dy bajtu

         mov       al,dl                    ; bajt k dek¢dov n¡
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; vy¨¨¡ tetr da bajtu
         cmp       al,10
         jae       DekHexB1
         sub       al,7
DekHexB1:add       al,"0"+7
         stosw

; ------ zobrazen¡ ni‘¨¡ tetr dy bajtu

         mov       al,dl                    ; bajt k dek¢dov n¡
         and       al,0fh
         cmp       al,10
         jae       DekHexB2
         sub       al,7
DekHexB2:add       al,"0"+7
         stosw
         ret

DekHexB  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova v DX HEX
; -----------------------------------------------------------------------------

DekHexW  PROC      NEAR

; ------ zobrazen¡ vy¨¨¡ tetr dy vy¨¨¡ho bajtu

         mov       al,dh                    ; bajt k dek¢dov n¡
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; vy¨¨¡ tetr da bajtu
         cmp       al,10
         jae       DekHexW1
         sub       al,7
DekHexW1:add       al,"0"+7
         stosw

; ------ zobrazen¡ ni‘¨¡ tetr dy vy¨¨¡ho bajtu

         mov       al,dh                    ; bajt k dek¢dov n¡
         and       al,0fh
         cmp       al,10
         jae       DekHexW2
         sub       al,7
DekHexW2:add       al,"0"+7
         stosw

; ------ zobrazen¡ vy¨¨¡ tetr dy ni‘¨¡ho bajtu

         mov       al,dl                    ; bajt k dek¢dov n¡
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; vy¨¨¡ tetr da bajtu
         cmp       al,10
         jae       DekHexW3
         sub       al,7
DekHexW3:add       al,"0"+7
         stosw

; ------ zobrazen¡ ni‘¨¡ tetr dy ni‘¨¡ho bajtu

         mov       al,dl                    ; bajt k dek¢dov n¡
         and       al,0fh
         cmp       al,10
         jae       DekHexW4
         sub       al,7
DekHexW4:add       al,"0"+7
         stosw
         ret

DekHexW  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu AL (DH=barva, DL=po‡et pozic, ES:DI=konec)
; -----------------------------------------------------------------------------

DekByte  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      di

; ------ dek¢dov n¡ ‡¡sla AL

         mov       bl,10                    ; dˆlitel
DekByte1:mov       ah,0                     ; AX = ‡¡slo
         div       bl                       ; v˜po‡et ‡¡slice
         add       ah,"0"
         dec       di
         mov       es:[di],dh               ; barva
         dec       di
         mov       es:[di],ah               ; ‡¡slice
         dec       dl
         or        al,al
         jnz       DekByte1

; ------ vymaz n¡ zbytku pole

         or        dl,dl                    ; zbyla nˆjak  pozice ?
         je        DekByte3                 ; nezbyla ‘ dn  pozice
         mov       al," "                   ; mezera k vymaz n¡
DekByte2:dec       di
         mov       es:[di],dh               ; barva
         dec       di
         mov       es:[di],al               ; znak mezery
         dec       dl
         jnz       DekByte2                 ; dal¨¡ znak

; ------ n vrat registr–

DekByte3:pop       di
         pop       bx
         pop       ax
         ret

DekByte  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu AL s nulami (DH=barva, DL=po‡et pozic)
; -----------------------------------------------------------------------------

DekByt0  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      di

; ------ dek¢dov n¡ ‡¡sla AL

         mov       bl,10                    ; dˆlitel
DekByt01:mov       ah,0                     ; AX = ‡¡slo
         div       bl                       ; v˜po‡et ‡¡slice
         add       ah,"0"
         dec       di
         mov       es:[di],dh               ; barva
         dec       di
         mov       es:[di],ah               ; ‡¡slice
         dec       dl
         or        al,al
         jnz       DekByt01                 ; bude dal¨¡ ‡¡slice

; ------ vymaz n¡ zbytku pole

         or        dl,dl
         jz        DekByt03                 ; nen¡ dal¨¡ pozice
         mov       al,"0"
DekByt02:dec       di
         mov       es:[di],dh               ; barva
         dec       di
         mov       es:[di],al
         dec       dl
         jnz       DekByt02

; ------ n vrat registr–

DekByt03:pop       di
         pop       bx
         pop       ax
         ret

DekByt0  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova AX (DH=barva, DL=po‡et pozic, ES:DI=konec buff.)
; -----------------------------------------------------------------------------

DekWord  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ dek¢dov n¡ ‡¡sla

         mov       bl,4                     ; ‡¡ta‡ © du
         mov       cx,dx                    ; CH=barva, CL=po‡et pozic
         mov       si,10                    ; dˆlitel
DekWord1:dec       bl                       ; ‡¡ta‡ © du
         jnz       DekWord5                 ; nen¡ oddˆlova‡ © du
         dec       di
         mov       es:[di],ch               ; barva znaku
         dec       di
         mov       byte ptr es:[di],"."     ; oddˆlovac¡ znak © du
         dec       cl
DekWord5:xor       dx,dx                    ; DX <- 0
         div       si                       ; v˜po‡et ‡¡slice
         add       dl,"0"                   ; nov  ‡¡slice
         dec       di
         mov       es:[di],ch               ; barva
         dec       di
         mov       es:[di],dl               ; ‡¡slice
         dec       cl                       ; ‡¡ta‡ pozic
         or        ax,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DekWord1                 ; nen¡ je¨tˆ = 0, dal¨¡ ‡¡slice

; ------ vymaz n¡ zbytku pole

         cmp       cl,0                     ; zbyla nˆjak  pozice ?
         je        DekWord3                 ; nezbyla ‘ dn  pozice
DekWord2:dec       di
         mov       es:[di],ch               ; barva
         dec       di
         mov       byte ptr es:[di]," "     ; mezera
         dec       cl
         jnz       DekWord2                 ; dal¨¡ znak

; ------ n vrat registr–

DekWord3:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekWord  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova AX bez te‡ky (DH=barva, DL=po‡et pozic)
; -----------------------------------------------------------------------------

DekWrd   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di

         mov       cx,dx                    ; CH=barva, CL=po‡et pozic
         mov       si,10                    ; dˆlitel
DekWrd1: xor       dx,dx
         div       si                       ; v˜po‡et ‡¡slice
         add       dl,"0"
         dec       di
         mov       es:[di],ch               ; barva
         dec       di
         mov       es:[di],dl               ; ‡¡slice
         dec       cl
         or        ax,ax
         jnz       DekWrd1

         cmp       cl,0
         je        DekWrd3
DekWrd2: dec       di
         mov       es:[di],ch
         dec       di
         mov       byte ptr es:[di]," "
         dec       cl
         jnz       DekWrd2

; ------ n vrat registr–

DekWrd3: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekWrd  ENDP


; -----------------------------------------------------------------------------
;        dek¢dov n¡ dvojslova DX:AX 13 pozic (BH=barva, ES:DI=konec buff.)
; -----------------------------------------------------------------------------

DekDWrd  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ dek¢dov n¡ ‡¡sla

         mov       si,13                    ; d‚lka pole
         mov       bp,10                    ; dˆlitel
         mov       bl,4                     ; ‡¡ta‡ © du + 1
DekDWrd1:xchg      ax,cx                    ; CX <- £schova AX
         xchg      ax,dx                    ; AX <- vy¨¨¡ © d
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydˆlen¡ vy¨¨¡ho © du
         xchg      ax,cx                    ; n vrat AX, CX <- £schova pod¡lu
         div       bp                       ; vydˆlen¡ ni‘¨¡ho © du
         add       dl,"0"                   ; korekce na ‡¡slici ASCII
         mov       dh,bh                    ; barva
         dec       bl                       ; ‡¡ta‡ © du
         jnz       DekDWrd3                 ; nen¡ oddˆlova‡ © du
         mov       bl,"."                   ; oddˆlova‡ © du
         dec       di
         dec       di                       ; ukazatel bufferu
         dec       si                       ; ‡¡ta‡ znak–
         mov       es:[di],bx               ; ulo‘en¡ znaku "."
         mov       bl,3                     ; nov˜ ‡¡ta‡ © du
DekDWrd3:dec       di
         dec       di                       ; ukazatel bufferu
         dec       si                       ; ‡¡ta‡ znak–
         mov       es:[di],dx               ; ulo‘en¡ znaku
         mov       dx,cx                    ; n vrat DX
         or        cx,ax                    ; je ‡¡slo ji‘ 0 ?
         jnz       DekDWrd1                 ; nen¡ je¨tˆ 0

; ------ vymaz n¡ zbytku pole

         or        si,si                    ; je ji‘ cel‚ pole ?
         jz        DekDWrd6                 ; konec pole
         mov       bl," "                   ; znak mezery k vymaz n¡
DekDWrd4:dec       di
         dec       di
         mov       es:[di],bx               ; ulo‘en¡ znaku mezery
         dec       si                       ; ‡¡ta‡ d‚lky pole
         jnz       DekDWrd4                 ; vymaz n¡ dal¨¡ho znaku

; ------ n vrat registr–

DekDWrd6:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekDWrd  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ pr zdn‚ho © dku podle definice AX (CX = 0 !)
; -----------------------------------------------------------------------------

DekClr   PROC      NEAR

; ------ £schova registr–

         push      si

; ------ vymaz n¡ prvn¡ho pole

         xchg      ax,si                    ; SI <- adresa definice
         mov       cl,cs:[si]               ; prvn¡ pole
         inc       si
         mov       ah,ss:[bp-18]            ; bˆ‘n  barva textu
         mov       al," "                   ; mezera
         rep       stosw                    ; vymaz n¡ prvn¡ho pole

; ------ oddˆlovac¡ ‡ ra

DekClr2: mov       cl,cs:[si]
         jcxz      DekClr5                  ; konec definice
         mov       al,"³"
         stosw

; ------ vymaz n¡ pole

         mov       al," "                   ; mezera
         rep       stosw                    ; vymaz n¡ pole
         inc       si
         jmp       short DekClr2            ; dal¨¡ pole

; ------ n vrat registr–

DekClr5: pop       si
         ret

DekClr   ENDP

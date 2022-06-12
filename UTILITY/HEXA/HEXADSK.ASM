
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Obsluha objekt–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        nulov n¡ ukazatel– objektu
; -----------------------------------------------------------------------------

NulUkaz  PROC      NEAR

         push      ax
         push      cx
         push      di
         push      es

         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset UkazBeg
         mov       cx,offset(UkazEnd-UkazBeg)
         cld
         mov       al,0
         rep       stosb                    ; vynulov n¡ ukazatel–

         mov       word ptr ds:[EditAkt0],10 ; aby se na‡etl buffer

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

NulUkaz  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Otev©en¡ objektu k editaci
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        otev©en¡ editovan‚ho objektu (CY=chyba)
; -----------------------------------------------------------------------------

OpenObj  PROC      NEAR

; ------ inicializace ukazatel–

         call      NulUkaz                  ; nulov n¡ ukazatel– objektu
         and       byte ptr ds:[Param2],not bit1+bit2 ; z kaz z pisu, z pis

; ------ otev©en¡ souboru

         mov       al,ds:[EditObj]          ; editovan˜ objekt
         test      al,bit0                  ; je editace souboru ?
         jz        OpenObj2                 ; nen¡ editace souboru
         jmp       OpenObjS                 ; otev©en¡ souboru

; ------ otev©en¡ adres ©e

OpenObj2:test      al,bit1                  ; je editace adres ©e ?
         jz        OpenObj3                 ; nen¡ editace adres ©e
         jmp       OpenObjD                 ; otev©en¡ adres ©e

; ------ otev©en¡ logick‚ho disku

OpenObj3:test      al,bit2                  ; je editace logick‚ho disku ?
         jz        OpenObj4                 ; nen¡ editace logick‚ho disku
         jmp       OpenObjL                 ; otev©en¡ logick‚ho disku

; ------ otev©en¡ fyzick‚ho disku

OpenObj4:test      al,bit3                  ; je editace fyzick‚ho disku ?
         jz        OpenObj5                 ; nen¡ editace fyzick‚ho disku
         jmp       OpenObjF                 ; otev©en¡ fyzick‚ho disku

; ------ otev©en¡ opera‡n¡ pamˆti

OpenObj5:test      al,bit4                  ; je editace opera‡n¡ pamˆti ?
         jz        OpenObj6                 ; nen¡ editace opera‡n¡ pamˆti
         jmp       OpenObjM                 ; otev©en¡ opera‡n¡ pamˆti

; ------ otev©en¡ roz¨¡©en‚ pamˆti

OpenObj6:test      al,bit5                  ; je editace roz¨¡©en‚ pamˆti ?
         jz        OpenObj7                 ; nen¡ editace roz¨¡©en‚ pamˆti
         jmp       OpenObjE                 ; otev©en¡ roz¨¡©en‚ pamˆti

; ------ otev©en¡ pamˆti CMOS

OpenObj7:test      al,bit6                  ; je editace pamˆti CMOS ?
         jz        OpenObj8                 ; nen¡ editace pamˆti CMOS
         jmp       OpenObjC                 ; otev©en¡ pamˆti CMOS


OpenObj8:stc
         ret

OpenObj  ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu Soubor
; -----------------------------------------------------------------------------

OpenObjS PROC      NEAR

; ------ £schova atribut– souboru

         mov       ax,4300h
         mov       dx,offset Soubor         ; jm‚no souboru
         int       21h                      ; poskytnut¡ aribut– souboru
         jc        OpnObjS9                 ; chyba p©¡stupu k souboru
         mov       ds:[SoubAtr],cx          ; £schova atribut– souboru

; ------ otev©en¡ souboru pro ‡ten¡ i z pis

         test      cx,RO                    ; je z kaz z pisu do souboru ?
         jnz       OpnObjS1                 ; je z kaz z pisu do souboru
         mov       ax,3d02h
         int       21h                      ; otev©en¡ pro ‡ten¡ i z pis
         jnc       OpnObjS2                 ; soubor otev©en OK

; ------ pokus o otev©en¡ alespo¤ pro ‡ten¡

OpnObjS1:mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         jc        OpnObjS9                 ; chyba otev©en¡ souboru
         or        byte ptr ds:[Param2],bit1 ; p©¡znak z kazu z pisu
OpnObjS2:mov       ds:[SoubIdnt],ax         ; identifik tor souboru

; ------ £schova data a ‡asu souboru

         mov       bx,ax                    ; identifik tor souboru
         mov       ax,5700h
         int       21h                      ; poskytnut¡ data a ‡asu souboru
         mov       ds:[SoubDate],dx         ; datum souboru
         mov       ds:[SoubTime],cx         ; ‡as souboru

; ------ stanoven¡ velikosti souboru

         xor       cx,cx
         xor       dx,dx                    ; offset od konce
         mov       ax,4202h
         int       21h                      ; vystaven¡ ukazatele na konec soub.
         jnc       OpnObjS3                 ; operace OK
         xor       ax,ax
         xor       dx,dx
OpnObjS3:mov       word ptr ds:[EditMax],ax ; velikost objektu LOW
         mov       word ptr ds:[EditMax+2],dx ; velikost objektu HIGH

; ------ ostatn¡ parametry objektu

         mov       word ptr ds:[ObjBlok],1  ; velikost nejmen¨¡ho bloku = 1 bajt
         clc                                ; p©¡znak operace OK
OpnObjS9:ret

OpenObjS ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu Adres ©
; -----------------------------------------------------------------------------

OpenObjD PROC      NEAR

; ------ otev©en¡ logick‚ho disku

         call      OpenLDsk                 ; otev©en¡ logick‚ho disku
         jc        OpenObD8                 ; chybn‚ parametry disku

; ------ p©id n¡ textu "*.*"

         mov       si,offset All            ; text "*.*"
         call      AddFile                  ; p©id n¡ textu "*.*"

; ------ nastaven¡ adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ prvn¡ aloka‡n¡ blok adres ©e

         mov       dx,offset Soubor         ; jm‚no adres ©e
         mov       ah,4eh
         mov       cx,DIR+HID+SYS+RO+ARC
         int       21h                      ; nalezen¡ ‡ehokoliv
         jc        OpenObD8                 ; chyba souboru
         mov       ax,word ptr ds:[DTA+13h] ; prvn¡ alok. blok pro DOS < 3.2
         cmp       word ptr ds:[VerzeOS],3*HI+20
         jb        OpenObD3
         mov       ax,word ptr ds:[DTA+0fh]
OpenObD3:mov       ds:[AdrClust],ax         ; ‡¡slo prvn¡ho alok. bloku

; ------ velikost

         mov       ax,word ptr ds:[ClusByte]
         mov       word ptr ds:[EditMax],ax
         mov       ax,word ptr ds:[ClusByte+2]
         mov       word ptr ds:[EditMax+2],ax

         clc
OpenObD8:ret

OpenObjD ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu Logick˜ disk
; -----------------------------------------------------------------------------

OpenObjL PROC      NEAR

         call      OpenLDsk                 ; otev©en¡ logick‚ho disku
         jc        OpenObL8                 ; chybn‚ parametry disku

         mov       ax,word ptr ds:[DiskSize] ; celkov  velikost disku LOW
         mov       word ptr ds:[EditMax],ax ; velikost objektu LOW
         mov       ax,word ptr ds:[DiskSize+2] ; celkov  velikost disku HIGH
         mov       word ptr ds:[EditMax+2],ax ; velikost objektu HIGH

OpenObL8:ret

OpenObjL ENDP

; -----------------------------------------------------------------------------
;        p©¡prava parametr– logick‚ho disku
; -----------------------------------------------------------------------------

OpenLDsk PROC      NEAR

; ------ tabulka parametr– disku

         and       byte ptr ds:[Param2],not bit0+bit5 ; zru¨en¡ p©¡znak– FAT16..
         call      GetLParm                 ; poskytnut¡ tabulky parametr– disku
         jnc       OpenLDs1
OpenLDs0:stc                                ; p©¡znak neplatn‚ho disku
         ret                                ; neplatn˜ disk

; ------ z kladn¡ parametry disku

OpenLDs1:mov       ax,es:[si+2]             ; po‡et bajt– na sektor
         cmp       ax,MAXSEKT               ; maxim ln¡ velikost sektoru
         ja        OpenLDs0                 ; sektor p©¡li¨ velk˜
         cmp       ax,16                    ; minim ln¡ velikost sektoru
         jb        OpenLDs0                 ; sektor p©¡li¨ mal˜
         mov       ds:[SektSize],ax         ; po‡et bajt– na sektor
         mov       ds:[ObjBlok],ax          ; po‡et bajt– na sektor
         xor       ax,ax                    ; AX <- 0
         mov       al,es:[si+4]             ; maxim ln¡ ‡¡slo sektoru v bloku
         inc       ax                       ; po‡et sektor– na alok. blok
         mov       ds:[SektClus],ax         ; po‡et sektor– na alok. blok
         mov       ax,es:[si+6]             ; po‡et rezervovan˜ch sektor–
         mov       ds:[RezSekt],ax          ; po‡et rezervovan˜ch sektor–
         mov       al,es:[si+8]             ; po‡et tabulek FAT
         or        al,al                    ; je nˆjak  tabulka FAT ?
         jz        OpenLDs0                 ; chyba - nen¡ tabulka FAT
         mov       ds:[NumFat],al           ; po‡et tabulek FAT
         mov       ax,es:[si+9]             ; po‡et polo‘ek ROOT
         or        ax,ax
         jz        OpenLDs0                 ; nen¡ ‘ dn  polo‘ka ROOT
         mov       ds:[MaxRoot],ax          ; po‡et polo‘ek ROOT
         mov       ax,es:[si+0bh]           ; ‡¡slo prvn¡ho dat. sektoru
         or        ax,ax
         jz        OpenLDs0                 ; chybn‚ ‡¡slo sektoru
         mov       ds:[DatSekt],ax          ; ‡¡slo prvn¡ho dat. sektoru
         mov       ax,es:[si+0dh]           ; ‡¡slo max. alok. bloku dat
         dec       ax                       ; po‡et alok. blok– dat
         jz        OpenLDs0                 ; chybn‚ ‡¡slo
         mov       ds:[NumClust],ax         ; po‡et alok. blok– dat
         mov       ax,es:[si+0fh]           ; po‡et sektor– na FAT
         cmp       word ptr ds:[VerzeOS],400h ; minim ln¡ verze DOS 4.00 ?
         jae       OpenLDs2                 ; je verze DOS 4.00 a vy¨¨¡
         mov       ah,0                     ; vy¨¨¡ bajt neplat¡
         dec       si                       ; korekce ukazatele
OpenLDs2:or        ax,ax
         jz        OpenLDs0                 ; chyba - nen¡ sektor FAT
         mov       ds:[SektFat],ax          ; po‡et sektor– na FAT
         mov       ax,es:[si+11h]           ; prvn¡ sektor ROOT
         or        ax,ax
         jz        OpenLDs0
         mov       ds:[RootSekt],ax         ; po‡ te‡n¡ sektor ROOT

; ------ rozli¨en¡ typu FAT

         mov       ax,ds:[NumClust]         ; po‡et aloka‡n¡ch blok– dat
         cmp       ax,0ff6h                 ; je tabulka FAT 16 ?
         jbe       OpenLDs3                 ; je tabulka FAT 12
         or        byte ptr ds:[Param2],bit0 ; p©¡znak FAT 16

; ------ stanoven¡ celkov‚ho po‡tu sektor–

OpenLDs3:mul       word ptr ds:[SektClus]   ; po‡et sektor– dat celkem
         add       ax,ds:[DatSekt]          ; p©i‡ten¡ sektor– p©ed daty
         adc       dx,0                     ; p©enos
         mov       word ptr ds:[NumDSekt],ax ; po‡et sektor– LOW
         mov       word ptr ds:[NumDSekt+2],dx ; po‡et sektor– HIGH
         jz        OpenLDs4                 ; po‡et sektor– nen¡ vˆt¨¡ ne‘ FFFF
         or        byte ptr ds:[Param2],bit5 ; p©¡znak velk‚ho disku

; ------ celkov  velikost disku

OpenLDs4:mov       bx,dx                    ; £schova po‡tu sektor– HIGH
         mul       word ptr ds:[SektSize]   ; po‡et bajt– celkem - LOW
         mov       word ptr ds:[DiskSize],ax ; velikost disku LOW
         xchg      ax,dx                    ; AX <- bude p©enos do vy¨¨¡ho slova
         xchg      ax,bx                    ; AX <- po‡et sektor– HIGH
         mul       word ptr ds:[SektSize]   ; po‡et bajt– celkem - HIGH
         add       ax,bx                    ; p©enos z ni‘¨¡ho slova
         mov       word ptr ds:[DiskSize+2],ax ; velikost disku HIGH

; ------ po‡et bajt– na aloka‡n¡ blok

         mov       ax,ds:[SektSize]         ; po‡et bajt– na sektor
         mul       word ptr ds:[SektClus]   ; po‡et bajt– na blok
         mov       word ptr ds:[ClusByte],ax ; po‡et bajt– na blok LOW
         mov       word ptr ds:[ClusByte+2],dx ; po‡et bajt– na blok HIGH

         clc

OpenLDs9:
         ret

OpenLDsk ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu Fyzick˜ disk
; -----------------------------------------------------------------------------

OpenObjF PROC      NEAR

         mov       word ptr ds:[EditMax+2],10h ; velikost objektu HIGH
         mov       word ptr ds:[ObjBlok],1  ; velikost nejmen¨¡ho bloku = 1 bajt
         ret

OpenObjF ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu PamˆŸ
; -----------------------------------------------------------------------------

OpenObjM PROC      NEAR

         mov       word ptr ds:[EditMax+2],10h ; velikost objektu HIGH
         mov       word ptr ds:[ObjBlok],1  ; velikost nejmen¨¡ho bloku = 1 bajt
         ret

OpenObjM ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu Roz¨¡©en  pamˆŸ
; -----------------------------------------------------------------------------

OpenObjE PROC      NEAR

         mov       word ptr ds:[EditMax+2],10h ; velikost objektu HIGH
         mov       word ptr ds:[ObjBlok],1  ; velikost nejmen¨¡ho bloku = 1 bajt
         ret

OpenObjE ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ objektu PamˆŸ CMOS
; -----------------------------------------------------------------------------

OpenObjC PROC      NEAR

         mov       word ptr ds:[EditMax],128 ; velikost objektu LOW
         mov       word ptr ds:[ObjBlok],1  ; velikost nejmen¨¡ho bloku = 1 bajt
         ret

OpenObjC ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            €ten¡ z objektu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        ‡ten¡ obsahu bufferu z editovan‚ho objektu (CY=chyba)
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ stanoven¡ velikosti dat k na‡ten¡ z objektu

         mov       cx,8000h                 ; velikost bufferu
         mov       ax,word ptr ds:[EditMax] ; velikost objektu LOW
         mov       dx,word ptr ds:[EditMax+2] ; velikost objektu HIGH
         sub       ax,word ptr ds:[EditBeg] ; ode‡ten¡ po‡ tku bufferu
         sbb       dx,word ptr ds:[EditBeg+2]
         jnz       ReadBf12                 ; konec objektu dostate‡nˆ vzd len
         cmp       ax,cx
         ja        ReadBf12                 ; zb˜v  dost dat
         xchg      ax,cx                    ; CX <- omezen¡ velikosti dat

; ------ stanoven¡ ukazatel– pro operaci ‡ten¡ dat

ReadBf12:mov       es,ds:[BuffSegm]         ; b zov  adresa buffer–
         mov       di,ds:[BuffOff1]         ; edita‡n¡ buffer
         mov       ax,word ptr ds:[EditBeg+2] ; offset za‡ tku dat HIGH
         mov       bx,ds:[ObjBlok]          ; velikost datov‚ho bloku
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; ‡¡slo po‡ te‡n¡ho bloku HIGH
         push      ax                       ; ‡¡slo bloku HIGH
         mov       ax,word ptr ds:[EditBeg] ; offset za‡ tku dat v bufferu LOW
         div       bx                       ; ‡¡slo po‡ te‡n¡ho bloku LOW
         push      ax                       ; ‡¡slo bloku LOW
         xchg      ax,cx                    ; AX <- po‡et bajt– v bufferu
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; v˜po‡et po‡tu blok–
         mov       cx,ax                    ; CX <- po‡et blok– k z pisu
         mul       bx                       ; zkorigovan  velikost dat
         mov       ds:[EditNum],ax          ; opraven  velikost dat v bufferu
         pop       ax                       ; ‡¡slo bloku LOW
         pop       dx                       ; ‡¡slo bloku HIGH

; ------ ‡ten¡ ze souboru

         cld
         test      byte ptr ds:[EditObj],bit0 ; je editace souboru ?
         jz        ReadBuf2                 ; nen¡ editace souboru
         call      ReadObjS                 ; ‡ten¡ ze souboru
         jmp       short ReadBuf9

; ------ ‡ten¡ z adres ©e

ReadBuf2:test      byte ptr ds:[EditObj],bit1 ; je editace adres ©e ?
         jz        ReadBuf3                 ; nen¡ editace adres ©e
         call      ReadObjD                 ; ‡ten¡ z adres ©e
         jmp       short ReadBuf9

; ------ ‡ten¡ z logick‚ho disku

ReadBuf3:test      byte ptr ds:[EditObj],bit2 ; je editace logick‚ho disku ?
         jz        ReadBuf4                 ; nen¡ editace logick‚ho disku
         call      ReadLDsk                 ; ‡ten¡ z logick‚ho disku
         jmp       short ReadBuf9

; ------ ‡ten¡ z fyzick‚ho disku

ReadBuf4:test      byte ptr ds:[EditObj],bit3 ; je editace fyzick‚ho disku ?
         jz        ReadBuf5                 ; nen¡ editace fyzick‚ho disku
         call      ReadObjF                 ; ‡ten¡ z fyzick‚ho disku
         jmp       short ReadBuf9

; ------ ‡ten¡ z opera‡n¡ pamˆti

ReadBuf5:test      byte ptr ds:[EditObj],bit4 ; je editace opera‡n¡ pamˆti ?
         jz        ReadBuf6                 ; nen¡ editace opera‡n¡ pamˆti
         call      ReadObjM                 ; ‡ten¡ z opera‡n¡ pamˆti
         jmp       short ReadBuf9

; ------ ‡ten¡ z roz¨¡©en‚ pamˆti

ReadBuf6:test      byte ptr ds:[EditObj],bit5 ; je editace roz¨¡©en‚ pamˆti ?
         jz        ReadBuf7                 ; nen¡ editace roz¨¡©en‚ pamˆti
         call      ReadObjE                 ; ‡ten¡ z roz¨¡©en‚ pamˆti
         jmp       short ReadBuf9

; ------ ‡ten¡ z pamˆti CMOS

ReadBuf7:;test      byte ptr ds:[EditObj],bit6 ; je editace pamˆti CMOS ?
         ;jz        ReadBuf8                 ; nen¡ editace pamˆti CMOS
         call      ReadObjC                 ; ‡ten¡ z pamˆti CMOS
         ;jmp       short ReadBuf9

;ReadBuf8:stc

; ------ operace OK - kopie dat do referen‡n¡ho bufferu

ReadBuf9:jc        ReadBf99                 ; chyba operace ‡ten¡ dat
         push      ds
         mov       cx,ds:[EditNum]          ; po‡et bajt– v edita‡n¡m bufferu
         mov       si,ds:[BuffOff1]         ; edita‡n¡ buffer
         mov       di,ds:[BuffOff2]         ; referen‡n¡ buffer
         mov       es,ds:[BuffSegm]         ; segment buffer–
         push      es
         pop       ds                       ; DS <- segment buffer–
         shr       cx,1                     ; po‡et slov v bufferu
         rep       movsw                    ; p©esun obsahu bufferu
         adc       cx,cx
         rep       movsb                    ; p©enos lich‚ho bajtu
         pop       ds
                                            ; zde je NC = operace OK

; ------ n vrat registr–

ReadBf99:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

;; -----------------------------------------------------------------------------
;;        ‡ten¡ z editovan‚ho objektu (CY=chyba)
;; -----------------------------------------------------------------------------
;; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;;        CX=po‡et blok– ke ‡ten¡
;;        ES:DI=adresa bufferu k na‡ten¡ dat
;; VSTUP:CY=chyba ‡ten¡ z objektu
;; -----------------------------------------------------------------------------
;
;ReadObj  PROC      NEAR
;
;; ------ £schova registr–
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;
;; ------ ‡ten¡ ze souboru
;
;         cld
;         clc
;         jcxz      ReadObj9                 ; nen¡ nic ke ‡ten¡
;         mov       bl,ds:[EditObj]          ; editovan˜ objekt
;         test      bl,bit0                  ; je editace souboru ?
;         jz        ReadObj2                 ; nen¡ editace souboru
;         call      ReadObjS                 ; ‡ten¡ ze souboru
;         jmp       short ReadObj9
;
;; ------ ‡ten¡ z adres ©e
;
;ReadObj2:test      bl,bit1                  ; je editace adres ©e ?
;         jz        ReadObj3                 ; nen¡ editace adres ©e
;         call      ReadObjD                 ; ‡ten¡ z adres ©e
;         jmp       short ReadObj9
;
;; ------ ‡ten¡ z logick‚ho disku
;
;ReadObj3:test      bl,bit2                  ; je editace logick‚ho disku ?
;         jz        ReadObj4                 ; nen¡ editace logick‚ho disku
;         call      ReadLDsk                 ; ‡ten¡ z logick‚ho disku
;         jmp       short ReadObj9
;
;; ------ ‡ten¡ z fyzick‚ho disku
;
;ReadObj4:test      bl,bit3                  ; je editace fyzick‚ho disku ?
;         jz        ReadObj5                 ; nen¡ editace fyzick‚ho disku
;         call      ReadObjF                 ; ‡ten¡ z fyzick‚ho disku
;         jmp       short ReadObj9
;
;; ------ ‡ten¡ z opera‡n¡ pamˆti
;
;ReadObj5:test      bl,bit4                  ; je editace opera‡n¡ pamˆti ?
;         jz        ReadObj6                 ; nen¡ editace opera‡n¡ pamˆti
;         call      ReadObjM                 ; ‡ten¡ z opera‡n¡ pamˆti
;         jmp       short ReadObj9
;
;; ------ ‡ten¡ z roz¨¡©en‚ pamˆti
;
;ReadObj6:test      bl,bit5                  ; je editace roz¨¡©en‚ pamˆti ?
;         jz        ReadObj7                 ; nen¡ editace roz¨¡©en‚ pamˆti
;         call      ReadObjE                 ; ‡ten¡ z roz¨¡©en‚ pamˆti
;         jmp       short ReadObj9
;
;; ------ ‡ten¡ z pamˆti CMOS
;
;ReadObj7:test      bl,bit6                  ; je editace pamˆti CMOS ?
;         jz        ReadObj8                 ; nen¡ editace pamˆti CMOS
;         call      ReadObjC                 ; ‡ten¡ z pamˆti CMOS
;         jmp       short ReadObj9
;
;ReadObj8:stc
;
;; ------ n vrat registr–
;
;ReadObj9:pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;ReadObj  ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ z objektu Soubor
; -----------------------------------------------------------------------------

ReadObjS PROC      NEAR

; ------ nastaven¡ ukazatele v souboru

         push      cx
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       cx,dx                    ; offset HIGH
         mov       dx,ax                    ; offset LOW
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele v souboru
         pop       cx
         jnc       ReaObjS7                 ; operace OK
         cmp       al,6                     ; neplatn˜ identifik tor ?
         jne       ReaObjS8                 ; chyba vystaven¡ ukazatele

; ------ nov‚ otev©en¡ souboru pro ‡ten¡ i z pis

         test      byte ptr ds:[Param2],bit1 ; je z kaz z pisu do souboru ?
         jnz       ReaObjS4                 ; je z kaz z pisu do souboru
         mov       ax,3d02h
         int       21h                      ; otev©en¡ pro ‡ten¡ i z pis
         jnc       ReaObjS5                 ; soubor otev©en OK

; ------ pokus o otev©en¡ alespo¤ pro ‡ten¡

ReaObjS4:mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         jc        ReaObjS8                 ; chyba otev©en¡ souboru
         or        byte ptr ds:[Param2],bit1 ; p©¡znak z kazu z pisu
ReaObjS5:mov       ds:[SoubIdnt],ax         ; nov˜ identifik tor souboru
         jmp       short ReaObjS8

; ------ na‡ten¡ dat do bufferu

ReaObjS7:push      ds
         mov       dx,di                    ; DX <- offset bufferu
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ah,3fh
         int       21h                      ; ‡ten¡ dat ze souboru
         pop       ds
         jc        ReaObjS9                 ; chyba ‡ten¡
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         je        ReaObjS9                 ; souhlas¡ OK
ReaObjS8:stc                                ; p©¡znak chyby ‡ten¡

ReaObjS9:ret

ReadObjS ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ z objektu Adres ©
; -----------------------------------------------------------------------------

ReadObjD PROC      NEAR

         mov       ax,ds:[AdrClust]

; ------ v˜po‡et ‡¡sla sektoru ke ‡ten¡

         sub       ax,2                     ; korekce ‡¡sla bloku
         jnc       ReadObD2
         mov       ax,ds:[RootSekt]         ; je to ROOT
         xor       dx,dx
         jmp       short ReadObD3
ReadObD2:mul       word ptr ds:[SektClus]   ; relativn¡ ‡¡slo sektoru
         add       ax,ds:[DatSekt]          ; p©i‡ten¡ 1. dat. sektoru
         adc       dx,0                     ; p©enos HIGH

ReadObD3:call      ReadLDsk

         ret

ReadObjD ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ dat z logick‚ho disku
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho sektoru
;        CX=po‡et sektor– ke ‡ten¡
;        ES:DI=adresa bufferu k na‡ten¡ dat
; VSTUP:CY=chyba ‡ten¡ z disku
; -----------------------------------------------------------------------------

ReadLDsk PROC      NEAR

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

; ------ p©¡prava paketu

         mov       bx,offset Paket          ; paket s daty
         mov       word ptr ds:[bx+PaketSec-Paket],ax ; po‡ te‡n¡ sektor LOW
         mov       word ptr ds:[bx+PaketSec+2-Paket],dx ; po‡ te‡n¡ sektor HIGH
         mov       ds:[bx+PaketNum-Paket],cx ; po‡et sektor– ke ‡ten¡
         mov       word ptr ds:[bx+PaketAdr-Paket],di ; adresa bufferu LOW
         mov       word ptr ds:[bx+PaketAdr+2-Paket],es ; adresa bufferu HIGH
         mov       dx,ax                    ; ‡¡slo po‡ te‡n¡ho sektoru
         mov       al,ds:[LDisk]            ; po‘adovan˜ logick˜ disk

; ------ na‡ten¡ dat z disku

         test      byte ptr ds:[Param2],bit5 ; je velk˜ disk > 32 MB ?
         jnz       ReadLDs2                 ; je obsluha pomoc¡ paketu
         mov       bx,di                    ; adresa bufferu
         push      es
         pop       ds                       ; DS <- adresa bufferu
         jmp       short ReadLDs3
ReadLDs2:mov       cx,-1                    ; indikace operace s paketem
ReadLDs3:mov       cs:[ReadLSP],sp          ; £schova ukazatele z sobn¡ku SP
         int       25h                      ; na‡ten¡ dat z disku
         mov       sp,cs:[ReadLSP]          ; n vrat ukazatele z sobn¡ku SP

; ------ n vrat registr–

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

ReadLDsk ENDP

ReadLSP  dw        0                        ; uschovan˜ registr SP

; -----------------------------------------------------------------------------
;        ‡ten¡ z objektu Fyzick˜ disk
; -----------------------------------------------------------------------------

ReadObjF PROC      NEAR


         stc
         ret

ReadObjF ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ z objektu Opera‡n¡ pamˆŸ
; -----------------------------------------------------------------------------

ReadObjM PROC      NEAR

         push      ds
         mov       si,ax                    ; SI <- offset LOW
         and       si,0fh                   ; normalizace offsetu
         mov       cl,4
         shr       ax,cl                    ; p©evod na segment
         ror       dx,cl                    ; p©evod na segment
         add       ax,dx                    ; segment adresy
         mov       ds,ax                    ; segment adresy
         rep       movsb                    ; p©enos dat
         pop       ds
         clc
         ret

ReadObjM ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ z objektu Roz¨¡©en  pamˆŸ
; -----------------------------------------------------------------------------

ReadObjE PROC      NEAR


         stc
         ret

ReadObjE ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ z objektu PamˆŸ CMOS
; -----------------------------------------------------------------------------

ReadObjC PROC      NEAR

         mov       ah,al                    ; po‡ te‡n¡ offset dat
ReadObC1:call      RdCMos                   ; na‡ten¡ bajtu
         stosb                              ; ulo‘en¡ bajtu do bufferu
         inc       ah                       ; zv˜¨en¡ ukazatele dat
         loop      ReadObC1                 ; dal¨¡ bajt
         clc
         ret

ReadObjC ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ bajtu z CMOS (adresa AH -> bajt AL)
; -----------------------------------------------------------------------------

RdCMos   PROC      NEAR

         push      ax
         mov       al,ah                    ; adresa bajtu z CMOS
         out       [70h],al                 ; nastaven¡ adresy pro ‡ten¡
         jmp       short $+2                ; mal  prodleva
         pop       ax
         in        al,[71h]                 ; data na adrese v CMOS
         ret

RdCMos   ENDP

; -----------------------------------------------------------------------------
;        kontroln¡ sou‡et CMOS -> DX
; -----------------------------------------------------------------------------

ChSmCMos PROC      NEAR

         push      ax
         xor       dx,dx                    ; st©ada‡ kontroln¡ho sou‡tu
         mov       ah,10h                   ; po‡ te‡n¡ adresa
ChSmCMs1:call      RdCMos                   ; ‡ten¡ jednoho bajtu z CMOS
         add       dl,al                    ; p©i‡ten¡ bajtu ke st©ada‡i
         adc       dh,0                     ; p©enos HIGH
         inc       ah                       ; zv˜¨en¡ ukazatele dat
         cmp       ah,2eh
         jne       ChSmCMs1
         pop       ax
         ret

ChSmCMos ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Z pis do objektu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        z pis obsahu bufferu do editovan‚ho objektu (CY=chyba)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

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

; ------ stanoven¡ ukazatel– pro operaci z pisu dat

         mov       es,ds:[BuffSegm]         ; b zov  adresa buffer–
         mov       si,ds:[BuffOff1]         ; edita‡n¡ buffer
         mov       ax,word ptr ds:[EditBeg+2] ; offset za‡ tku dat HIGH
         mov       bx,ds:[ObjBlok]          ; velikost datov‚ho bloku
         xor       dx,dx
         div       bx                       ; ‡¡slo po‡ te‡n¡ho bloku HIGH
         push      ax                       ; ‡¡slo bloku HIGH
         mov       ax,word ptr ds:[EditBeg] ; offset za‡ tku dat v bufferu LOW
         div       bx                       ; ‡¡slo po‡ te‡n¡ho bloku LOW
         push      ax                       ; ‡¡slo bloku LOW
         mov       ax,ds:[EditNum]          ; po‡et bajt– v bufferu
         xor       dx,dx
         div       bx                       ; v˜po‡et po‡tu blok–
         xchg      ax,cx                    ; CX <- po‡et blok– k z pisu
         pop       ax                       ; ‡¡slo bloku LOW
         pop       dx                       ; ‡¡slo bloku HIGH

; ------ minimalizace £seku dat pro velikost bloku 1









         cld
         mov       bx,8000h                 ; korekce adres buffer–
         test      byte ptr ds:[Param2],bit1 ; je z kaz z pisu do objektu ?
         jnz       WritBf99                 ; je z kaz z pisu do objektu

; ------ z pis do souboru

         test      byte ptr ds:[EditObj],bit0 ; je editace souboru ?
         jz        WritBuf2                 ; nen¡ editace souboru
         call      WritObjS                 ; z pis do souboru
         jmp       short WritBuf9

; ------ z pis do adres ©e

WritBuf2:test      byte ptr ds:[EditObj],bit1 ; je editace adres ©e ?
         jz        WritBuf3                 ; nen¡ editace adres ©e
         call      WritObjD                 ; z pis do adres ©e
         jmp       short WritBuf9

; ------ z pis na logick˜ disk

WritBuf3:test      byte ptr ds:[EditObj],bit2 ; je editace logick‚ho disku ?
         jz        WritBuf4                 ; nen¡ editace logick‚ho disku
         call      WritLDsk                 ; z pis na logick˜ disk
         jmp       short WritBuf9

; ------ z pis na fyzick˜ disk

WritBuf4:test      byte ptr ds:[EditObj],bit3 ; je editace fyzick‚ho disku ?
         jz        WritBuf5                 ; nen¡ editace fyzick‚ho disku
         call      WritObjF                 ; z pis na fyzick˜ disk
         jmp       short WritBuf9

; ------ z pis do opera‡n¡ pamˆti

WritBuf5:test      byte ptr ds:[EditObj],bit4 ; je editace opera‡n¡ pamˆti ?
         jz        WritBuf6                 ; nen¡ editace opera‡n¡ pamˆti
         call      WritObjM                 ; z pis do opera‡n¡ pamˆti
         jmp       short WritBuf9

; ------ z pis do roz¨¡©en‚ pamˆti

WritBuf6:test      byte ptr ds:[EditObj],bit5 ; je editace roz¨¡©en‚ pamˆti ?
         jz        WritBuf7                 ; nen¡ editace roz¨¡©en‚ pamˆti
         call      WritObjE                 ; z pis do roz¨¡©en‚ pamˆti
         jmp       short WritBuf9

; ------ z pis do pamˆti CMOS

WritBuf7:;test      byte ptr ds:[EditObj],bit6 ; je editace pamˆti CMOS ?
         ;jz        WritBuf8                 ; nen¡ editace pamˆti CMOS
         call      WritObjC                 ; z pis do pamˆti CMOS
         ;jmp       short WritBuf9

;WritBuf8:stc

; ------ operace OK - kopie dat do referen‡n¡ho bufferu

WritBuf9:jc        WritBf99                 ; chyba operace z pisu dat
         mov       cx,ds:[EditNum]          ; po‡et bajt– v edita‡n¡m bufferu
         mov       si,ds:[BuffOff1]         ; edita‡n¡ buffer
         mov       di,ds:[BuffOff2]         ; referen‡n¡ buffer
         mov       es,ds:[BuffSegm]         ; segment buffer–
         push      es
         pop       ds
         shr       cx,1                     ; po‡et slov v bufferu
         rep       movsw                    ; p©esun obsahu bufferu
         adc       cx,cx
         rep       movsb                    ; p©enos lich‚ho bajtu
                                            ; zde je NC = operace OK

; ------ n vrat registr–

WritBf99:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; -----------------------------------------------------------------------------
;        z pis do objektu Soubor
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;        CX=po‡et blok– k z pisu
;        ES:SI=adresa bufferu dat k z pisu
; VSTUP:CY=chyba z pisu do objektu
; -----------------------------------------------------------------------------

WritObjS PROC      NEAR

; ------ nastaven¡ ukazatele v souboru

         push      cx
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         mov       cx,dx                    ; offset HIGH
         mov       dx,ax                    ; offset LOW
         mov       ax,4200h
         int       21h                      ; nastaven¡ ukazatele v souboru
         pop       cx
         jc        WrtObjS9                 ; chyba vystaven¡ ukazatele

; ------ z pis dat do souboru

         push      ds
         mov       dx,si                    ; DX <- offset bufferu
         push      es
         pop       ds                       ; DS <- segment bufferu
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         pop       ds
         jc        WrtObjS9                 ; chyba operace
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         stc                                ; p©¡znak chyby z pisu
         jne       WrtObjS9                 ; nesouhlas¡ - chyba

; ------ nastaven¡ p–vodn¡ho data a ‡asu souboru

         mov       ax,5701h
         mov       dx,ds:[SoubDate]         ; p–vodn¡ datum souboru
         mov       cx,ds:[SoubTime]         ; p–vodn¡ ‡as souboru
         int       21h                      ; nastaven¡ p–vodn¡ho data a ‡asu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ nastaven¡ p–vodn¡ch atribut– souboru

         mov       dx,offset Soubor         ; jm‚no souboru
         mov       cx,ds:[SoubAtr]          ; atributy souboru
         mov       ax,4301h
         int       21h                      ; nastaven¡ atribut– souboru

; ------ nov‚ otev©en¡ souboru pro ‡ten¡ i z pis

         test      byte ptr ds:[Param2],bit1 ; je z kaz z pisu do souboru ?
         jnz       WrtObjS4                 ; je z kaz z pisu do souboru
         mov       ax,3d02h
         int       21h                      ; otev©en¡ pro ‡ten¡ i z pis
         jnc       WrtObjS5                 ; soubor otev©en OK

; ------ pokus o otev©en¡ alespo¤ pro ‡ten¡

WrtObjS4:mov       ax,3d00h
         int       21h                      ; otev©en¡ pro ‡ten¡
         jc        WrtObjS8                 ; chyba otev©en¡ souboru
         or        byte ptr ds:[Param2],bit1 ; p©¡znak z kazu z pisu
WrtObjS5:mov       ds:[SoubIdnt],ax         ; nov˜ identifik tor souboru

WrtObjS8:clc
WrtObjS9:ret

WritObjS ENDP

; -----------------------------------------------------------------------------
;        z pis do objektu Adres ©
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;        CX=po‡et blok– k z pisu
;        ES:SI=adresa bufferu dat k z pisu
; VSTUP:CY=chyba z pisu do objektu
; -----------------------------------------------------------------------------

WritObjD PROC      NEAR

         mov       ax,ds:[AdrClust]

; ------ v˜po‡et ‡¡sla sektoru k z pisu

         sub       ax,2                     ; korekce ‡¡sla bloku
         jnc       WritObD2
         mov       ax,ds:[RootSekt]         ; je to ROOT
         xor       dx,dx
         jmp       short WritObD3
WritObD2:mul       word ptr ds:[SektClus]   ; relativn¡ ‡¡slo sektoru
         add       ax,ds:[DatSekt]          ; p©i‡ten¡ 1. dat. sektoru
         adc       dx,0                     ; p©enos HIGH

WritObD3:;call      WritLDsk
         clc

         ret

WritObjD ENDP

; -----------------------------------------------------------------------------
;        z pis dat na logick˜ disk
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho sektoru
;        CX=po‡et sektor– k z pisu
;        ES:SI=adresa bufferu k z pisu dat
; VSTUP:CY=chyba z pisu na disk
; -----------------------------------------------------------------------------

WritLDsk PROC      NEAR

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

; ------ p©¡prava paketu

         mov       bx,offset Paket          ; paket s daty
         mov       word ptr ds:[bx+PaketSec-Paket],ax ; po‡ te‡n¡ sektor LOW
         mov       word ptr ds:[bx+PaketSec+2-Paket],dx ; po‡ te‡n¡ sektor HIGH
         mov       ds:[bx+PaketNum-Paket],cx ; po‡et sektor– ke ‡ten¡
         mov       word ptr ds:[bx+PaketAdr-Paket],di ; adresa bufferu LOW
         mov       word ptr ds:[bx+PaketAdr+2-Paket],es ; adresa bufferu HIGH
         mov       dx,ax                    ; ‡¡slo po‡ te‡n¡ho sektoru
         mov       al,ds:[LDisk]            ; po‘adovan˜ logick˜ disk

; ------ na‡ten¡ dat z disku

;         test      byte ptr ds:[Param2],bit5 ; je velk˜ disk > 32 MB ?
;         jnz       WritLDs2                 ; je obsluha pomoc¡ paketu
;         mov       bx,si                    ; adresa bufferu
;         push      es
;         pop       ds                       ; DS <- adresa bufferu
;         jmp       short WritLDs3
;WritLDs2:mov       cx,-1                    ; indikace operace s paketem
;WritLDs3:mov       cs:[WritLSP],sp          ; £schova ukazatele z sobn¡ku SP
;         int       25h                      ; na‡ten¡ dat z disku
;         mov       sp,cs:[WritLSP]          ; n vrat ukazatele z sobn¡ku SP
         clc

; ------ n vrat registr–

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

WritLDsk ENDP

WritLSP  dw        0                        ; uschovan˜ registr SP

; -----------------------------------------------------------------------------
;        z pis do objektu Fyzick˜ disk
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;        CX=po‡et blok– k z pisu
;        ES:SI=adresa bufferu dat k z pisu
; VSTUP:CY=chyba z pisu do objektu
; -----------------------------------------------------------------------------

WritObjF PROC      NEAR


         stc
         ret

WritObjF ENDP

; -----------------------------------------------------------------------------
;        z pis do objektu Opera‡n¡ pamˆŸ
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;        CX=po‡et blok– k z pisu
;        ES:SI=adresa bufferu dat k z pisu
; VSTUP:CY=chyba z pisu do objektu
; -----------------------------------------------------------------------------

WritObjM PROC      NEAR

         push      ds
         mov       di,ax                    ; SI <- offset LOW
         and       di,0fh                   ; normalizace offsetu
         mov       cl,4
         shr       ax,cl                    ; p©evod na segment
         ror       dx,cl                    ; p©evod na segment
         add       ax,dx                    ; segment adresy
         mov       ds,ax                    ; segment adresy
;         rep       movsb                    ; p©enos dat
         pop       ds
         clc
         ret

WritObjM ENDP

; -----------------------------------------------------------------------------
;        z pis do objektu Roz¨¡©en  pamˆŸ
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;        CX=po‡et blok– k z pisu
;        ES:SI=adresa bufferu dat k z pisu
; VSTUP:CY=chyba z pisu do objektu
; -----------------------------------------------------------------------------

WritObjE PROC      NEAR


         stc
         ret

WritObjE ENDP

; -----------------------------------------------------------------------------
;        z pis do objektu PamˆŸ CMOS
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo prvn¡ho bloku
;        CX=po‡et blok– k z pisu
;        ES:SI=adresa bufferu dat k z pisu
; VSTUP:CY=chyba z pisu do objektu
; -----------------------------------------------------------------------------

WritObjC PROC      NEAR

         mov       ah,al                    ; po‡ te‡n¡ offset dat
WritObC1:mov       al,es:[si]               ; bajt k z pisu
         inc       si
;         call      WrCMos                   ; z pis do pamˆti CMOS
         inc       ah                       ; zv˜¨en¡ ukazatele dat
         loop      WritObC1                 ; dal¨¡ bajt
         clc
         ret

WritObjC ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu do CMOS (adresa AH, bajt AL)
; -----------------------------------------------------------------------------

WrCMos   PROC      NEAR

         push      ax
         mov       al,ah                    ; adresa bajtu z CMOS
         out       [70h],al                 ; nastaven¡ adresy pro z pis
         jmp       short $+2                ; mal  prodleva
         pop       ax
         out       [71h],al                 ; data na adresu v CMOS
         ret

WrCMos   ENDP

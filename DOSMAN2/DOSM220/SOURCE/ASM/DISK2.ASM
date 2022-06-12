
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                D I S K 2
;        informace o disku, verifikace, mapa disku, zobrazen¡ a editace disku
;
; =============================================================================
;
; Ve©ejn‚ procedury:
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  ASM\DEF.ASM

CodeDisk SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDisk,ds:Data

; *****************************************************************************
;
;                        informace o disku
;
; *****************************************************************************
;þ
DiskDInf PROC      FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

         call      far ptr InitDPar         ; inicializace diskov˜ch informac¡

; ------ zobrazen¡ hl ¨en¡ o na‡¡t n¡ informac¡ o disku

         mov       si,offset DIMnTxtC
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ ozna‡en¡ disku

         mov       al,ds:[AktPath]          ; aktivn¡ disk
         mov       ds:[DIMnLTi1],al         ; aktivn¡ disk
         sub       al,"A"                   ; ‡¡slo disku
         mov       ds:[DIMnLDsk],al         ; £schova ‡¡sla disku

; ------ jm‚no disku

         mov       word ptr ds:[DIMJmenA],offset DIMNeni ; p©ednastaven¡ - nen¡
         push      ds
         pop       es
         mov       di,offset DIMJmeno+1     ; buffer k na‡ten¡ jm‚na
         call      far ptr GetVol           ; na‡ten¡ n vˆ¨t¡ disku
         jcxz      DiskDIn2                 ; nen¡ n vˆ¨t¡ disku
         mov       word ptr ds:[DIMJmenA],offset DIMJmeno ; je n vˆ¨t¡
         add       di,cx                    ; konec n vˆ¨t¡
         cld
         mov       al,0                     ; p©ep¡na‡ barvy
         stosb
         mov       ax,"( "                  ; mezera a z vorka pro datum
         stosw

         mov       si,offset VolDate-FileDate ; datum vytvo©en¡
         mov       dx,ds                    ; DX <- datov˜ segment
         mov       ah,0                     ; barva se neukl d 
         call      far ptr DekA4Dat         ; dek¢dov n¡ data

         cld
         mov       ax,"v "
         stosw                              ; oddˆlova‡ " v "
         stosb

         mov       si,offset VolTime-FileTime ; ‡as vytvo©en¡
         mov       ah,0                     ; barva se neukl d 
         call      far ptr DekATmS          ; dek¢dov n¡ ‡asu

         cld
         mov       al,")"
         stosb                              ; prav  z vorka
         sub       di,offset DIMJmeno+1     ; d‚lka textu
         xchg      ax,di
         mov       ds:[DIMJmeno],al         ; d‚lka textu

; ------ s‚riov‚ ‡¡slo

DiskDIn2:mov       word ptr ds:[DIMSercA],offset DIMNeni ; p©ednastaven¡ - nen¡
         mov       al,ds:[DIMnLDsk]         ; ‡¡slo disku
         call      far ptr GetSerN          ; poskytnut¡ s‚riov‚ho ‡¡sla disku
         jc        DiskDIn3                 ; nen¡ s‚riov‚ ‡¡slo
         mov       word ptr ds:[DIMSercA],offset DIMSerc ; je s‚riov‚ ‡¡slo

         mov       di,offset DIMSerc+1      ; buffer k dek¢dov n¡ ‡¡sla
         mov       bh,0                     ; barva se neukl d 
         xchg      ax,dx                    ; AX <- s‚riov‚ ‡¡slo HIGH
         call      far ptr DekHWord         ; dek¢dov n¡ ‡¡sla HIGH
         inc       di                       ; p©esko‡en¡ oddˆlova‡e "-"
         xchg      ax,cx                    ; AX <- s‚riov‚ ‡¡slo LOW
         call      far ptr DekHWord         ; dek¢dov n¡ ‡¡sla LOW

; ------ na‡ten¡ informac¡ o disku

DiskDIn3:mov       al,ds:[DIMnLDsk]         ; ‡¡slo disku
         call      far ptr GetDInfo         ; poskytnut¡ informac¡ o disku

         push      bx                       ; po‡et voln˜ch aloka‡n¡ch blok–
         push      dx                       ; celkov˜ po‡et aloka‡n¡ch blok–
         push      ax                       ; po‡et sektor– na aloka‡n¡ blok

; ------ velikost sektoru (z CX)

         xchg      ax,cx                    ; AX <- po‡et bajt– na sektor
         mov       ds:[DInfSekt],ax         ; £schova po‡tu bajt– na sektor
         mov       di,offset DIMSekt        ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDIW                  ; dek¢dov n¡ ‡¡sla (slovo) s "B"

; ------ velikost aloka‡n¡ho bloku

         pop       ax                       ; po‡et sektor– na aloka‡n¡ blok
         mov       ds:[DInfSBlk],ax         ; po‡et sektor– na aloka‡n¡ blok
         mul       word ptr ds:[DInfSekt]   ; velikost aloka‡n¡ho bloku
         or        dx,dx                    ; p©ete‡en¡ velikosti bloku ?
         jz        DiskDIn4                 ; nen¡ p©ete‡en¡ velikosti bloku
         mov       ax,-1                    ; omezen¡ velikosti bloku
DiskDIn4:mov       ds:[DInfBlok],ax         ; velikost aloka‡n¡ho bloku
         mov       di,offset DIMBlok        ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDIW                  ; dek¢dov n¡ ‡¡sla (slovo) s "B"

; ------ celkov  kapacita disku

         pop       ax                       ; celkov˜ po‡et aloka‡n¡ch blok–
         mov       ds:[DInfCelk],ax         ; celkov˜ po‡et alok. blok–
         mov       di,offset DIMNBlok       ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDI1                  ; p©¡prava bufferu
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla

         mov       word ptr ds:[DInfRoot],112 ; implicitnˆ ROOT=7*16 pro diskety
         mov       byte ptr ds:[DInfPop],0f0h ; popisova‡ m‚dia pro diskety
         mov       byte ptr ds:[DIMFATT],"2" ; je FAT 12
         cmp       ax,0ff6h                 ; je pot©eba FAT 16 ?
         jb        DiskDIn5                 ; nen¡ pot©eba FAT 16
         mov       byte ptr ds:[DIMFATT],"6" ; je FAT 16
         mov       word ptr ds:[DInfRoot],512 ; implicitnˆ ROOT=32*16 pro disky
         mov       byte ptr ds:[DInfPop],0f8h ; popisova‡ m‚dia pro disky

DiskDIn5:mul       word ptr ds:[DInfBlok]   ; kapacita disku v bajtech

         cmp       word ptr ds:[GetCDMxS+2],0 ; je £daj pro CD disk ?
         je        DiskDI52                 ; nen¡ £daj pro CD disk

         mov       ax,word ptr ds:[GetCDMxS] ; velikost CD disku v bajtech
         mov       dx,word ptr ds:[GetCDMxS+2]

DiskDI52:mov       di,offset DIMKapac       ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDID                  ; dek¢dov n¡ ‡¡sla (dvojslovo) s "B"

; ------ voln  kapacita disku

         pop       ax                       ; po‡et voln˜ch aloka‡n¡ch blok–
         mul       word ptr ds:[DInfBlok]   ; voln  kapacita disku v bajtech
         mov       di,offset DIMVolne       ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDID                  ; dek¢dov n¡ ‡¡sla (dvojslovo) s "B"

; ------ na‡ten¡ syst‚mov˜ch informac¡ o disku

         call      far ptr TestBreak        ; p©eru¨en¡ funkce ?
         jnc       DiskDIn6                 ; nen¡ p©eru¨en¡
         jmp       DiskDIn8                 ; je p©eru¨en¡ funkce

; ====== POZOR - pou‘¡v  se lok ln¡ zmˆna SP !!!!

DiskDIn6:mov       bl,ds:[DIMnLDsk]         ; ‡¡slo disku
         inc       bx                       ; korekce ‡¡sla disku (1...)
         mov       bp,sp
         sub       sp,120                   ; asi tak rezerva pro buffer
         mov       dx,sp                    ; DX <- buffer v z sobn¡ku

         push      ds                       ; £schova DS
         push      ss
         pop       ds                       ; DS <- segment z sobn¡ku
         mov       si,ds                    ; SI <- DS pro OS/2
         mov       di,dx                    ; DI <- DX pro OS/2
         mov       byte ptr ds:[di],bit0+bit2 ; dopl¤uj¡c¡ funkce
         mov       ax,440dh
         mov       cx,860h                  ; slu‘ba - poskytnut¡ informac¡
         stc                                ; p©ednastaven¡
         int       21h                      ; poskytnut¡ informac¡ o disku
         pop       ds
         jc        DskDIn69                 ; chyba
         jmp       DskDIn77                 ; operace OK

; ------ parametry slu‘bou 32h (pro RAM-disk)

DskDIn69:mov       ax,1
         mov       ds:[DInfSekS],ax         ; je 1 sektor na stopu
         mov       ds:[DInfStrn],ax         ; je 1 strana
         mov       ds:[DInfNFAT],al         ; po‡et FAT

         mov       al,ds:[DIMnLDsk]         ; ‡¡slo disku
         call      far ptr GetParB          ; poskytnut¡ parametr– disku ES:SI
         jnc       DskDIn70                 ; slu‘ba OK

; ------ vymy¨len‚ parametry (pro CD-ROM disk a SUBST RAM-disk)

         mov       ax,ds:[DInfCelk]         ; velikost disku v bloc¡ch
         push      ax
         cmp       ax,0ff6h                 ; je FAT12 ?
         mov       cx,3                     ; 3 tetr dy na polo‘ku
         jb        DskDI692                 ; je FAT12
         inc       cx                       ; 4 tetr dy na polo‘ku
DskDI692:mov       ax,ds:[DInfSekt]         ; po‡et bajt– na sektor
         xor       dx,dx                    ; DX <- 0
         add       ax,ax                    ; po‡et tetr d na sektor
         adc       dx,dx
         div       cx                       ; v˜po‡et po‡tu polo‘ek na sektor
         xchg      ax,cx                    ; CX <- po‡et polo‘ek na sektor
         pop       ax

         dec       cx                       ; bude zaokrouhlen¡
         xor       dx,dx                    ; DX <- 0
         add       ax,cx                    ; zaokrouhlen¡ na sektory
         adc       dx,0
         inc       cx
         div       cx                       ; v˜po‡et sektor– FAT
         mov       ds:[DInfFAT],ax          ; po‡et sektor– na FAT

         mov       ax,ds:[DInfCelk]         ; velikost disku v bloc¡ch
         mul       word ptr ds:[DInfSBlk]   ; velikost disku v sektorech
         add       ax,ds:[DInfFAT]          ; p©i‡ten¡ sektor– FAT
         adc       dx,0
         mov       bx,ds:[DInfRoot]         ; po‡et polo‘ek v ROOT
         mov       cl,5                     ; po‡et rotac¡
         shr       bx,cl                    ; po‡et sektor– na ROOT
         inc       bx                       ; + BOOT sektor
         add       ax,bx                    ; p©i‡ten¡ ROOT a BOOT
         adc       dx,0
         call      DskDI760                 ; v˜po‡et po‡tu v lc– z DX:AX
         jmp       short DskDIn76

; ------ parametry ze slu‘by 32h

DskDIn70:mov       ax,es:[si+0dh]           ; maxim ln¡ ‡¡slo bloku
         dec       ax                       ; po‡et aloka‡n¡ch blok–
         mov       cl,es:[si+4]             ; maxim ln¡ ‡¡slo sektoru
         mov       ch,0                     ; CH <- 0
         inc       cx                       ; po‡et sektor– v bloku
         mul       cx                       ; po‡et datov˜ch sektor–
         add       ax,es:[si+0bh]           ; p©i‡ten¡ po‡ te‡n¡ho sektoru dat
         adc       dx,0
         call      DskDI760                 ; v˜po‡et po‡tu v lc– z DX:AX

         mov       al,es:[si+8]             ; po‡et FAT
         mov       ds:[DInfNFAT],al         ; po‡et FAT
         mov       ax,es:[si+9]             ; po‡et polo‘ek ROOT
         mov       ds:[DInfRoot],ax         ; po‡et polo‘ek v ROOT
         mov       ah,0
         mov       al,es:[si+0fh]           ; po‡et sektor– na FAT
         cmp       byte ptr ds:[VerzeOS+1],4 ; je verze syst‚mu 4.x ?
         jb        DskDIn75                 ; je n¡zk  verze syst‚mu
         mov       ah,es:[si+10h]           ; po‡et sektor– na FAT (HIGH)
         inc       si                       ; korekce adresy
DskDIn75:mov       ds:[DInfFAT],ax          ; po‡et sektor– na FAT
         mov       al,es:[si+16h]           ; popisova‡ m‚dia
         mov       ds:[DInfPop],al          ; popisova‡ m‚dia
DskDIn76:jmp       DskDIn79


; ====== v˜po‡et po‡tu v lc– z celkov‚ho po‡tu sektor– DX:AX

DskDI760 PROC      NEAR

DskDI762:or        dx,dx
         jnz       DskDI764                 ; je p©ete‡en¡
         cmp       ax,1024
         jbe       DskDI768                 ; po‡et v lc– je ji‘ OK
DskDI764:shr       dx,1                     ; po‡et v lc– / 2
         rcr       ax,1
         cmp       word ptr ds:[DInfSekS],64/2 ; asi tak maximum sektor– na stopu
         jb        DskDI766                 ; je to je¨tˆ OK
         shl       word ptr ds:[DInfStrn],1 ; zv˜¨en¡ po‡tu stran
         jmp       short DskDI762

DskDI766:shl       word ptr ds:[DInfSekS],1 ; zv˜¨en¡ po‡tu sektor– na stopu
         jmp       short DskDI762

DskDI768:mov       ds:[DInfVal],ax          ; po‡et v lc–
         ret

DskDI760 ENDP

; ------ parametry slu‘bou 440dh

DskDIn77:mov       si,sp                    ; SI <- buffer v z sobn¡ku
         mov       ax,ss:[si+4]             ; po‡et v lc–
         mov       ds:[DInfVal],ax          ; po‡et v lc–

         mov       al,ss:[si+7+5]           ; po‡et FAT
         mov       ds:[DInfNFAT],al         ; po‡et FAT

         mov       ax,ss:[si+7+6]           ; po‡et polo‘ek v ROOT
         mov       ds:[DInfRoot],ax         ; po‡et polo‘ek v ROOT

         mov       al,ss:[si+7+0ah]         ; popisova‡ m‚dia
         mov       ds:[DInfPop],al          ; popisova‡ m‚dia

         mov       ax,ss:[si+7+0bh]         ; po‡et sektor– na FAT
         mov       ds:[DInfFAT],ax          ; po‡et sektor– na FAT

         mov       ax,ss:[si+7+0dh]         ; po‡et sektor– na stopu
         mov       ds:[DInfSekS],ax         ; po‡et sektor– na stopu

         mov       ax,ss:[si+7+0fh]         ; po‡et stran
         mov       ds:[DInfStrn],ax         ; po‡et stran

         mov       ax,ds:[DInfSekS]         ; po‡et sektor– na stopu
         mul       word ptr ds:[DInfStrn]   ; po‡et stran * po‡et sektor–
         or        dx,dx                    ; je p©ete‡en¡ ?
         jnz       DskDIn79                 ; je p©ete‡en¡
         xchg      ax,cx                    ; CX <- po‡et sektor– na v lec
         jcxz      DskDIn79                 ; chybn˜ £daj

         xor       dx,dx                    ; DX <- 0
         mov       ax,ss:[si+7+8]           ; po‡et sektor– celkem
         or        ax,ax                    ; je mal˜ po‡et sektor– ?
         jnz       DskDI782                 ; po‡et sektor– je OK
         mov       ax,ss:[si+7+15h]         ; po‡et sektor– velk‚ho disku
         mov       dx,ss:[si+7+15h+2]
DskDI782:dec       cx                       ; sektor– na v lec - 1
         add       ax,cx                    ; zaokrouhlen¡ nahoru
         adc       dx,0
         jc        DskDIn79
         inc       cx                       ; po‡et sektor– na v lec
         cmp       dx,cx                    ; bylo by p©ete‡en¡ ?
         jae       DskDIn79                 ; bylo by p©ete‡en¡
         div       cx                       ; v˜po‡et po‡tu v lc–
         cmp       ax,ds:[DInfVal]          ; kter  hodnota je vˆt¨¡ ?
         jbe       DskDIn79                 ; nen¡ vˆt¨¡ £daj
         mov       ds:[DInfVal],ax          ; po‡et v lc– disku

DskDIn79:mov       sp,bp                    ; n vrat SP

; ====== konec lok ln¡ zmˆny SP !!!!


; ------ typ disku

DiskDIn8:mov       al,"Q"                   ; disk QD
         cmp       byte ptr ds:[DInfSekS],23 ; je disketa QD ?
         jae       DskDIn81                 ; je disketa QD
         mov       al,"H"                   ; disk HD
         cmp       byte ptr ds:[DInfSekS],14 ; je disketa HD ?
         jae       DskDIn81                 ; je disketa HD
         mov       al,"D"                   ; disk DD
DskDIn81:mov       ds:[DIMTypTH],al         ; typ diskety

         mov       di,offset DIMTyp         ; buffer
         call      DiskDI0                  ; p©¡prava bufferu

         mov       al,ds:[DIMnLDsk]         ; po‡et bajt– na popisova‡
         mov       ah,0
         add       ax,offset DiskITab       ; offset v tabulce
         xchg      ax,si
         mov       cl,ds:[si]               ; typ disku
         and       cl,bit0+bit1+bit2
         mov       ch,0
         mov       ah,0
         mov       si,offset DIMTypT        ; tabulka disk–
         jcxz      DskDIn83                 ; disk nezn m˜
DskDIn82:lodsb                              ; d‚lka textu
         add       si,ax                    ; n sleduj¡c¡ text
         loop      DskDIn82                 ; nalezen¡ adresy textu k disku
DskDIn83:lodsb                              ; d‚lka textu
         xchg      ax,cx                    ; CX <- d‚lka textu
         rep       movsb                    ; p©enos textu pro disk
         mov       al,0                     ; zmˆna barvy
         stosb                              ; koncov  zmˆna barvy

; ------ po‡et polo‘ek v ROOT

         mov       di,offset DIMRoot        ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDI1                  ; p©¡prava bufferu
         mov       ax,ds:[DInfRoot]         ; po‡et polo‘ek v ROOT
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         cld
         mov       si,offset DIMRootT       ; text "polo‘ek"
         mov       cx,offset(DIMRotT0-DIMRootT)
         rep       movsb

; ------ informace o FAT

         mov       di,offset DIMFat         ; buffer k dek¢dov n¡
         call      DiskDI1                  ; p©¡prava bufferu

         mov       al,ds:[DInfNFat]         ; po‡et tabulek FAT
         mov       ah,0                     ; barva se neukl d 
         call      far ptr DekNumB          ; dek¢dov n¡ ‡¡sla
         cld
         mov       si,offset DIMFatT1       ; text " x "
         movsw                              ; zmˆna barvy a mezera
         movsw                              ; znak n soben¡ "x" a mezera
         movsb                              ; zmˆna barvy
         mov       ax,ds:[DInfFAT]          ; po‡et sektor– na FAT
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         cld
         mov       cx,offset(DIMFatT0-DIMFatTT)
         rep       movsb

; ------ popisova‡ m‚dia

         mov       di,offset DIMPopis+1     ; buffer
         mov       al,ds:[DInfPop]          ; popisova‡ m‚dia
         mov       ah,0                     ; barva se neukl d 
         call      far ptr DekHByte         ; dek¢dov n¡ popisova‡e
         cld
         mov       al,0
         stosb                              ; zmˆna barvy

; ------ po‡et v lc–

         mov       di,offset DIMValcu       ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDI1                  ; p©¡prava bufferu

         mov       ax,ds:[DInfVal]          ; po‡et v lc– disku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         cld
         mov       al,0
         stosb                              ; zmˆna barvy

; ------ po‡et stran

         mov       di,offset DIMStran       ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDI1                  ; p©¡prava bufferu

         mov       ax,ds:[DInfStrn]         ; po‡et stran disku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         mov       al,0
         cld
         stosb

; ------ po‡et sektor– na stopu

         mov       di,offset DIMStopa       ; buffer k dek¢dov n¡ ‡¡sla
         call      DiskDI1                  ; p©¡prava bufferu

         mov       ax,ds:[DInfSekS]         ; po‡et sektor– na stopu
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         cld
         mov       si,offset DIMStopT       ; text " na stopu"
         mov       cx,offset(DIMStop0-DIMStopT)
         rep       movsb

; ------ zobrazen¡ okna

         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr TestBreak        ; p©eru¨en¡ operace ?
         jc        DiskDIn9                 ; p©eru¨en¡ operace
         mov       si,offset DIMnuLin       ; menu informace o disku
         call      far ptr Lin0Menu
DiskDIn9:jmp       far ptr Main0

DiskDInf ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla (dvojslova) do bufferu DI s ozna‡en¡m "B"
; -----------------------------------------------------------------------------

DiskDID  PROC      NEAR

         call      DiskDI1                  ; p©¡prava bufferu
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla (dvojslovo)
         jmp       short DiskDIW2

DiskDID  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla (slova) do bufferu DI s ozna‡en¡m "B"
; -----------------------------------------------------------------------------

DiskDIW  PROC      NEAR

         call      DiskDI1                  ; p©¡prava bufferu
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla (slovo)
DiskDIW2:cld
         mov       ax," "*HI                ; zmˆna barvy a mezera
         stosw
         mov       al,"B"
         stosb
         ret

DiskDIW  ENDP

; -----------------------------------------------------------------------------
;        p©¡prava bufferu DI
; -----------------------------------------------------------------------------

DiskDI1: mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         mov       bh,0                     ; barva se neukl d 

DiskDI0  PROC      NEAR

         push      ax
         push      cx

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ch,0
         mov       cl,ds:[di]               ; d‚lka bufferu
         inc       di                       ; za‡ tek bufferu

         push      di                       ; za‡ tek bufferu
         mov       al," "
         cld
         rep       stosb                    ; vymaz n¡ bufferu
         pop       di

         pop       cx
         pop       ax
         ret

DiskDI0  ENDP

; *****************************************************************************
;
;                           Verifikace disku
;
; *****************************************************************************
;þ
DiskVer  PROC      FAR

; ------ uzav©en¡ oken menu

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

; ------ otev©en¡ a na‡ten¡ mapy disku

DiskVr0A:call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         mov       byte ptr ds:[DVDSmart],-1 ; stav SMARTDRV nezn m˜
         call      OpenDMap                 ; otev©en¡ a na‡ten¡ mapy disku
         jc        DiskVer0                 ; chyba

; ------ £schova a vypnut¡ SMARTDRV pro aktivn¡ disk

         call      DiskSOff                 ; £schova a vypnut¡ SMARTDRV

; ------ vytvo©en¡ bufferu pro na‡ten¡ bloku

         mov       bx,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         call      far ptr CreatDat         ; vytvo©en¡ bufferu
         jnc       DiskVer1                 ; buffer vytvo©en OK
         call      far ptr MemErr           ; chyba pamˆti
DiskVer0:xor       bx,bx                    ; nen¡ kl vesa
         jmp       DiskVer9

; ------ p©¡prava ukazatel– bufferu

DiskVer1:mov       ds:[DVDskSeg],ax         ; segment bufferu
         xchg      ax,bx                    ; AX <- velikost bufferu
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DskLBSkt]   ; v˜po‡et po‡tu sektor–
         mov       ds:[DVDskSNm],ax         ; velikost bufferu v sektorech

; ------ d‚lka kurzoru operace

         xor       dx,dx
         div       word ptr ds:[DskLSBlk]   ; p©epo‡et na po‡et blok–
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DMapBlk]    ; p©epo‡et na po‡et pozic
         or        ax,ax                    ; je to rozumn‚ ‡¡slo ?
         jnz       DiskVr12                 ; je to nˆjak‚ ‡¡slo
         inc       ax                       ; minim lnˆ 1 blok
DiskVr12:mov       ds:[DVDskDel],ax         ; d‚lka kurzoru operace
         mov       ds:[DVDskDl0],ax         ; d‚lka kurzoru operace

; ------ otev©en¡ okna mapy disku

         mov       word ptr ds:[DVDskOfs],-1 ; zru¨en¡ star‚ho offsetu v mapˆ
         mov       si,offset DVMnuLin       ; menu mapy disku
         call      far ptr OpenMnu          ; otev©en¡ okna
         call      far ptr KurzOff          ; vypnut¡ kurzoru

; ------ hl ¨en¡ o verifikaci disku

         mov       si,offset DVMnTxt
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ p©¡prava k verifikaci disku

         mov       ax,word ptr ds:[DskLNSkt] ; po‡et sektor– na disku
         mov       word ptr ds:[DVDskCit],ax ; ‡¡ta‡ zbyl˜ch sektor–
         mov       ax,word ptr ds:[DskLNSkt+2] ; po‡et sektor– na disku
         mov       word ptr ds:[DVDskCit+2],ax ; ‡¡ta‡ zbyl˜ch sektor–
         mov       word ptr ds:[DVDsk1Sk],0 ; nen¡ 1-sektorov  operace

; ------ po‡ te‡n¡ sektor k operaci

         mov       ax,ds:[DVDskSeg]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu -> ES
         xor       ax,ax                    ; ukazatel ‡¡sla sektoru
         xor       dx,dx
         call      DiskVNl                  ; nulov n¡ mˆ©en¡ rychlosti

         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jz        DiskVer2                 ; nen¡ to CD disk
         mov       al,16                    ; p©esko‡en¡ prvn¡ch 16 sektor–
         sub       word ptr ds:[DVDskCit],ax ; sn¡‘en¡ po‡tu sektor– o 16
         sbb       word ptr ds:[DVDskCit+2],dx

; ------ test, zda je p©eru¨en¡ operace

DiskVer2:call      far ptr MousBrea         ; test p©eru¨en¡ my¨¡
;         call      far ptr TestBEsc         ; je p©eru¨en¡ operace ?
         jnc       DiskVr22
DiskVr21:jmp       DiskVer8                 ; je p©eru¨en¡ operace

; ------ obsluha my¨i a kl vesnice

DiskVr22:call      far ptr MouseGet         ; ovl d n¡ my¨¡
         jnc       DiskVr23                 ; je k¢d my¨i
         push      ax
         call      far ptr TestChar         ; test znaku z kl vesnice
         pop       ax
         jc        DiskVr24                 ; nen¡ kl vesa

         xchg      ax,bx
         call      far ptr InputChar        ; vstup znaku z kl vesnice
         xchg      ax,bx                    ; BX <- kl vesa
DiskVr23:call      DiskVKur                 ; posun ukazatele kurzory
         jnc       DiskVer2                 ; kl vesa byla obslou‘ena - dal¨¡

DiskVr24:call      far ptr DispTime         ; obsluha zobrazen¡ ‡asu
         call      far ptr DarkNul          ; nulov n¡ stm¡va‡e obrazovky

; ------ ukazatel operace

         push      ax
         push      dx

         xor       bx,bx                    ; ukazatel pro Boot (= 0)
         sub       ax,ds:[DskLBFat]         ; ode‡ten¡ sektor– pro Boot
         sbb       dx,0
         jc        DiskVer3                 ; je Boot

         inc       bx                       ; ukazatel pro FAT (= 1)
         sub       ax,ds:[DskLCFat]         ; ode‡ten¡ sektor– na FAT
         sbb       dx,0
         jc        DiskVer3                 ; je FAT

         inc       bx                       ; ukazatel pro Root (= 2)
         sub       ax,ds:[DskLSRot]         ; ode‡ten¡ sektor– na Root
         sbb       dx,0
         jc        DiskVer3                 ; je Root

         inc       bx                       ; ukazatel pro data (= 3)
         div       word ptr ds:[DskLSBlk]   ; p©epo‡et na ‡¡slo bloku
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DMapBlk]    ; p©epo‡et na offset v mapˆ
         add       bx,ax                    ; BX <- offset v mapˆ

DiskVer3:mov       ax,ds:[DVDskDl0]
         mov       ds:[DVDskDel],ax         ; d‚lka kurzoru

         pop       dx
         pop       ax
         mov       ds:[DVDskOfs],bx         ; nov˜ offset v mapˆ

; ------ po‡et sektor– ke ‡ten¡

         mov       cx,ds:[DVDskSNm]         ; velikost bufferu v sektorech
         cmp       word ptr ds:[DVDskCit+2],0 ; zb˜v  je¨tˆ dost ?
         jne       DiskVer4                 ; zb˜v  je¨tˆ dost dat
         cmp       cx,word ptr ds:[DVDskCit] ; zb˜v  m‚nˆ sektor– ?
         jbe       DiskVer4                 ; zb˜v  je¨tˆ dost sektor–
         mov       cx,word ptr ds:[DVDskCit] ; omezen¡ po‡tu sektor–
DiskVer4:jcxz      DiskVr21                 ; konec operace
         cmp       word ptr ds:[DVDsk1Sk],0 ; je 1-sektorov  operace ?
         je        DiskVer5                 ; nen¡ 1-sektorov  operace
         mov       cx,1                     ; omezen¡ na 1 sektor
         dec       word ptr ds:[DVDsk1Sk]   ; sn¡‘en¡ ‡¡ta‡e
         mov       ds:[DVDskDel],cx         ; d‚lka kurzoru = 1

; ------ dek¢dov n¡ ‡¡sla sektoru

DiskVer5:push      ax
         push      cx
         push      dx
         push      es

         push      ax                       ; £schova ‡¡sla sektoru LOW
         push      dx                       ; £schova ‡¡sla sektoru HIGH

         push      ds
         pop       es
         mov       di,offset DMMnLPS1+1
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla sektoru
         sub       di,offset DMMnLPS1+1
         mov       cx,di
         mov       ds:[DMMnLPS1],cl

; ------ dek¢dov n¡ ‡¡sla bloku

         mov       di,offset DMMnLPS2+1
         sub       ax,ds:[DskLBDat]         ; ode‡ten¡ po‡ te‡n¡ho dat. sektoru
         sbb       dx,0
         jnc       DiskVr52                 ; nen¡ podte‡en¡
         xor       ax,ax
         xor       dx,dx
DiskVr52:div       word ptr ds:[DskLSBlk]   ; p©epo‡et na ‡¡slo bloku
         inc       ax
         inc       ax                       ; ‡¡slo bloku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla bloku
         sub       di,offset DMMnLPS2+1
         mov       cx,di
         mov       ds:[DMMnLPS2],cl

; ------ na‡ten¡ uplynul‚ho ‡asu operace -> BX:CX

         mov       ax,word ptr ds:[DVDskBeg] ; ‡as po‡ tku operace
         mov       dx,word ptr ds:[DVDskBeg+2]
         call      far ptr GetCDelt         ; na‡ten¡ uplynul‚ho ‡asu
         xchg      ax,cx                    ; CX <- uplynul˜ ‡as LOW
         mov       bx,dx                    ; BX <- uplynul˜ ‡as HIGH

; ------ p©epo‡et sektor– na bajty -> DX:AX

         pop       ax                       ; ‡¡slo sektoru HIGH
         pop       dx                       ; ‡¡slo sektoru LOW

         sub       dx,word ptr ds:[DVDskCt0] ; ode‡ten¡ po‡ tku
         sbb       ax,word ptr ds:[DVDskCt0+2]
         jnc       DiskVr53
         jmp       DiskVr58                 ; bylo by p©ete‡en¡ £daje

DiskVr53:push      dx                       ; £schova ‡¡sla sektoru LOW

         mul       word ptr ds:[DskLBSkt]   ; p©epo‡et na bajty HIGH
         xchg      ax,di                    ; DI <- po‡et bajt– HIGH

         pop       ax                       ; n vrat ‡¡sla sektoru LOW
         mul       word ptr ds:[DskLBSkt]   ; p©epo‡et na bajty LOW
         add       dx,di                    ; po‡et bajt– HIGH

; ------ p©epo‡et bajt– na KB*4 -> DX:AX

         mov       al,ah                    ; vydˆlen¡ / 256
         mov       ah,dl
         mov       dl,dh
         mov       dh,0

; ------ korekce (KB*4 * 18/2) -> DX:AX (tj. KB*2 * 18)

         mov       di,9                     ; n sobek (tj. 18/2)
         xchg      ax,si                    ; SI <- £schova LOW
         xchg      ax,dx                    ; AX <- HIGH
         mul       di                       ; HIGH * 18
         xchg      ax,si                    ; SI <- nov‚ HIGH, AX <- star‚ LOW
         mul       di                       ; LOW * 18
         add       dx,si                    ; p©i‡ten¡ p©enosu HIGH

; ------ normalizace dˆlitele -> DX:AX/CX (tj. KB * 18 / CX)

DiskVr54:shr       dx,1
         rcr       ax,1                     ; / 2
         or        bx,bx                    ; je ji‘ dˆlitel OK ?
         jz        DiskVr56                 ; dˆlitel je ji‘ OK
         shr       bx,1
         rcr       cx,1
         jmp       short DiskVr54

; ------ v˜po‡et rychlosti

DiskVr56:or        cx,cx                    ; je dˆlitel OK ?
         jnz       DiskVr57                 ; dˆlitel je OK
         inc       cx                       ; minim lnˆ 1

DiskVr57:xchg      ax,bx                    ; BX <- KB LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- KB HIGH, DX <- 0
         div       cx                       ; rychlost HIGH
         xchg      ax,bx                    ; BX <- rychlost HIGH, AX <- KB LOW
         div       cx                       ; rychlost LOW
         mov       dx,bx                    ; DX <- rychlost HIGH

; ------ dek¢dov n¡ rychlosti

         call      far ptr TestTDis         ; bude zmˆna £daje ?
         jc        DiskVr58                 ; nebude zmˆna £daje

         mov       bh,0
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         mov       di,offset DMMnLPS3+1
         call      far ptr DekNum           ; dek¢dov n¡ rychlosti
         sub       di,offset DMMnLPS3+1
         mov       cx,di
         mov       ds:[DMMnLPS3],cl

         add       ax,50                    ; korekce pro zaokrouhlen¡ 50 KB
         adc       dx,0
         mov       cx,150                   ; dˆlitel pro p©epo‡et
         xchg      ax,bx                    ; BX <- KB LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- KB HIGH, DX <- 0
         div       cx                       ; rychlost HIGH
         xchg      ax,bx                    ; BX <- rychlost HIGH, AX <- KB LOW
         div       cx                       ; rychlost LOW
         mov       dx,bx                    ; DX <- rychlost HIGH

         xor       bx,bx                    ; nen¡ barva ani oddˆlova‡
         mov       di,offset DMMnLPS4+1
         call      far ptr DekNum           ; dek¢dov n¡ rychlosti
         sub       di,offset DMMnLPS4+1
         mov       cx,di
         mov       ds:[DMMnLPS4],cl

DiskVr58:pop       es
         pop       dx
         pop       cx
         pop       ax

; ------ zobrazen¡ ukazatele operace

         mov       si,offset DVMnuLin
         call      far ptr DispMnu          ; nov‚ zobrazen¡ okna

; ------ na‡ten¡ jednoho bloku dat

         xor       di,di                    ; DI <- ukl dac¡ adresa
         call      far ptr ReadLDsk         ; na‡ten¡ bufferu z disku
         jnc       DiskVer7                 ; operace OK

; ------ p©i chybˆ zmˆna na 1-sektorovou operaci

         cmp       cx,1                     ; je ji‘ operace po 1 sektoru ?
         je        DiskVr59                 ; je ji‘ operace po 1 sektoru
         mov       ds:[DVDsk1Sk],cx         ; po‡et sektor– k operaci
         jmp       DiskVer2                 ; opakov n¡ operace

; ------ hl ¨en¡, ‘e je chyba operace

DiskVr59:test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jz        DiskVr61                 ; nen¡ to CD disk
         or        dx,dx                    ; je sektor < 16 ?
         jnz       DiskVr61                 ; nen¡ sektor < 16
         cmp       ax,16                    ; je sektor < 16 ?
         jb        DiskVer7                 ; je sektor < 16
DiskVr61:call      DiskVHls                 ; hl ¨en¡, ‘e je chyba operace
         jc        DiskVer8                 ; p©eru¨en¡ operace
         mov       cx,1                     ; 1 sektor
         mov       word ptr ds:[DVDsk1Sk],2 ; je¨tˆ asi tak 2x po 1 sektoru

; ------ zv˜¨en¡ ukazatele dat

DiskVer7:add       ax,cx                    ; zv˜¨en¡ ukazatele sektor–
         adc       dx,0
         sub       word ptr ds:[DVDskCit],cx
         sbb       word ptr ds:[DVDskCit+2],0

         push      ax
         mov       ax,word ptr ds:[DVDskCt0] ; sektor po‡ tku operace
         or        ax,word ptr ds:[DVDskCt0+2] ; je prvn¡ pr–chod ?
         pop       ax
         jnz       DiskVr72                 ; nen¡ prvn¡ pr–chod
         call      DiskVNl                  ; nulov n¡ mˆ©en¡ rychlosti

DiskVr72:jmp       DiskVer2           ; dal¨¡ blok dat

; ------ uzav©en¡ re‘imu verifikace

DiskVer8:call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         mov       word ptr ds:[DVDskOfs],-1 ; zru¨en¡ indik toru verifikace
         mov       si,offset DVMnuLin       ; menu mapy disku
         call      far ptr DispMnu          ; nov‚ zobrazen¡ okna
         call      far ptr KurzOff          ; vypnut¡ kurzoru
         call      far ptr FlushChr         ; vypr zdnˆn¡ bufferu kl vesnice
DiskVr81:call      far ptr InpChar          ; vstup znaku z kl vesnice -> BX
         cmp       bl,CR
         je        DiskVr82
         cmp       bl,ESCP
         je        DiskVr82
         cmp       bh,MousXKod/HI           ; je k¢d kl vesy ?
         jne       DiskVr81
         cmp       bl,MousXRP               ; stisk prav‚ho tla‡¡tka my¨i ?
         je        DiskVr82
         cmp       bl,MousXLP               ; stisk lev‚ho tla‡¡tka my¨i ?
         jne       DiskVr81
         mov       bl,CR                    ; k¢d kl vesy pro opakov n¡ operace
DiskVr82:call      far ptr ClosMnu          ; uzav©en¡ okna menu
         call      DiskSRet                 ; navr cen¡ stavu SMARTDRV

; ------ zru¨en¡ buffer– (BX=kl vesa pro opakov n¡)

DiskVer9:call      ClosDMap                 ; uzav©en¡ mapy disku
         mov       ax,ds:[DVDskSeg]         ; segment bufferu
         call      far ptr DelSeg           ; zru¨en¡ segmentu mapy
         mov       ds:[DVDskSeg],ax
         cmp       bl,CR                    ; je opakov n¡ operace ?
         jne       DiskVerA                 ; nen¡ opakov n¡
         jmp       DiskVr0A                 ; opakov n¡ operace
DiskVerA:jmp       far ptr Main0

DiskVer  ENDP

; -----------------------------------------------------------------------------
;        posun ukazatele sektor– DX:AX kurzory BX -> NC=je kl vesa kurzor–
; -----------------------------------------------------------------------------

DiskVKur PROC      NEAR

         push      cx
         push      bp

         push      ax
         push      dx
         mov       ax,ds:[DMapBlk]          ; po‡et blok– na zobrazenou pozici
         mul       word ptr ds:[DskLSBlk]   ; p©epo‡et na po‡et sektor–
         mov       bp,dx                    ; BP <- po‡et sektor– HIGH
         xchg      ax,cx                    ; CX <- po‡et sektor– na pozici
         pop       dx
         pop       ax

         call      far ptr JumpBX           ; obsluha kl vesy

         dw        4700h,DiskVK23           ; Home
         dw        4f00h,DiskVK43           ; End
         dw        4800h,DiskVKr1           ; nahoru
         dw        4b00h,DiskVKr2           ; vlevo
         dw        5000h,DiskVKr3           ; dol–
         dw        4d00h,DiskVKr4           ; vpravo
         dw        MousXKod+MousXLP,DiskVKr5 ; stisk lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXMov,DiskVKr5 ; posun my¨¡ s dr‘en¡m tla‡¡tka
         dw        3920h,DiskVKr7           ; mezera
         dw        0,DiskVKr8               ; neplatn  kl vesa

DiskVKr1:call      DiskVKM                  ; po‡et sektor– na ©adu

DiskVKr2:cmp       bp,dx                    ; bylo by podte‡en¡ ?
         jne       DiskVK22
         cmp       cx,ax
DiskVK22:jbe       DiskVK24                 ; nen¡ podte‡en¡
DiskVK23:mov       bp,dx                    ; omezen¡ velikosti posunu
         mov       cx,ax
DiskVK24:sub       ax,cx                    ; posun ukazatele
         sbb       dx,bp
         add       word ptr ds:[DVDskCit],cx ; posun ‡¡ta‡e zbyl˜ch sektor–
         adc       word ptr ds:[DVDskCit+2],bp
         jmp       short DiskVKr7

DiskVKr5:call      DiskVMou                 ; posun pomoc¡ my¨i
         jns       DiskVKr4                 ; nen¡ posun zpˆt
         not       cx
         not       bp
         add       cx,1
         adc       bp,0
         jmp       short DiskVKr2

DiskVKr3:call      DiskVKM                  ; po‡et sektor– na ©adu

DiskVKr4:cmp       bp,word ptr ds:[DVDskCit+2] ; bylo by p©ete‡en¡ ?
         jne       DiskVK42
         cmp       cx,word ptr ds:[DVDskCit]
DiskVK42:jbe       DiskVK44                 ; nen¡ podte‡en¡
DiskVK43:mov       cx,word ptr ds:[DVDskCit] ; omezen¡ velikosti posunu
         mov       bp,word ptr ds:[DVDskCit+2]
DiskVK44:add       ax,cx                    ; posun ukazatele
         adc       dx,bp
         sub       word ptr ds:[DVDskCit],cx ; posun ‡¡ta‡e zbyl˜ch sektor–
         sbb       word ptr ds:[DVDskCit+2],bp

DiskVKr7:call      DiskVNl                  ; nulov n¡ mˆ©en¡ rychlosti
         clc                                ; p©¡znak obslou‘en‚ kl vesy
         jmp       short DiskVKr9

DiskVKr8:stc                                ; p©¡znak neplatn‚ kl vesy
DiskVKr9:pop       bp
         pop       cx
         ret

DiskVKur ENDP

; ------ po‡et sektor– na © dek -> BP:CX

DiskVKM  PROC      NEAR

         push      ax
         push      dx

         mov       ax,ds:[DMapSir]          ; ¨¡©ka mapy disku
         mul       bp                       ; v˜po‡et sektor– na © dek HIGH
         xchg      ax,bp                    ; BP <- po‡et sektor– HIGH
         mov       ax,ds:[DMapSir]          ; ¨¡©ka mapy disku
         mul       cx                       ; v˜po‡et sektor– na © dek LOW
         xchg      ax,cx                    ; CX <- po‡et sektor– LOW
         add       bp,dx                    ; BP <- po‡et sektor– HIGH

         pop       dx
         pop       ax
         ret

DiskVKM  ENDP

; ------ posun kurzoru pomoc¡ my¨i -> BP:CX

DiskVMou PROC      NEAR

         xchg      ax,cx
         mov       bp,dx

         mov       al,byte ptr ds:[MousePoz+1] ; © dek s kurzorem my¨i
         mov       ah,ds:[DVMnuLin+MnuRad]  ; po‡ te‡n¡ © dek menu
         add       ah,1                     ; p©i‡ten¡ horn¡ho okraje
         sub       al,ah                    ; © dek s my¨¡ relativnˆ
         jnc       DiskVMo1
         mov       al,0                     ; omezen¡ p©i podte‡en¡
DiskVMo1:mov       dh,byte ptr ds:[DMapSir] ; ¨¡©ka mapy
         mul       dh                       ; p©epo‡et © dku na pozice
         xchg      ax,bx                    ; BX <- © dek s my¨¡ relativnˆ

         mov       al,byte ptr ds:[MousePoz] ; pozice s kurzorem my¨i
         mov       ah,ds:[si+MnuPoz]        ; po‡ te‡n¡ pozice menu
         add       ah,2                     ; p©i‡ten¡ lev‚ho okraje
         sub       al,ah                    ; pozice s my¨¡ relativnˆ
         jnc       DiskVMo2
         mov       al,0
DiskVMo2:mov       ah,0
         cmp       al,dh                    ; p©ete‡en¡ ¨¡©ky mapy ?
         jb        DiskVMo3                 ; je to OK
         mov       al,dh                    ; ¨¡©ka mapy
         dec       ax                       ; posledn¡ pozice

DiskVMo3:add       ax,bx                    ; offset kurzoru my¨i
         sub       ax,3                     ; ode‡ten¡ syst‚mov‚ oblasti
         jnc       DiskVMo4
         xor       ax,ax
DiskVMo4:mul       word ptr ds:[DMapBlk]    ; p©epo‡et na po‡et blok–
         xchg      ax,bx                    ; BX <- po‡et blok– LOW
         xchg      ax,dx                    ; AX <- po‡et blok– HIGH
         mul       word ptr ds:[DskLSBlk]   ; p©epo‡et na sektory HIGH
         xchg      ax,bx                    ; BX <- sektory HIGH, AX <- bloky LOW
         mul       word ptr ds:[DskLSBlk]   ; p©epo‡et na sektory LOW
         add       dx,bx                    ; p©i‡ten¡ sektor– HIGH
         add       ax,ds:[DskLBDat]         ; p©i‡ten¡ po‡ te‡n¡ho datov‚ho sektoru
         adc       dx,0

         sub       ax,cx                    ; vzd lenost od aktu ln¡ho ukazatele
         sbb       dx,bp

         xchg      ax,cx
         xchg      bp,dx
         ret

DiskVMou ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ mˆ©en¡ rychlosti ‡ten¡ (DX:AX=aktu ln¡ sektor)
; -----------------------------------------------------------------------------

DiskVNl  PROC      NEAR

         mov       word ptr ds:[DVDskCt0],ax ; po‡ te‡n¡ sektor
         mov       word ptr ds:[DVDskCt0+2],dx

         push      ax
         push      dx

         call      far ptr GetCTime         ; na‡ten¡ syst‚mov‚ho ‡asu
         mov       word ptr ds:[DVDskBeg],ax ; £schova ‡asu
         mov       word ptr ds:[DVDskBeg+2],dx

         pop       dx
         pop       ax
         ret

DiskVNl  ENDP

; -----------------------------------------------------------------------------
;        £schova a vypnut¡ SMARTDRV (uchov  p©¡znaky !)
; -----------------------------------------------------------------------------

DiskSOff PROC      NEAR

         pushf
         push      ax

         call      far ptr SmartFls         ; vypr zdnˆn¡ cache pro SMARTDRV

         mov       al,ds:[DskLDisk]         ; aktivn¡ disk
         call      far ptr SmartGet         ; poskytnut¡ stavu disku
         mov       ds:[DVDSmart],ah         ; £schova stavu SMARTDRV

         or        ah,bit6+bit7             ; nen¡ ‘ dn  cache
DiskSOf2:call      far ptr SmartSet         ; vypnut¡ cache disku
DiskSOf4:pop       ax
         popf
         ret

DiskSOff ENDP

; -----------------------------------------------------------------------------
;        navr cen¡ stavu SMARTDRV
; -----------------------------------------------------------------------------

DiskSRet PROC      NEAR

         pushf
         push      ax

         mov       al,ds:[DskLDisk]         ; aktivn¡ disk
         mov       ah,-1                    ; stav nezn m˜
         xchg      ah,ds:[DVDSmart]         ; uschovan˜ stav SMARTDRV
         cmp       ah,-1                    ; je stav zn m˜ ?
         jne       DiskSOf2                 ; stav je zn m˜
         jmp       short DiskSOf4

DiskSRet ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡, ‘e je vadn˜ sektor DX:AX -> CY=p©eru¨en¡
; -----------------------------------------------------------------------------

DiskVHls PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx
         push      es

; ------ dek¢dov n¡ ‡¡sla sektoru

         push      ds
         pop       es
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         mov       di,offset DVBMnPl3+1     ; buffer ‡¡sla sektoru
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla sektoru
         sub       di,offset DVBMnPl3+1     ; d‚lka textu
         mov       cx,di
         mov       ds:[DVBMnPl3],cl         ; d‚lka textu

; ------ p©evod na ‡¡slo bloku, p©¡prava textu pro hl ¨en¡

         mov       si,offset DVBMnPlB       ; BOOT
         sub       ax,ds:[DskLBFat]         ; ode‡ten¡ sektor– pro Boot
         sbb       dx,0
         jc        DiskVHl1                 ; je Boot

         mov       si,offset DVBMnPlF       ; FAT
         sub       ax,ds:[DskLCFat]         ; ode‡ten¡ sektor– na FAT
         sbb       dx,0
         jc        DiskVHl1                 ; je FAT

         mov       si,offset DVBMnPlR       ; ROOT
         sub       ax,ds:[DskLSRot]         ; ode‡ten¡ sektor– na Root
         sbb       dx,0
         jc        DiskVHl1                 ; je Root

         div       word ptr ds:[DskLSBlk]   ; p©epo‡et na ‡¡slo bloku
         inc       ax
         inc       ax                       ; ‡¡slo bloku
         mov       di,offset DVBMnPl4+1     ; buffer k dek¢dov n¡ ‡¡sla bloku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla bloku
         sub       di,offset DVBMnPl4+1     ; d‚lka textu
         mov       cx,di                    ; CX <- d‚lka textu
         mov       si,offset DVBMnPl4       ; ‡¡slo bloku
         mov       ds:[si],cl               ; d‚lka textu
         jmp       short DiskVHl2

DiskVHl1:xor       ax,ax                    ; ‡¡slo bloku neplat¡
DiskVHl2:mov       ds:[DVBMnPl1],si         ; adresa textu
         xchg      ax,bx                    ; BX <- ‡¡slo bloku

; ------ syst‚mov˜ sektor - blok nen¡ voln˜

         or        byte ptr ds:[DVBMnBlk],bit1 ; blokov n¡ mo‘nosti ozna‡en¡
         mov       word ptr ds:[DVBMnPl2],offset DVBMnPl5 ; blok nelze ozna‡it
         or        bx,bx                    ; je syst‚mov˜ blok ?
         jz        DiskVHl4                 ; je syst‚mov˜ blok

; ------ test, zda je blok ji‘ ozna‡en jako vadn˜

         call      far ptr GetClust         ; poskytnut¡ obsahu bloku
         cmp       ax,0fff7h                ; je blok ozna‡en jako vadn˜ ?
         je        DiskVHl8                 ; blok je ji‘ ozna‡en jako vadn˜

; ------ blok je voln˜

         or        ax,ax                    ; je blok voln˜ ?
         jnz       DiskVHl4                 ; blok nen¡ voln˜
         mov       word ptr ds:[DVBMnPl2],offset DVBMnPl6 ; blok je voln˜
         and       byte ptr ds:[DVBMnBlk],not bit1 ; je mo‘n‚ ozna‡en¡

; ------ hl ¨en¡ o chybˆ operace

DiskVHl4:call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         mov       si,offset DVBMnLin       ; menu hl ¨en¡ chyby
         push      bx
         call      far ptr Lin0MenF         ; chybov‚ hl ¨en¡
         dec       bx                       ; je ozna‡en¡ bloku ?
         pop       bx
         jc        DiskVHl9                 ; p©eru¨en¡ operace
         jnz       DiskVHl8                 ; nen¡ ozna‡en¡ bloku

; ------ ozna‡en¡ bloku za vadn˜

         mov       ax,0fff7h                ; p©¡znak - blok je vadn˜
         call      far ptr SetClust         ; ozna‡en¡ bloku, ‘e je vadn˜
         call      far ptr WritFat          ; z pis tabulky FAT

         mov       al,ds:[DskLDisk]         ; aktivn¡ disk
         mov       ah,bit3+bit4+bit5        ; v¨echna okna
         call      far ptr ModWDisk         ; aktualizace oken

         mov       ax,ds:[DMapSeg]          ; segment mapy disku
         call      far ptr GetDat           ; adresa segmentu mapy
         xchg      ax,bx                    ; AX <- ‡¡slo bloku
         dec       ax
         dec       ax                       ; korekce ‡¡sla bloku
         xor       dx,dx
         div       word ptr ds:[DMapBlk]    ; p©epo‡et na offset v mapˆ
         xchg      ax,si                    ; SI <- offset v mapˆ
         or        byte ptr es:[si],bit1    ; p©¡znak vadn‚ho bloku

; ------ obnoven¡ zobrazen¡ hl ¨en¡

DiskVHl8:clc                                ; je pokra‡ov n¡ operace
DiskVHl9:pushf
         call      far ptr InfoDisp         ; obnoven¡ zobrazen¡ hl ¨en¡
         popf

; ------ n vrat registr–

         pop       es
         pop       dx
         pop       ax
         ret

DiskVHls ENDP

; *****************************************************************************
;
;                             Mapa disku
;
; *****************************************************************************
;þ
DiskMap  PROC      FAR

; ------ uzav©en¡ oken menu

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

; ------ otev©en¡ a na‡ten¡ mapy disku

         mov       word ptr ds:[DVDskDel],1 ; d‚lka kurzoru operace
         mov       word ptr ds:[DVDskOfs],-1 ; ukazatel se nezobraz¡
         call      OpenDMap                 ; otev©en¡ a na‡ten¡ mapy disku
         jc        DiskMap9                 ; chyba

         mov       si,offset DMMnuLin       ; menu mapy disku
         call      far ptr OpenMnu          ; otev©en¡ okna
         call      far ptr KurzOff          ; vypnut¡ kurzoru
         call      far ptr InpChar          ; vstup znaku z kl vesnice
         call      far ptr ClosMnu          ; uzav©en¡ okna menu

DiskMap9:call      ClosDMap                 ; uzav©en¡ mapy disku
         jmp       far ptr Main0

DiskMap  ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ a na‡ten¡ mapy disku (CY=chyba)
; -----------------------------------------------------------------------------

OpenDMap PROC      NEAR

; ------ hl ¨en¡ o na‡¡t n¡ struktury disku

         mov       si,offset DMMnTxt
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ ozna‡en¡ disku

         mov       al,ds:[AktPath]
         mov       ds:[DMMnLTi1],al         ; aktivn¡ disk
         mov       ds:[DVMnLTi1],al

; ------ inicializace parametr– aktivn¡ho disku

         call      far ptr InitLDsk         ; inicializace parametr– disku
         jc        OpenDM33                 ; chyba

; ------ p©¡prava parametr– pro menu

         mov       ah,0
         mov       al,ds:[Radku]            ; po‡et © dk– displeje
         sub       ax,10                    ; asi tolik se nepou‘ije
         mov       ds:[DMapVys],ax          ; v˜¨ka mapy disku
         xchg      ax,dx                    ; DX <- v˜¨ka mapy disku
         mov       ah,0
         mov       al,ds:[Pozic]            ; po‡et pozic na © dek
         sub       ax,6                     ; asi tolik se nepou‘ije
         mov       ds:[DMapSir],ax          ; ¨¡©ka mapy displeje
         mul       dx                       ; velikost mapy
         mov       ds:[DMapSize],ax         ; velikost mapy disku

; ------ stanoven¡ po‡tu blok– na pozici (jsou ji‘ zaji¨tˆn‚ minim lnˆ 2 bloky)

         sub       ax,3                     ; rezerva pro syst‚movou oblast
         xchg      ax,cx                    ; CX <- po‡et zobrazen˜ch pozic
         mov       ax,ds:[DskLNBlk]         ; celkov˜ po‡et aloka‡n¡ch blok–
         xor       dx,dx                    ; DX <- 0
         dec       ax                       ; p©ednastaven¡-1 (pro zaokrouhlen¡)
         add       ax,cx                    ; zaokrouhlen¡ nahoru (je ji‘ "-1")
         adc       dx,dx                    ; p©enos HIGH
         div       cx                       ; v˜po‡et po‡tu blok– na pozici
         mov       ds:[DMapBlk],ax          ; po‡et blok– na pozici

; ------ otev©en¡ bufferu tabulky FAT (hl s¡ chybu pamˆti)

         call      far ptr ResDisk          ; resetov n¡ diskov‚ho syst‚mu
         call      far ptr OpenLFat         ; otev©en¡ bufferu tabulky FAT
         jc        OpenDM33                 ; nedostatek pamˆti

; ------ vytvo©en¡ segmentu mapy

         call      far ptr CreatSeg         ; vytvo©en¡ segmentu mapy
         jc        OpenDM32                 ; chyba
         mov       ds:[DMapSeg],ax          ; segment mapy
         mov       bx,ds:[DMapSize]         ; velikost segmentu mapy
         call      far ptr ModiSegS         ; nastaven¡ velikosti segmentu
         jnc       OpenDM34                 ; pamˆŸ OK

; ------ chyba pamˆti

OpenDM32:call      far ptr MemErr           ; chyba pamˆti
OpenDM33:jmp       short OpenDMp9

; ------ vymaz n¡ segmentu mapy

OpenDM34:call      far ptr GetDat           ; adresa segmentu mapy
         xor       di,di                    ; DI <- 0 po‡ tek mapy
         xor       ax,ax                    ; AX <- 0 mazac¡ slovo
         mov       cx,bx                    ; CX <- velikost bufferu
         shr       cx,1                     ; velikost ve slovech
         cld
         rep       stosw                    ; vymaz n¡ segmentu mapy
         adc       cx,cx                    ; je lich˜ bajt ?
         rep       stosb                    ; lich˜ bajt

; ------ na‡ten¡ mapy disku

         xor       di,di                    ; ukl dac¡ adresa
         mov       bx,2                     ; ukazatel ‡¡sla bloku
         mov       cx,ds:[DMapBlk]          ; po‡et blok– na pozici mapy
OpenDMp4:
;test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
;         jnz       OpenDMp5                 ; pro CD disk je to v‘dy obsazen‚
         call      far ptr GetClust         ; poskytnut¡ ‡¡sla bloku
         jz        OpenDM52                 ; je to voln˜ aloka‡n¡ blok

         cmp       ax,0fff7h                ; je vadn˜ blok ?
         jne       OpenDMp5                 ; nen¡ to vadn˜ blok
         or        byte ptr es:[di],bit1    ; je vadn˜ blok
         jmp       short OpenDMp6

OpenDMp5:or        byte ptr es:[di],bit0    ; je obsazen˜ blok
         jmp       short OpenDMp6

OpenDM52:or        byte ptr es:[di],bit2    ; je voln˜ blok

OpenDMp6:dec       cx                       ; ‡¡ta‡ p©¡rustku adresy
         jnz       OpenDMp7                 ; nen¡ p©¡rustek adresy
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         mov       cx,ds:[DMapBlk]          ; po‡et blok– na pozici mapy

OpenDMp7:inc       bx                       ; zv˜¨en¡ ‡¡sla bloku
         cmp       bx,ds:[DskLMBlk]         ; byl to posledn¡ blok ?
         jbe       OpenDMp4                 ; test dal¨¡ho bloku
         cmp       cx,ds:[DMapBlk]          ; zapo‡at˜ dal¨¡ bajt ?
         je        OpenDM72                 ; nen¡ zapo‡at˜ dal¨¡ bajt
         inc       di                       ; v‡etnˆ posledn¡ho bajtu
OpenDM72:mov       ds:[DMapSegN],di         ; po‡et bajt– segmentu mapy
         clc                                ; p©¡znak operace OK
OpenDMp9:call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         ret

OpenDMap ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ mapy disku
; -----------------------------------------------------------------------------

ClosDMap PROC      NEAR

         mov       ax,ds:[DMapSeg]          ; segment mapy
         call      far ptr DelSeg           ; zru¨en¡ segmentu mapy
         mov       ds:[DMapSeg],ax
         call      far ptr ClosLFat         ; uzav©en¡ bufferu FAT
         ret

ClosDMap ENDP

; -----------------------------------------------------------------------------
;        inicializace menu mapy disku DS:SI
; -----------------------------------------------------------------------------

InitPMnu PROC      FAR

         mov       al,byte ptr ds:[DMapSir] ; ¨¡©ka mapy
         add       al,4                     ; p©i‡ten¡ okraj–
         mov       ds:[si+MnuSir],al        ; ¨¡©ka okna

         mov       al,byte ptr ds:[DMapVys] ; v˜¨ka mapy
         add       al,7                     ; p©i‡ten¡ okraj–
         mov       ds:[si+MnuVys],al        ; v˜¨ka okna

         call      far ptr CentMenu         ; vycentrov n¡ menu
         ret

InitPMnu ENDP

; *****************************************************************************
;        zobrazen¡ menu mapy disku DS:SI
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) © dek na displeji
;                   SS:[BP-2] (1) pozice na displeji
;                   SS:[BP-3] (1) ‡¡ta‡ vnit©n¡ch © dk– k zobrazen¡
;                   SS:[BP-4] (1) ¨¡©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen¡
;                   SS:[BP-8] (2) adresa segmentu mapy
;                   SS:[BP-10] (2) ukazatel adresy mapy
;                   SS:[BP-12] (2) ‡¡ta‡ bajt– mapy k zobrazen¡
;                   SS:[BP-13] (1) barva voln‚ pozice
;                   SS:[BP-14] (1) barva obsazen‚ pozice
;                   SS:[BP-15] (1) barva vadn‚ pozice
;                   SS:[BP-16] (1) barva ‡ ste‡nˆ pou‘it‚ pozice
;                   SS:[BP-18] (2) ‡¡ta‡ ukazatele operace verifikace
;                   SS:[BP-20] (2) znak ukazatele verifikace
;                   SS:[BP-21] (1) ‡¡ta‡ © dku se syst‚mov˜mi bloky
;                   SS:[BP-22] (1) barva syst‚mov‚ oblasti
;                   SS:[BP-24] (2) ‡¡ta‡ d‚lky kurzoru operace
; *****************************************************************************

DispPMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen¡ horn¡ a doln¡ linky

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©¡prava bufferu v z sobn¡ku

         sub       sp,24
         mov       al,ds:[si+MnuSir]        ; ¨¡©ka okna
         mov       ah,0
         shl       ax,1                     ; po‡et bajt– na © dek
         sub       sp,ax                    ; lok ln¡ buffer

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       ax,word ptr ds:[si+MnuPoz] ; © dek a pozice menu
         inc       ah                       ; po‡ te‡n¡ © dek
         mov       ss:[bp-2],ax             ; © dek a pozice k zobrazen¡
         mov       ax,word ptr ds:[si+MnuSir] ; ¨¡©ka a v˜¨ka okna
         sub       ah,6                     ; vnit©n¡ v˜¨ka okna
         mov       ss:[bp-4],ax             ; ¨¡©ka a v˜¨ka okna
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen¡
         mov       ah,0
         mov       ss:[bp-6],ax             ; hladina k zobrazen¡
         mov       ax,ds:[DMapSeg]          ; adresa segmentu mapy
         call      far ptr GetSgAdr         ; adresa segmentu
         mov       ss:[bp-8],dx             ; adresa segmentu mapy
         mov       word ptr ss:[bp-10],0    ; ukazatel adresy mapy
         mov       ax,ds:[DMapSegN]         ; po‡et bajt– segmentu mapy
         mov       ss:[bp-12],ax            ; ‡¡ta‡ bajt– mapy k zobrazen¡
         mov       al,ds:[ColDMapF]         ; barva voln‚ pozice
         mov       ss:[bp-13],al            ; barva voln‚ pozice
         mov       al,ds:[ColDMapC]         ; barva obsazen‚ pozice
         mov       ss:[bp-14],al            ; barva obsazen‚ pozice
         mov       al,ds:[ColDMapB]         ; barva vadn‚ pozice
         mov       ss:[bp-15],al            ; barva vadn‚ pozice
         mov       al,ds:[ColDMapP]         ; barva ‡ ste‡nˆ pou‘it‚ pozice
         mov       ss:[bp-16],al            ; barva ‡ ste‡nˆ pou‘it‚ pozice
         mov       ax,ds:[DVDskOfs]         ; offset verifikace
         inc       ax                       ; p©ednastaven¡
         mov       ss:[bp-18],ax            ; ‡¡ta‡ ukazatele verifikace
         mov       al,"V"
         mov       ah,ds:[ColDMapV]
         mov       ss:[bp-20],ax            ; indik tor operace verifikace
         mov       ah,1                     ; ‡¡ta‡ syst‚mov‚ho © dku
;         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
;         jz        DispM002                 ; nen¡ to CD disk
;         mov       ah,0                     ; nen¡ syst‚mov˜ © dek
DispM002:mov       al,ds:[ColDMapS]         ; barva syst‚mov‚ oblasti
         mov       ss:[bp-22],ax
         mov       ax,ds:[DVDskDel]         ; d‚lka kurzoru operace
         mov       ss:[bp-24],ax            ; d‚lka kurzoru operace

; ------ dek¢dov n¡ po‡tu blok– na pozici

         push      ds
         pop       es
         mov       di,offset DMMnLPlN+1
         mov       ax,ds:[DMapBlk]          ; po‡et blok– na pozici
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         sub       di,offset DMMnLPlN+1
         xchg      ax,di
         mov       ds:[DMMnLPlN],al         ; d‚lka textu

; ------ p©¡prava textu po‡tu blok–

         mov       word ptr ds:[DMMnLPl1],offset DMMnLPl2 ; 1 blok
         dec       di
         jz        DispPMn0                 ; je 1 blok
         mov       word ptr ds:[DMMnLPl1],offset DMMnLPl3 ; 2, 3 a 4 bloky
         sub       di,4-1
         jbe       DispPMn0                 ; jsou 2, 3 nebo 4 bloky
         mov       word ptr ds:[DMMnLPl1],offset DMMnLPl4 ; jinak 5 a v¡ce blok–

; ------ vymaz n¡ bufferu © dku

DispPMn0:mov       ch,0
DispPMn1:call      DispP0Mn                 ; vymaz n¡ © dku

; ------ p©¡prava k dek¢dov n¡ © dku mapy

         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         sub       cl,4                     ; bez okraj–
         mov       di,sp
         add       di,2*2                   ; adresa k dek¢dov n¡

         push      ds
         lds       si,ss:[bp-10]            ; adresa mapy
         cmp       cx,ss:[bp-12]            ; zb˜v  m‚nˆ pozic ?
         jbe       DispPMn2                 ; po‡et pozic je OK
         mov       cx,ss:[bp-12]            ; omezen¡ po‡tu pozic

; ------ dek¢dov n¡ syst‚mov‚ oblasti

DispPMn2:dec       byte ptr ss:[bp-21]      ; je to syst‚mov˜ © dek ?
         jnz       DispPM28                 ; nen¡ to syst‚mov˜ © dek
         sub       cx,3                     ; sn¡‘en¡ po‡tu blok–

         mov       al,"B"                   ; znak pro BOOT
         call      DispPSys                 ; ulo‘en¡ znaku

         mov       al,"F"                   ; znak pro FAT
         call      DispPSys                 ; ulo‘en¡ znaku

         mov       al,"R"                   ; znak pro ROOT
         call      DispPSys                 ; ulo‘en¡ znaku

DispPM28:jcxz      DispPMn5                 ; nen¡ dal¨¡ pozice
         sub       ss:[bp-12],cx            ; sn¡‘en¡ zbyl˜ch pozic

; ------ dek¢dov n¡ © dku mapy

DispPMn3:lodsb                              ; znak mapy
         test      al,bit1                  ; je to vadn˜ blok ?
         mov       ah,ss:[bp-15]            ; barva vadn‚ho bloku
         mov       al,"x"                   ; ozna‡en¡ vadn‚ho bloku
         jnz       DispPMn4                 ; je vadn˜ blok
         mov       ah,ss:[bp-14]            ; barva obsazen‚ pozice
         mov       al,7                     ; znak obsazen‚ pozice
         test      byte ptr ds:[si-1],bit2  ; jsou voln‚ bloky ?
         jz        DispPMn4                 ; je to plnˆ obsazen˜ blok
         mov       ah,ss:[bp-13]            ; barva voln‚ pozice
         mov       al,"."                   ; znak voln‚ pozice
         test      byte ptr ds:[si-1],bit0  ; jsou obsazen‚ bloky ?
         jz        DispPMn4                 ; je to plnˆ voln˜ blok
         mov       ah,ss:[bp-16]            ; barva ‡ ste‡nˆ pou‘it‚ pozice
         mov       al,"±"                   ; znak ‡ ste‡nˆ obsazen‚ pozice
DispPMn4:dec       word ptr ss:[bp-18]      ; ‡¡ta‡ operace verifikace
         jnz       DispPM42                 ; nen¡ verifikace
         call      DispPSy2
         jmp       short DispPM44

DispPM42:stosw                              ; ulo‘en¡ znaku
DispPM44:loop      DispPMn3                 ; dal¨¡ pozice na © dku

; ------ zobrazen¡ © dku mapy

DispPMn5:mov       ss:[bp-10],si            ; ukazatel mapy
         pop       ds                       ; datov˜ segment

         mov       si,sp
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       dx,ss:[bp-2]             ; © dek a pozice na displeji
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         push      dx
         call      far ptr DispMStr         ; zobrazen¡ © dku
         pop       dx

; ------ p©¡prava pro dal¨¡ © dek

         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatel © dk–
         dec       byte ptr ss:[bp-3]       ; ‡¡ta‡ © dk– k zobrazen¡
         jz        DispPMn6                 ; jsou ji‘ v¨echny © dky
         jmp       DispPMn1                 ; zobrazen¡ dal¨¡ho © dku

; ------ informa‡n¡ © dek - po‡et blok– na pozici

DispPMn6:inc       dh                       ; zv˜¨en¡ ukazatele © dku
         mov       si,offset DMMnLPol
         call      far ptr DispTxtM         ; zobrazen¡ informa‡n¡ho © dku

; ------ pr zdn˜ © dek

         inc       dh                       ; zv˜¨en¡ ukazatele © dku
         cmp       word ptr ds:[DVDskOfs],-1 ; je zapnut kurzor operace ?
         je        DispPM66                 ; nen¡ zapnut kurzor

         mov       si,offset DMMnLPSk
         call      far ptr DispTxtM         ; zobrazen¡ textu
         jmp       short DispPM68

DispPM66:call      DispP0Mn                 ; vymaz n¡ © dku
         mov       si,sp                    ; buffer v z sobn¡ku
         push      dx
         call      far ptr DispMStr         ; zobrazen¡ © dku
         pop       dx

; ------ text vysvˆtlivek 1

DispPM68:call      DispP0Mn                 ; vymaz n¡ © dku
         mov       si,offset DMMnLPl5
         mov       di,sp
         add       di,ds:[DMapSir]
         add       di,4
         sub       di,offset (DMMnLPl6-DMMnLPl5)
         shr       di,1
         shl       di,1

         push      di
         mov       cx,offset(DMMnLPl6-DMMnLPl5)
         mov       ah,ds:[ColMnu1]
         cld
DispMMn7:lodsb
         stosw
         loop      DispMMn7
         pop       di

; ------ korekce barev

         mov       al,ss:[bp-22]            ; barva syst‚mov‚ oblasti
         mov       es:[di+1],al             ; Boot
         mov       es:[di+10*2+1],al        ; FAT
         mov       es:[di+19*2+1],al        ; Root
         mov       al,ss:[bp-15]            ; barva vadn‚ho bloku
         mov       es:[di+29*2+1],al        ; barva vadn‚ho bloku

         mov       si,sp                    ; buffer v z sobn¡ku
         inc       dh                       ; zv˜¨en¡ ukazatele © dku
         push      dx
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         call      far ptr DispKStr         ; zobrazen¡ © dku
         pop       dx
         inc       dh                       ; zv˜¨en¡ ukazatele © dku

; ------ text vysvˆtlivek 2

         call      DispP0Mn                 ; vymaz n¡ © dku
         mov       si,offset DMMnLPl8
         mov       di,sp

         add       di,ds:[DMapSir]
         add       di,4
         sub       di,offset (DMMnLPl9-DMMnLPl8)
         shr       di,1
         shl       di,1

         push      di
         mov       cx,offset(DMMnLPl9-DMMnLPl8)
         mov       ah,ds:[ColMnu1]
         cld
DispMMn8:lodsb
         stosw
         loop      DispMMn8
         pop       di

; ------ korekce barev

         mov       al,ss:[bp-13]            ; barva voln‚ pozice
         mov       es:[di+1],al             ; barva voln‚ pozice
         mov       al,ss:[bp-16]            ; barva nezaplnˆn‚ pozice
         mov       es:[di+11*2+1],al        ; barva nezaplnˆn‚ pozice
         mov       al,ss:[bp-14]            ; barva obsazen‚ pozice
         mov       es:[di+27*2+1],al        ; barva obsazen‚ pozice

; ------ zobrazen¡ © dku vysvˆtlivek

         mov       si,sp
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         call      far ptr DispKStr         ; zobrazen¡ © dku

; ------ n vrat registr–

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispPMnu ENDP

; ------ ulo‘en¡ znaku verifikace

DispPSys:mov       ah,ss:[bp-22]            ; barva syst‚mov‚ oblasti
         dec       word ptr ss:[bp-18]      ; ‡¡ta‡ operace verifikace
         jnz       DispPSy4                 ; nen¡ verifikace
DispPSy2:mov       ax,ss:[bp-20]            ; znak verifikace
         dec       word ptr ss:[bp-24]      ; je vypnut¡ kurzoru ?
         jz        DispPSy4                 ; kurzor se vypnut
         inc       word ptr ss:[bp-18]      ; zapnut¡ pro p©¡¨tˆ
DispPSy4:stosw                              ; ulo‘en¡ znaku
         ret

; ------ vymaz n¡ © dku

DispP0Mn:push      ss
         pop       es
         mov       di,sp
         inc       di
         inc       di
         cld
         mov       ah,ds:[ColMnu1R]         ; bˆ‘n  barva okna menu
         mov       al,"³"                   ; "³"
         stosw                              ; lev˜ okraj
         push      cx
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         dec       cx
         dec       cx
         mov       al," "
         rep       stosw                    ; vnit©n¡ mezera
         pop       cx
         mov       ah,ds:[ColMnu1L]
         mov       al,"³"                   ; "³"
         stosw                              ; prav˜ okraj
         ret

; *****************************************************************************
;
;                       Zobrazen¡/editace obsahu disku
;
; *****************************************************************************
;þ
; ------ editace disku

EdiDisk  LABEL     FAR

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

;EdiDiskF LABEL     FAR

         mov       byte ptr ds:[DZAktMod],bit0 ; editace disku
         mov       word ptr ds:[DZMnuLin+MnuTitl],offset DEMnLTit ; editace
         mov       word ptr ds:[DZMnuLin+MnuHlp],offset DEMnLHlp ; editace
         jmp       short ZobDisk1


; ------ zobrazen¡ disku

ZobDisk  PROC      FAR

; ------ uzav©en¡ oken menu

         add       sp,4                     ; zru¨en¡ n vratov‚ adresy
         call      far ptr ClosMnuA         ; uzav©en¡ v¨ech oken menu

ZobDiskF LABEL     FAR

         mov       byte ptr ds:[DZAktMod],bit2 ; zobrazen¡ disku, ASCII pole
         mov       word ptr ds:[DZMnuLin+MnuTitl],offset DZMnLTit ; zobrazen¡
         mov       word ptr ds:[DZMnuLin+MnuHlp],offset DZMnLHlp ; zobrazen¡

; ------ ozna‡en¡ disku

ZobDisk1:mov       al,ds:[AktPath]
         mov       ds:[DZMnLTi1],al         ; aktivn¡ disk
         mov       ds:[DEMnLTi1],al         ; aktivn¡ disk
         and       byte ptr ds:[DZAktMod],not bit5 ; nen¡ hled n¡ ©etˆzce

; ------ vypnut¡ grafick‚ my¨i

         or        byte ptr ds:[ParMous2],bit3 ; z kaz grafick‚ my¨i
         call      far ptr RIniMous         ; reinicializace my¨i

; ------ otev©en¡ okna

         mov       word ptr ds:[DskLBSkt],512 ; implicitn¡ velikost sektoru
         xor       ax,ax
         mov       ds:[DZobBNum],ax         ; nejsou data
         mov       ds:[DZobBTop],ax         ; offset zobrazen‚ho po‡ tku
         mov       ds:[DZobBKur],ax         ; inicializace kurzoru na za‡ tek
         mov       si,offset DZMnuLin       ; menu zobrazen¡ disku
         call      far ptr OpenMnu          ; otev©en¡ okna

; ------ inicializace parametr– aktivn¡ho disku

         call      far ptr InitLDsk         ; inicializace parametr– disku
         jnc       ZobDisk3                 ; disk je p©ipraven OK

ZobDisk2:jmp       ZobDisk9

; ------ otev©en¡ bufferu FAT

ZobDisk3:call      far ptr OpenLFat         ; otev©en¡ bufferu tabulky FAT
         jc        ZobDisk2                 ; chyba
         call      far ptr ResDisk          ; resetov n¡ diskov‚ho syst‚mu

; ------ otev©en¡ bufferu adres ©e

         call      far ptr OpenLDir         ; otev©en¡ bufferu adres ©e
         jc        ZobDisk2                 ; chyba
         call      far ptr ResDisk          ; resetov n¡ diskov‚ho syst‚mu

; ------ vytvo©en¡ pracovn¡ho bufferu

         mov       bx,ds:[DskLBSkt]         ; po‡et bajt– na sektor disku
         shl       bx,1                     ; po‡et bajt– na 2 sektory
         jc        ZobDisk2                 ; p©¡li¨ velk˜ sektor
         shl       bx,1                     ; po‡et bajt– na 4 sektory
         jc        ZobDisk2                 ; p©¡li¨ velk˜ sektor
         call      far ptr CreatDat         ; vytvo©en¡ bufferu (velikost BX)
         jc        ZobDisk2                 ; chyba
         mov       ds:[DZobBSeg],ax         ; pracovn¡ buffer
         xchg      ax,bx                    ; AX <- velikost bufferu
         shr       ax,1                     ; velikost jedn‚ poloviny bufferu
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DskLBSkt]   ; po‡et sektor– v bufferu (polovina)
         mov       ds:[DZobBSek],ax         ; po‡et sektor– v polovinˆ bufferu
         mul       word ptr ds:[DskLBSkt]   ; zaokrouhlen  velikost bufferu
         mov       ds:[DZobBRef],ax         ; offset referen‡n¡ch dat v bufferu
         add       ax,ds:[DskLBSkt]         ; jeden sektor rezerva
         cmp       ax,ds:[DZobBV16]         ; sta‡¡ buffer na displej ?
         jb        ZobDisk2                 ; buffer nesta‡¡ k zobrazen¡

; ------ p©¡prava po‡ te‡n¡ho sektoru dat (DZobBNum nastaveno na 0)

         mov       ax,16                    ; po‡ te‡n¡ sektor pro CD-ROM
         test      byte ptr ds:[DskLPar],bit6 ; je to CD-disk ?
         jnz       ZobDsk51                 ; je to CD-disk
         call      far ptr GetAClus         ; aktivn¡ aloka‡n¡ blok
         jnc       ZobDisk5                 ; ‡¡slo bloku je OK
         xor       ax,ax                    ; n hradn¡ blok p©i chybˆ
ZobDisk5:xchg      ax,bx                    ; BX <- ‡¡slo aloka‡n¡ho bloku
         call      far ptr ClstSekt         ; p©epo‡et na absolutn¡ sektor DX:AX
         mov       cx,ds:[DskLBSkt]         ; velikost sektoru = adresa dat
         sub       ax,1                     ; 1 sektor rezerva od za‡ tku bufferu
         sbb       dx,0
         jnc       ZobDsk52                 ; nen¡ sektor 0
         xor       ax,ax                    ; AX <- 0 (sektor LOW)
ZobDsk51:xor       cx,cx                    ; CX <- 0 (offset dat v bufferu)
         xor       dx,dx                    ; DX <- 0 (sektor HIGH)
ZobDsk52:mov       word ptr ds:[DZobBBeg],ax ; po‡ te‡n¡ sektor v bufferu
         mov       word ptr ds:[DZobBBeg+2],dx
         mov       ds:[DZobBTop],cx         ; zobrazen˜ po‡ tek
         mov       ds:[DZobBKur],cx         ; kurzor

; ------ na‡ten¡ bufferu

         call      far ptr ResDisk          ; resetov n¡ diskov‚ho syst‚mu
         call      ZobDRead                 ; na‡ten¡ obsahu bufferu
         call      ZobDModi                 ; nulov n¡ modifikace dat

; ------ zobrazen¡ okna

ZobDisk6:call      ZobDNorm                 ; normalizace bufferu
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         mov       si,offset DZMnuLin       ; menu zobrazen¡ disku
         call      far ptr DispMnu          ; zobrazen¡ okna

; ------ vstup znaku z kl vesnice
; Sem se vrac¡ s EdZChr !

ZobDisk7:mov       si,offset DZMnuLin       ; menu zobrazen¡ disku
         call      DispZDK                  ; zobrazen¡ kurzoru
         call      far ptr NulBreak         ; nulov n¡ p©¡znaku p©eru¨en¡
         call      far ptr InpChar          ; vstup znaku z kl vesnice

         mov       di,offset DEMnLHlM       ; menu pro editaci
         test      byte ptr ds:[DZAktMod],bit0 ; je m¢d editace ?
         jnz       ZobDsk72                 ; je m¢d editace
         mov       di,offset DZMnLHlM       ; menu pro zobrazen¡
ZobDsk72:call      far ptr MenKlHlp         ; obsluha menu kl ves mal‚ n povˆdy

         cmp       bx,MousXKod+MousXRP      ; stisk prav‚ho tla‡¡tka my¨i ?
         je        ZobDisk8                 ; p©eru¨en¡ prav˜m tla‡¡tkem my¨i
         cmp       bl,27                    ; Esc
         je        ZobDisk8                 ; je Esc
         call      EdZDisk                  ; obsluha disku
         jmp       short ZobDisk6

ZobDisk8:call      ZobDWrit                 ; ulo‘en¡ dat
         jc        ZobDisk6

; ------ uzav©en¡ re‘imu editace/zobrazen¡ disku

ZobDisk9:call      far ptr ClosMnu          ; uzav©en¡ okna menu
         and       byte ptr ds:[ParMous2],not bit3 ; zru¨en¡ z kazu grafick‚ my¨i
         call      far ptr RIniMous         ; reinicializace my¨i
         mov       ax,ds:[DZobBSeg]         ; segment prohl¡‘e‡e
         call      far ptr DelSeg           ; zru¨en¡ segmentu
         mov       ds:[DZobBSeg],ax
         call      far ptr ClosLFat         ; uzav©en¡ bufferu FAT
         call      far ptr ClosLDir         ; uzav©en¡ bufferu adres ©e
         jmp       far ptr Main0

ZobDisk  ENDP

; -----------------------------------------------------------------------------
;        obsluha ovl d n¡ zobrazen¡/editace disku (SI=definice okna)
; -----------------------------------------------------------------------------
;þ
EdZDisk  PROC      NEAR

         call      far ptr JumpBX

         dw        3c00h,ZobDWrit           ; F2 z pis dat
         dw        3f00h,ZobDVlas           ; F5 vlastn¡k
         dw        4000h,ZobDSkok           ; F6 skok
         dw        4100h,ZobDHled           ; F7 hledej

         dw        5a00h,ZobDHlCL           ; Shift-F7
         dw        260ch,ZobDHlCL           ; Ctrl-L

         dw        4b00h,EdZLeft            ; vlevo
         dw        4d00h,EdZRght            ; vpravo
         dw        4800h,EdZUp              ; nahoru
         dw        5000h,EdZDown            ; dol–

         dw        7300h,EdZCLft            ; Ctrl-vlevo
         dw        7400h,EdZCRgh            ; Ctrl-vpravo

         dw        4700h,EdZHome            ; Home
         dw        4f00h,EdZEnd             ; End
         dw        7700h,EdZCPgUp           ; Ctrl-Home
         dw        7500h,EdZCPgDn           ; Ctrl-End

         dw        4900h,EdZPgUp            ; PageUp
         dw        5100h,EdZPgDn            ; PageDown
         dw        8400h,EdZCPgUp           ; Ctrl-PageUp
         dw        7600h,EdZCPgDn           ; Ctrl-PageDown

         dw        1709h,EdZTab             ; Ctrl-I
         dw        0f09h,EdZTab             ; TAB
         dw        0f00h,EdZTab             ; Shift-Tab

         dw        0e08h,EdZBS              ; BS
         dw        5300h,EdZDel             ; Delete

         dw        MousXKod+MousXMov,EdZMous ; pohyb my¨¡
         dw        MousXKod+MousXLP,EdZMous ; stisk lev‚ho tla‡¡tka my¨i
         dw        MousXKod+MousXLH,EdZMous ; dr‘en¡ lev‚ho tla‡¡tka my¨i

         dw        0,EdZChr                 ; znak

EdZDisk  ENDP

; -----------------------------------------------------------------------------
;        veden¡ kurzoru my¨¡
; -----------------------------------------------------------------------------

EdZMous  PROC      NEAR

; ------ pozice my¨i relativnˆ v oknˆ -> DX

         mov       ax,word ptr ds:[DZMnuLin+MnuPoz]  ; © dek a pozice okna menu
         add       ax,20Bh                  ; p©i‡ten¡ okraj–
         mov       dx,ds:[MousePoz]         ; © dek a pozice kurzoru my¨i
         sub       dl,al                    ; pozice relativnˆ
         jnc       EdZMous2
         mov       dl,0
EdZMous2:sub       dh,ah                    ; © dek relativnˆ
         jnc       EdZMous3
         mov       dh,0

; ------ nulov n¡ kurzoru

EdZMous3:mov       ax,ds:[DZobBTop]         ; offset zobrazen‚ho po‡ tku
         mov       ds:[DZobBKur],ax         ; kurzor na za‡ tek str nky
         and       byte ptr ds:[DZAktMod],not bit3 ; aktivn¡ 1. znak HEX

; ------ nastaven¡ kurzoru pro ASCII pole

         mov       al,16
         mul       dh                       ; p©epo‡et © dku na offset
         xchg      ax,dx                    ; DX <- offset © dku, AL <- pozice
         mov       ah,0
         cmp       al,16*2 + 15 + 1 + 2 + 1 + 1 ; je ASCII pole ?
         jb        EdZMous5                 ; nen¡ ASCII pole
         or        byte ptr ds:[DZAktMod],bit2 ; je ASCII pole
         sub       al,16*2 + 15 + 1 + 2 + 1 + 1
         cmp       al,15
         jbe       EdZMous4
         mov       al,15
EdZMous4:add       ax,dx                    ; offset kurzoru
         add       ds:[DZobBKur],ax         ; kurzor
         ret

; ------ korekce oddˆlova‡– HEX pole

EdZMous5:cmp       al,4*2 + 3 + 1           ; je za 1/4 ?
         jb        EdZMous6
         dec       ax
EdZMous6:cmp       al,8*2 + 7 + 1           ; je za polovinou ?
         jb        EdZMous7                 ; nen¡ za polovinou
         dec       ax                       ; odstranˆn¡ oddˆlova‡e v polovinˆ
         dec       ax
EdZMous7:cmp       al,12*2 + 11             ; je za 3/4 ?
         jb        EdZMous8
         dec       ax                       ; odstranˆn¡ oddˆlova‡e
EdZMous8:mov       cl,3                     ; dˆlitel
         div       cl                       ; v˜po‡et offsetu
         or        ah,ah                    ; je 2. znak HEX ?
         jz        EdZMous9                 ; je 1. znak HEX
         or        byte ptr ds:[DZAktMod],bit3 ; je 2. znak HEX
EdZMous9:mov       ah,0
         and       byte ptr ds:[DZAktMod],not bit2 ; je HEX pole
         jmp       short EdZMous4           ; nastaven¡ kurzoru

EdZMous  ENDP

; -----------------------------------------------------------------------------
;        zad n¡ znaku nebo neplatn  kl vesa
; -----------------------------------------------------------------------------

EdZChr   PROC      NEAR

; ------ test, zda je platn˜ znak ASCII

         cmp       bx,300h
         je        EdZChr2                  ; Ctrl-@
         cmp       bh,MousXKod/HI           ; je k¢d my¨i ?
         je        EdZChr9                  ; je k¢d my¨i
         or        bx,bx                    ; je Ctrl-Break ?
         jz        EdZChr9                  ; Ctrl-Break neplat¡
         cmp       bh,0
         je        EdZChr2                  ; znak s Alt-‡¡slo
         cmp       bl," "
         jb        EdZChr9                  ; neplatn  kl vesa

; ------ adresa znaku v bufferu

EdZChr2: call      GetZBSeg                 ; adresa bufferu
         mov       si,ds:[DZobBKur]         ; offset kurzoru
         cmp       si,ds:[DZobBNum]         ; je platn  adresa kurzoru ?
         jae       EdZChr9                  ; nen¡ platn  adresa kurzoru

; ------ test, zda je ASCII pole

         test      byte ptr ds:[DZAktMod],bit2 ; je ASCII pole ?
         jnz       EdZChr7                  ; je ASCII pole

; ------ konverze na velk‚ p¡smeno

         xchg      ax,bx
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         xchg      ax,bx

; ------ test, zda je platn˜ znak HEX

         sub       bl,"0"
         jb        EdZChr9                  ; neplatn˜ znak
         cmp       bl,9
         jbe       EdZChr4
         sub       bl,7
         cmp       bl,9
         jbe       EdZChr9                  ; neplatn˜ znak
         cmp       bl,15
         ja        EdZChr9

; ------ nov˜ znak na pozici kurzoru

EdZChr4: mov       al,es:[si]               ; p–vodn¡ znak na pozici kurzoru
         mov       ah,0f0h                  ; maska p–vodn¡ho znaku
         test      byte ptr ds:[DZAktMod],bit3 ; je 1. znak HEX ?
         jnz       EdZChr5                  ; je 2. znak HEX
         mov       ah,0fh                   ; maska p–vodn¡ho znaku
         mov       cl,4
         shl       bl,cl
EdZChr5: and       al,ah                    ; maskov n¡ p–vodn¡ho znaku
         or        bl,al                    ; nov˜ znak

; ------ vlo‘en¡ znaku do bufferu

EdZChr7: test      byte ptr ds:[DZAktMod],bit0 ; povolena editace ?
         jz        EdZChr8                  ; editace nen¡ povolena
         mov       es:[si],bl               ; vlo‘en¡ znaku do bufferu

         add       si,ds:[DZobBRef]         ; data v referen‡n¡m bufferu
         cmp       bl,es:[si]               ; je bajt rozd¡ln˜ ?
         je        EdZChr72                 ; bajt je shodn˜
         test      byte ptr ds:[DZAktMod],bit1 ; jsou data ji‘ modifikov na ?
         jnz       EdZChr8                  ; data jsou ji‘ modifikov na
         jmp       short EdZChr74           ; test modifikace

EdZChr72:test      byte ptr ds:[DZAktMod],bit1 ; je modifikace zru¨ena ?
         jz        EdZChr8                  ; modifikace je ji‘ zru¨ena
EdZChr74:call      ZobDModi                 ; test modifikace dat
EdZChr8: jmp       EdZRght                  ; posun kurzoru vpravo

; ------ neplatn˜ znak - n vrat bez zobrazen¡ okna

EdZChr9: pop       ax                       ; zru¨en¡ n vratov‚ adresy
         jmp       ZobDisk7

EdZChr   ENDP

; -----------------------------------------------------------------------------
;        Delete obnoven¡ znaku
; -----------------------------------------------------------------------------

EdZDel   PROC      NEAR

         call      EdZBS1                   ; obnoven¡ znaku za kurzorem
         jmp       EdZRght                  ; posun kurzoru vpravo

EdZDel   ENDP

; -----------------------------------------------------------------------------
;        BS obnoven¡ znaku
; -----------------------------------------------------------------------------

EdZBS    PROC      NEAR

; ------ posun kurzoru vlevo

         call      EdZLeft                  ; posun kurzoru vlevo
         call      ZobDNorm                 ; normalizace bufferu
         jc        EdZBs6                   ; p©eru¨en¡

; ------ adresa kurzoru

EdZBS1:  call      GetZBSeg                 ; adresa bufferu -> ES
         mov       si,ds:[DZobBKur]         ; offset kurzoru
         cmp       si,ds:[DZobBNum]         ; je platn  adresa kurzoru ?
         jae       EdZBS6                   ; nen¡ platn  adresa kurzoru
         mov       bx,ds:[DZobBRef]         ; offset referen‡n¡ho bufferu

; ------ n vrat znaku ASCII

         mov       al,es:[si+bx]            ; p–vodn¡ znak
         test      byte ptr ds:[DZAktMod],bit2 ; je ASCII pole ?
         jz        EdZBS2                   ; nen¡ ASCII pole
         mov       es:[si],al               ; n vrat znaku
         jmp       short EdZBS54

; ------ n vrat znaku HEX - druh˜ znak

EdZBS2:  test      byte ptr ds:[DZAktMod],bit3 ; je 2. znak HEX ?
         jz        EdZBS4                   ; je 1. znak HEX
         and       al,0fh                   ; p–vodn¡ 2. znak
         and       byte ptr es:[si],0f0h    ; zru¨en¡ p–vodn¡ho 2. znaku
         jmp       short EdZBS5

; ------ n vrat znaku HEX - prvn¡ znak

EdZBS4:  and       al,0f0h                  ; p–vodn¡ 1. znak
         and       byte ptr es:[si],0fh     ; zru¨en¡ p–vodn¡ho 1. znaku
EdZBS5:  or        es:[si],al               ; n vrat znaku
EdZBS54: test      byte ptr ds:[DZAktMod],bit1 ; je modifikace zru¨ena ?
         jz        EdZBS6                   ; modifikace je ji‘ zru¨ena
         call      ZobDModi                 ; test modifikace dat

EdZBS6:  ret

EdZBS    ENDP

; -----------------------------------------------------------------------------
;        tabul tor
; -----------------------------------------------------------------------------

EdZTab   PROC      NEAR

         xor       byte ptr ds:[DZAktMod],bit2 ; zmˆna aktivn¡ho pole
         and       byte ptr ds:[DZAktMod],not bit3 ; aktivn¡ 1. znak HEX
EdZTab9: ret

EdZTab   ENDP

; -----------------------------------------------------------------------------
;        F5 vlastn¡k
; -----------------------------------------------------------------------------

ZobDVlas PROC      NEAR

         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jnz       ZobDVls1                 ; je to CD disk

; ------ ‡¡slo aktu ln¡ho sektoru -> DX:AX

         mov       ax,ds:[DZobBKur]         ; offset kurzoru v bufferu
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DskLBSkt]   ; p©epo‡et na offset v sektorech
         xor       dx,dx                    ; DX <- 0
         add       ax,word ptr ds:[DZobBBeg] ; v˜po‡et ‡¡sla sektoru kurzoru
         adc       dx,word ptr ds:[DZobBBeg+2] ; sektor kurzoru HIGH

; ------ ‡¡slo hledan‚ho aktu ln¡ho bloku -> BP

         sub       ax,ds:[DskLBDat]         ; offset od datov‚ho sektoru
         sbb       dx,0
         jnc       ZobDVls2                 ; ‡¡slo sektoru je OK
ZobDVls1:jmp       ZobDVls9

ZobDVls2:cmp       dx,ds:[DskLSBlk]         ; bylo by p©ete‡en¡ ?
         jae       ZobDVls1                 ; bylo by p©ete‡en¡
         div       word ptr ds:[DskLSBlk]   ; v˜po‡et ‡¡sla bloku relativnˆ
         inc       ax
         inc       ax                       ; korekce - ‡¡slo po‡ te‡n¡ho bloku
         mov       bp,ax                    ; BP <- £schova aktu ln¡ho bloku

; ------ dek¢dov n¡ ‡¡sla bloku do bufferu

         push      ds
         pop       es                       ; ES <- DS
         mov       bl,ds:[OddelRad]
         mov       bh,0
         mov       di,offset DZVMnPl2+1     ; buffer ‡¡sla bloku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla bloku
         xchg      ax,di
         sub       ax,offset DZVMnPl2+1     ; d‚lka textu
         mov       ds:[DZVMnPl2],al         ; d‚lka textu

; ------ zobrazen¡ informa‡n¡ho textu

         mov       si,offset DZVMnTx1       ; informa‡n¡ text o vyhled v n¡
         call      far ptr InfDisp0         ; zobrazen¡ informa‡n¡ho textu

; ------ obsah aloka‡n¡ho bloku

         mov       bx,bp                    ; BX <- ‡¡slo aloka‡n¡ho bloku
         call      far ptr GetClust         ; poskytnut¡ aloka‡n¡ho bloku

; ------ test, zda je blok voln˜

         mov       word ptr ds:[DZVMnPl1],offset DZVMnPl3 ; voln˜ blok
         jz        ZobDVl54                 ; voln˜ aloka‡n¡ blok

; ------ test, zda je vadn˜ aloka‡n¡ blok

         mov       word ptr ds:[DZVMnPl1],offset DZVMnPl4 ; vadn˜ blok
         cmp       ax,0fff7h                ; je to vadn˜ aloka‡n¡ blok ?
         je        ZobDVl54                 ; je to vadn˜ aloka‡n¡ blok

; ------ nalezen¡ p©ede¨l‚ho aloka‡n¡ho bloku -> BP

         mov       dx,ds:[DskLNBlk]         ; celkov˜ po‡et blok–
ZobDVl32:mov       cx,ds:[DskLNBlk]         ; celkov˜ po‡et blok–
ZobDVls3:dec       bx                       ; sn¡‘en¡ ukazatele bloku
         cmp       bx,2                     ; je podte‡en¡ ?
         jae       ZobDVls4                 ; blok je je¨tˆ platn˜
         mov       bx,ds:[DskLMBlk]         ; maxim ln¡ ‡¡slo bloku
ZobDVls4:call      far ptr GetClust         ; poskytnut¡ ‡¡sla bloku -> AX
         cmp       ax,bp                    ; je to hledan˜ blok ?
         loopne    ZobDVls3                 ; nen¡ hledan˜ blok - dal¨¡
         jne       ZobDVls6                 ; dal¨¡ blok nenalezen
         mov       bp,bx                    ; BP <- nov˜ blok v ©etˆzci
         call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        ZobDVls5                 ; p©eru¨en¡ operace
         dec       dx                       ; ‡¡ta‡ nalezen˜ch blok–
         jnz       ZobDVl32                 ; dal¨¡ pokus

; ------ vlastn¡k bloku nenalezen (nebo zacyklen¡ FAT)

ZobDVls5:mov       word ptr ds:[DZVMnPl1],offset DZVMnPl5 ; nenalezen
ZobDVl54:jmp       short ZobDVls7

; ------ nalezen¡ bloku v souborech

ZobDVls6:call      far ptr IniLDir          ; inicializace ukazatel– adres ©e
         jc        ZobDVls5                 ; chyba
ZobDVl61:call      far ptr NextLDir         ; nalezen¡ dal¨¡ polo‘ky
         jc        ZobDVl62                 ; konec adres ©e
         cmp       byte ptr es:[si],0       ; konec adres ©e ?
         je        ZobDVl62                 ; konec adres ©e
         cmp       byte ptr es:[si],0e5h    ; zru¨en  polo‘ka ?
         je        ZobDVl61                 ; zru¨en  polo‘ka neplat¡
         cmp       word ptr es:[si]," ."    ; aktivn¡ adres © ?
         je        ZobDVl61                 ; aktivn¡ adres ©
         cmp       es:[si+1ah],bp           ; souhlas¡ blok ?
         je        ZobDVl66                 ; blok souhlas¡ OK
         jmp       short ZobDVl61           ; dal¨¡ polo‘ka

ZobDVl62:call      far ptr TestBEsc
         jc        ZobDVl88                 ; p©eru¨en¡ operace
         call      far ptr ResLDir          ; resetov n¡ ukazatele
         jc        ZobDVls5
         call      far ptr SrcLDir          ; dal¨¡ adres ©
         jnc       ZobDVl61                 ; dal¨¡ adres ©
         jmp       short ZobDVls5           ; vlastn¡k nenalezen

; ------ zaji¨tˆn¡ oddˆlovac¡ho znaku "\"

ZobDVl66:mov       di,ds:[DskLDirN]         ; d‚lka textu adres ©e
         add       di,offset DskLDir        ; adresa konce textu adres ©e
         cmp       byte ptr ds:[di-1],"\"   ; je ji‘ koncov˜ "\" ?
         je        ZobDVl67                 ; je ji‘ koncov˜ znak "\"
         mov       byte ptr ds:[di],"\"     ; oddˆlovac¡ znak "\"
         inc       di

; ------ p©id n¡ jm‚na adres ©e k cestˆ

ZobDVl67:push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- polo‘ka FCB
         pop       es                       ; ES <- buffer k dek¢dov n¡
         call      far ptr FileAsc          ; dek¢dov n¡ jm‚na adres ©e
         pop       ds
         sub       di,offset DskLDir        ; nov  d‚lka textu adres ©e
         xchg      ax,di
         mov       ds:[DskLDir0],al

; ------ parametry menu

         mov       word ptr ds:[DZVMnPl1],offset DskLDir0 ; soubor/adres ©
         add       al,6
         cmp       al,45
         jae       ZobDVls8

ZobDVls7:mov       al,45
ZobDVls8:mov       si,offset DZVMnLin
         mov       ds:[si+MnuSir],al
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr Lin0Menu         ; zobrazen¡ vlastn¡ka
ZobDVl88:call      far ptr FlushChr
ZobDVls9:call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         ret

ZobDVlas ENDP

; -----------------------------------------------------------------------------
;        F6 skok
; -----------------------------------------------------------------------------

ZobDSkok PROC      NEAR

; ------ ulo‘en¡ obsahu bufferu

         call      ZobDWrit                 ; ulo‘en¡ obsahu bufferu
         jnc       ZobDSko2                 ; operace OK
ZobDSko1:ret

; ------ zad n¡ skoku

ZobDSko2:mov       si,offset DZSMSLin
         call      far ptr Lin0Menu         ; zad n¡ c¡sle skoku
         jc        ZobDSko1                 ; p©eru¨en¡ operace

; ------ p©¡prava k dek¢dov n¡ zad n¡

         mov       si,offset LinBuff        ; buffer textu
         mov       ch,0
         mov       cl,ds:[LinNum]           ; po‡et bajt– v buffeur

; ------ na‡ten¡ prvn¡ho znaku

ZobDSko3:call      far ptr RozXPCh          ; na‡ten¡ prvn¡ho znaku
         jc        ZobDSko1                 ; nen¡ niic zad no
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno

; ------ BOOT sektor

         xor       di,di                    ; offset kurzoru
         xor       bx,bx                    ; sektor DX:BX
         xor       dx,dx
         cmp       al,"B"
         je        ZobDSo48                 ; je BOOT sektor

; ------ FAT

         cmp       al,"F"
         jne       ZobDSo46
         call      ZobDSkN                  ; ‡¡slo FAT
         or        dx,dx
         jz        ZobDSko4
         mov       bx,-1
ZobDSko4:or        bh,bh
         jz        ZobDSo43
         mov       bx,255
ZobDSo43:cmp       bl,ds:[DskLNFat]         ; po‡et tabulek FAT
         jbe       ZobDSo44
         mov       bl,ds:[DskLNFat]         ; omezen¡ ‡¡sla FAT
ZobDSo44:mov       cx,bx                    ; CX <- ‡¡slo FAT
         mov       bx,ds:[DskLBFat]         ; po‡ te‡n¡ sektor FAT
         xor       dx,dx                    ; DX <- 0
         jcxz      ZobDSko8                 ; je FAT 1
         dec       cx                       ; korekce
         jcxz      ZobDSko8                 ; je FAT 1
ZobDSo45:add       bx,ds:[DskLSFat]         ; dal¨¡ FAT
         adc       dx,0
         loop      ZobDSo45
         jmp       short ZobDSko8

; ------ ROOT

ZobDSo46:mov       bx,ds:[DskLBRot]         ; po‡ te‡n¡ sektor ROOT
         cmp       al,"R"
         je        ZobDSko8                 ; je ROOT

; ------ sektor

         cmp       al,"S"
         jne       ZobDSko5
         call      ZobDSkN                  ; na‡ten¡ ‡¡sla
         jc        ZobDSo60
ZobDSo48:jmp       short ZobDSko8

; ------ offset

ZobDSko5:cmp       al,"O"
         jne       ZobDSko6
         call      ZobDSkN                  ; na‡ten¡ ‡¡sla
         jc        ZobDSo60

         mov       di,bx                    ; po‘adovan˜ offset LOW
         mov       ax,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         dec       ax                       ; maska offsetu v sektoru
         and       di,ax                    ; zamaskov n¡ offsetu v sektoru
         inc       ax                       ; po‡et bajt– na sektor
         shr       ax,1                     ; p©ednastaven¡ / 2
ZobDSo52:shr       dx,1                     ; offset / 2
         rcr       bx,1
         shr       ax,1
         jnz       ZobDSo52
         jmp       short ZobDSko8

; ------ aloka‡n¡ blok

ZobDSko6:dec       si                       ; n vrat posledn¡ho znaku
         inc       cx
         call      ZobDSkN                  ; na‡ten¡ ‡¡sla
ZobDSo60:jc        ZobDSko9                 ; chyba zad n¡

         sub       bx,2                     ; ‡¡slo bloku relativnˆ
         sbb       dx,0
         jnc       ZobDSo61
         mov       bx,ds:[DskLBRot]         ; po‡ te‡n¡ sektor ROOT
         xor       dx,dx
         jmp       short ZobDSko8

ZobDSo61:mov       ax,ds:[DskLSBlk]         ; po‡et sektor– na blok
         shr       ax,1                     ; p©ednastaven¡
         jz        ZobDSo64
ZobDSo62:shl       bx,1                     ; ‡¡slo bloku / 2
         rcl       dx,1
         shr       ax,1
         jnz       ZobDSo62
ZobDSo64:add       bx,ds:[DskLBDat]         ; + po‡ te‡n¡ sektor dat
         adc       dx,0

; ------ nastaven¡ nov‚ho sektoru DX:BX

ZobDSko8:cmp       dx,word ptr ds:[DskLNSkt+2]
         jne       ZobDSo81
         cmp       bx,word ptr ds:[DskLNSkt]
ZobDSo81:jb        ZobDSo82
         mov       bx,word ptr ds:[DskLNSkt]
         mov       dx,word ptr ds:[DskLNSkt+2]
         sub       bx,1
         sbb       dx,0

ZobDSo82:mov       cx,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         sub       bx,1                     ; rezerva 1 sektor
         sbb       dx,0
         jnc       ZobDSo84
         xor       bx,bx                    ; omezen¡ pro sektor 0
         xor       dx,dx
         xor       cx,cx

ZobDSo84:add       cx,di                    ; offset v sektoru
         mov       word ptr ds:[DZobBKur],cx ; kurzor
         and       cl,not 0fh               ; zarovn n¡ na © dek
         mov       word ptr ds:[DZobBTop],cx ; zobrazen˜ po‡ tek
         mov       word ptr ds:[DZobBBeg],bx ; nov˜ offset dat
         mov       word ptr ds:[DZobBBeg+2],dx
         mov       word ptr ds:[DZobBNum],0 ; buffer je pr zdn˜
         call      ZobDRead                 ; na‡ten¡ obsahu bufferu
ZobDSko9:ret

ZobDSkok ENDP

; ------ na‡ten¡ ‡¡sla -> DX:BX

ZobDSkN: xor       dx,dx
         xor       bx,bx                    ; st©ada‡ ‡¡sla
         call      far ptr RozXPCh          ; na‡ten¡ prvn¡ho znaku ‡¡sla
         jc        ZobDSkN9                 ; nen¡ dal¨¡ znak
         cmp       al,"$"                   ; je HEX ‡¡slo ?
         jne       ZobDSkN4                 ; nen¡ HEX ‡¡slo
         call      far ptr RozXHNum         ; na‡ten¡ ‡¡sla DX:AX v HEX k¢du
         jmp       short ZobDSkN8

ZobDSkN4:dec       si                       ; n vrat posledn¡ho znaku
         inc       cx
         call      far ptr RozXDNum         ; na‡ten¡ ‡¡sla DX:AX

ZobDSkN8:xchg      ax,bx                    ; BX <- ‡¡slo LOW
ZobDSkN9:ret

; -----------------------------------------------------------------------------
;        F7 vyhled n¡ textu na disku
; -----------------------------------------------------------------------------

ZobDHled PROC      NEAR

; ------ zad n¡ dat k vyhled n¡

         mov       byte ptr ds:[EdiHPrN],0  ; po‡et p©edvoleb hled n¡ ASCII
         mov       byte ptr ds:[EdiHHPN],0  ; po‡et p©edvoleb hled n¡ HEX
         and       byte ptr ds:[EdiHldP2],not bit2 ; nen¡ HEX tvar
         test      byte ptr ds:[DZAktMod],bit2 ; je ASCII pole ?
         jnz       ZobDHle1                 ; je ASCII pole
         or        byte ptr ds:[EdiHldP2],bit2 ; je zad n¡ v HEX tvaru
ZobDHle1:call      far ptr EdiHF7Za         ; zad n¡ textu k hled n¡
         jc        ZobDHle9                 ; p©eru¨en¡ operace

; ------ pokra‡ov n¡ v hled n¡ Ctrl-L

; ------ konverze bufferu na velk  p¡smena

ZobDHlCL:mov       cx,ds:[TextFndN]         ; po‡et bajt– v bufferu
         jcxz      ZobDHle9                 ; nejsou ‘ dn  data k hled n¡
         test      byte ptr ds:[DZAktMod],bit2 ; je HEX pole ?
         jz        ZobDHle4                 ; je HEX pole
         mov       si,offset TextFnd        ; buffer textu
ZobDHle2:cld
         lodsb
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         mov       ds:[si-1],al             ; zkonvertovan˜ znak
         loop      ZobDHle2

; ------ zobrazen¡ hl ¨en¡ o vyhled v n¡

ZobDHle4:or        byte ptr ds:[DZAktMod],bit5 ; je hled n¡ ©etˆzce
         call      ZobDHlIn                 ; zobrazen¡ hl ¨en¡

; ------ adresa kurzoru -> ES:DI

         inc       word ptr ds:[DZobBKur]   ; dal¨¡ znak
         call      GetZBSeg                 ; adresa bufferu -> ES
         mov       di,ds:[DZobBKur]         ; kurzor

; ------ hled n¡ dat v HEX m¢du

         test      byte ptr ds:[DZAktMod],bit2 ; je HEX pole ?
         jnz       ZobDHle5                 ; nen¡ HEX pole
         call      ZobDHlHx                 ; hled n¡ dat v HEX k¢du
         jmp       short ZobDHle8

; ------ hled n¡ dat v ASCII m¢du bez otazn¡ku

ZobDHle5:test      byte ptr ds:[EdiHldP2],bit1 ; je v ©etˆzci otazn¡k ?
         jnz       ZobDHle6                 ; v ©etˆzci je otazn¡k
         call      ZobDHlAs                 ; hled n¡ dat v ASCII m¢du
         jmp       short ZobDHle8

ZobDHle6:call      ZobDHlOt                 ; hled n¡ dat s otazn¡kem

; ------ konec hled n¡ dat (buƒ nalezen˜ ©etˆzec nebo konec disku)

ZobDHle8:dec       di                       ; n vrat prvn¡ho znaku ©etˆzce
         mov       ds:[DZobBKur],di         ; nastaven¡ kurzoru na ©etˆzec
         call      ZobDNorm                 ; normalizace bufferu

         call      far ptr FlushChr         ; vypr zdnˆn¡ bufferu kl vesnice
         and       byte ptr ds:[DZAktMod],not bit3 ; je 1. znak HEX
ZobDHle9:call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         and       byte ptr ds:[DZAktMod],not bit5 ; nen¡ hled n¡ ©etˆzce
         ret

ZobDHled ENDP

; -----------------------------------------------------------------------------
;     p©¡prava bufferu ES:DI s daty pro hled n¡ -> DI=kurzor, CX=po‡et ©etˆzc–
; -----------------------------------------------------------------------------

ZobDHBP  PROC      NEAR                     ; vstup: DI=ukazatel kurzoru

; ------ po‡et zbyl˜ch ©etˆzc– k testu -> CX

         mov       ds:[DZobBKur],di         ; nov˜ kurzor
         mov       cx,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         sub       cx,di                    ; CX <- zbyl˜ po‡et znak–
         jbe       ZobDHBP2                 ; nejsou dal¨¡ data
         inc       cx                       ; korekce
         sub       cx,ds:[TextFndN]         ; CX <- po‡et ©etˆzc– k testu
         ja        ZobDHBP9                 ; zbyly nˆjak‚ ©etˆzce OK

; ------ test, zda je p©eru¨en¡ operace

ZobDHBP2:call      far ptr TestBEsc         ; test p©eru¨en¡ operace
         jc        ZobDHBP8                 ; p©eru¨en¡ operace

; ------ £schova ukazatel– bufferu

         push      word ptr ds:[DZobBNum]   ; po‡et bajt– v bufferu
         push      word ptr ds:[DZobBBeg]   ; po‡ te‡n¡ sektor bufferu LOW
         push      word ptr ds:[DZobBBeg+2] ; po‡ te‡n¡ sektor bufferu HIGH

; ------ na‡ten¡ dal¨¡ho bloku dat

         add       di,ds:[TextFndN]         ; rezerva, aby se data na‡etla
         mov       ds:[DZobBKur],di         ; nov˜ kurzor
         call      ZobDNorm                 ; normalizace bufferu
         mov       ax,ds:[TextFndN]         ; d‚lka textu
         sub       ds:[DZobBKur],ax         ; n vrat kurzoru
         call      ZobDNorm                 ; opravn  normalizace

; ------ nov‚ zobrazen¡ okna

         mov       si,offset DZMnuLin       ; menu zobrazen¡ disku
         call      far ptr DispMnu          ; zobrazen¡ okna
         call      far ptr DispTime         ; zobrazen¡ ‡asu
         call      far ptr KurzOff          ; vypnut¡ kurzoru

; ------ test, zda byl na‡ten dal¨¡ blok dat

         pop       dx                       ; po‡ te‡n¡ sektor bufferu HIGH
         pop       ax                       ; po‡ te‡n¡ sektor bufferu LOW
         pop       cx                       ; po‡et bajt– v bufferu

         cmp       dx,word ptr ds:[DZobBBeg+2] ; zv˜¨en po‡ te‡n¡ sektor ?
         jne       ZobDHBP4
         cmp       ax,word ptr ds:[DZobBBeg]
ZobDHBP4:jb        ZobDHBP6                 ; po‡ te‡n¡ sektor zv˜¨en OK
         cmp       cx,ds:[DZobBNum]         ; zv˜¨en po‡et bajt– v bufferu ?
         jae       ZobDHBP8                 ; obsah bufferu nezmˆnˆn

; ------ test, zda je ji‘ dost platn˜ch dat

ZobDHBP6:mov       di,ds:[DZobBKur]         ; DI <- kurzor
         mov       cx,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         sub       cx,di                    ; CX <- zbyl˜ po‡et znak–
         jbe       ZobDHBP8                 ; nejsou dal¨¡ data
         inc       cx                       ; korekce
         sub       cx,ds:[TextFndN]         ; CX <- po‡et ©etˆzc– k testu
         ja        ZobDHBP9                 ; je ji‘ dost znak– OK

ZobDHBP8:stc                                ; p©¡znak, ‘e nejsou dal¨¡ data
ZobDHBP9:ret

ZobDHBP  ENDP

; -----------------------------------------------------------------------------
;        hled n¡ dat v HEX m¢du (buffer ES:DI)
; -----------------------------------------------------------------------------

; ------ p©¡prava bufferu

ZobDHlHx:call      ZobDHBP                  ; p©¡prava bufferu k hled n¡
         jc        ZobDHlH8                 ; nejsou dal¨¡ data

; ------ nalezen¡ prvn¡ho znaku ©etˆzce

         mov       al,ds:[TextFnd]          ; prvn¡ znak ©etˆzce
         cld
         repne     scasb                    ; nalezen¡ prvn¡ho znaku
         jne       ZobDHlHx                 ; znak nenalezen

; ------ porovn n¡ zbytku ©etˆzce

         push      cx
         push      di
         mov       cx,ds:[TextFndN]         ; po‡et bajt– v bufferu
         dec       cx                       ; bez prvn¡ho znaku ("1" nastav¡ ZY)
         mov       si,offset TextFnd+1      ; buffer ©etˆzce
         repe      cmpsb                    ; porovn n¡ ©etˆzce
         pop       di
         pop       cx
         jne       ZobDHlHx                 ; ©etˆzec nenalezen
         clc
ZobDHlH8:ret

; -----------------------------------------------------------------------------
;        hled n¡ dat v ASCII m¢du bez otazn¡ku (buffer ES:DI)
; -----------------------------------------------------------------------------

; ------ p©¡prava bufferu

ZobDHlAs:call      ZobDHBP                  ; p©¡prava bufferu k hled n¡
         jc        ZobDHlA8                 ; nejsou dal¨¡ data

; ------ zrychlen‚ nalezen¡ prvn¡ho znaku ©etˆzce (jenom p©ibli‘nˆ)

         mov       ah,ds:[TextFnd]          ; prvn¡ znak ©etˆzce
         and       ah,not 20h               ; fiktivn¡ velk‚ p¡smeno
ZobDHlA2:mov       al,es:[di]               ; znak z bufferu
         inc       di                       ; zv˜¨en¡ ukazatele v bufferu
         and       al,not 20h               ; konverze na velk‚ p¡smeno
         cmp       al,ah                    ; je to asi tak prvn¡ znak ?
         loopne    ZobDHlA2                 ; nen¡ to prvn¡ znak
         jne       ZobDHlAs                 ; znak nenalezen

; ------ £pln‚ porovn n¡ ©etˆzce

         push      cx
         push      di

         dec       di                       ; n vrat na prvn¡ znak ©etˆzce
         mov       si,offset TextFnd-1      ; buffer ©etˆzce - 1
         mov       cx,ds:[TextFndN]         ; d‚lka hledan‚ho ©etˆzce (CX > 0)
ZobDHlA4:inc       si                       ; zv˜¨en¡ ukazatele ©etˆzce
         mov       al,es:[di]               ; znak z bufferu textu
         inc       di                       ; zv˜¨en¡ ukazatele textu
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         cmp       al,ds:[si]               ; souhlas¡ znak ?
         loope     ZobDHlA4                 ; porovn n¡ dal¨¡ho znaku

         pop       di
         pop       cx
         jne       ZobDHlAs                 ; ©etˆzec nesouhlas¡
         clc
ZobDHlA8:ret

; -----------------------------------------------------------------------------
;        hled n¡ dat v ASCII m¢du s otazn¡kem (buffer ES:DI)
; -----------------------------------------------------------------------------

; ------ p©¡prava bufferu

ZobDHlOt:call      ZobDHBP                  ; p©¡prava bufferu k hled n¡
         jc        ZobDHlO8                 ; nejsou dal¨¡ data

; ------ zrychlen‚ nalezen¡ prvn¡ho znaku ©etˆzce (jenom p©ibli‘nˆ)

         mov       ah,ds:[TextFnd]          ; prvn¡ znak ©etˆzce
         inc       di
         dec       cx
         cmp       ah,"?"                   ; je prvn¡ znak otazn¡k ?
         je        ZobDHlO3                 ; prvn¡ znak je otazn¡k
         inc       cx
         dec       di
         and       ah,not 20h               ; fiktivn¡ velk‚ p¡smeno
ZobDHlO2:mov       al,es:[di]               ; znak z bufferu
         inc       di                       ; zv˜¨en¡ ukazatele v bufferu
         and       al,not 20h               ; konverze na velk‚ p¡smeno
         cmp       al,ah                    ; je to asi tak prvn¡ znak ?
         loopne    ZobDHlO2                 ; nen¡ to prvn¡ znak
         jne       ZobDHlOt                 ; znak nenalezen

; ------ £pln‚ porovn n¡ ©etˆzce

ZobDHlO3:push      cx
         push      di

         dec       di                       ; n vrat na prvn¡ znak ©etˆzce
         mov       si,offset TextFnd-1      ; buffer ©etˆzce - 1
         mov       cx,ds:[TextFndN]         ; d‚lka hledan‚ho ©etˆzce (CX > 0)
ZobDHlO4:inc       si                       ; zv˜¨en¡ ukazatele ©etˆzce
         mov       al,es:[di]               ; znak z bufferu textu
         inc       di                       ; zv˜¨en¡ ukazatele textu
         mov       ah,ds:[si]               ; porovn van˜ znak ©etˆzce
         cmp       ah,"?"                   ; je to otazn¡k ?
         je        ZobDHlO6                 ; je to otazn¡k - plat¡ v‘dy
         call      far ptr UpCase           ; konverze na velk‚ p¡smeno
         cmp       al,ah                    ; souhlas¡ znak ?
ZobDHlO6:loope     ZobDHlO4                 ; porovn n¡ dal¨¡ho znaku

         pop       di
         pop       cx
         jne       ZobDHlOt                 ; ©etˆzec nesouhlas¡
         clc
ZobDHlO8:ret

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho textu o hled n¡
; -----------------------------------------------------------------------------

ZobDHlIn PROC      NEAR

         mov       si,offset DZHMLTxt       ; prvn¡ ‡ st textu
         call      far ptr InfDisp0         ; dek¢dov n¡ textu hl ¨en¡
         ret

ZobDHlIn ENDP

; -----------------------------------------------------------------------------
;        za‡ tek disku
; -----------------------------------------------------------------------------

EdZCPgUp PROC      NEAR

; ------ test, zda je ji‘ za‡ tek disku

         mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor
         or        ax,word ptr ds:[DZobBBeg+2] ; je ji‘ za‡ tek disku ?
         jz        EdZCPgU3                 ; je ji‘ za‡ tek disku

; ------ nov‚ na‡ten¡ bufferu

         call      ZobDWrit                 ; ulo‘en¡ obsahu bufferu
         jc        EdZCPgU7                 ; p©eru¨en¡ operace
         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[DZobBBeg],ax ; po‡ te‡n¡ sektor disku
         mov       word ptr ds:[DZobBBeg+2],ax
         mov       word ptr ds:[DZobBNum],ax ; buffer je pr zdn˜
         call      ZobDRead                 ; na‡ten¡ obsahu bufferu

; ------ inicializace ukazatel– kurzoru a po‡ tku (AX=0)

EdZCPgU3:mov       word ptr ds:[DZobBKur],ax ; kurzor = 0
         mov       word ptr ds:[DZobBTop],ax ; po‡ tek = 0
         and       byte ptr ds:[DZAktMod],not bit3 ; je 1. znak HEX
EdZCPgU7:ret

EdZCPgUp ENDP

; -----------------------------------------------------------------------------
;        konec disku
; -----------------------------------------------------------------------------

EdZCPgDn PROC      NEAR

; ------ v˜po‡et po‡ te‡n¡ho sektoru v bufferu

         mov       ax,word ptr ds:[DskLNSkt] ; celkov˜ po‡et sektor– disku
         mov       dx,word ptr ds:[DskLNSkt+2]
         sub       ax,ds:[DZobBSek]         ; ‡¡slo po‡ te‡n¡ho sektoru
         sbb       dx,0
         jnc       EdZCPgD2
         xor       ax,ax                    ; omezen¡ p©i podte‡en¡
         xor       dx,dx

; ------ test, zda je ji‘ konec disku v bufferu

EdZCPgD2:cmp       ax,word ptr ds:[DZobBBeg] ; jsou data ji‘ na‡tena ?
         jne       EdZCPgD3                 ; data nejsou na‡tena
         cmp       dx,word ptr ds:[DZobBBeg+2]
         je        EdZCPgD4                 ; data jsou ji‘ v bufferu

; ------ nov‚ na‡ten¡ bufferu

EdZCPgD3:call      ZobDWrit                 ; ulo‘en¡ obsahu bufferu
         jc        EdZCPgD9                 ; p©eru¨en¡ operace
         mov       word ptr ds:[DZobBBeg],ax ; nov˜ offset dat
         mov       word ptr ds:[DZobBBeg+2],dx
         mov       word ptr ds:[DZobBNum],0 ; buffer je pr zdn˜
         call      ZobDRead                 ; na‡ten¡ obsahu bufferu

; ------ inicializace kurzoru

EdZCPgD4:mov       ax,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         dec       ax                       ; posledn¡ bajt v bufferu
         jns       EdZCPgD5                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; AX <- 0 p©i podte‡en¡
EdZCPgD5:mov       ds:[DZobBKur],ax         ; offset kurzoru

; ------ offset zobrazen‚ho po‡ tku

         mov       ax,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         sub       ax,ds:[DZobBV16]         ; nov˜ po‡ tek
         jnc       EdZCPgD6                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; AX <- 0 p©i podte‡en¡
EdZCPgD6:mov       ds:[DZobBTop],ax         ; zobrazen˜ po‡ tek
         and       byte ptr ds:[DZAktMod],not bit3 ; je 1. znak HEX

EdZCPgD9:ret

EdZCPgDn ENDP

; -----------------------------------------------------------------------------
;        p©ede¨l  zmˆna
; -----------------------------------------------------------------------------

EdZCLft  PROC      NEAR

; ------ adresa kurzoru

         call      GetZBSeg                 ; adresa bufferu
         mov       di,ds:[DZobBKur]         ; offset kurzoru
         mov       cx,di                    ; CX <- offset kurzoru
         jcxz      EdZLeft4                 ; kurzor na za‡ tku bufferu
         dec       di                       ; p©ede¨l˜ bajt p©ed kurzorem
         mov       si,ds:[DZobBRef]         ; offset referen‡n¡ho bufferu
         add       si,di                    ; adresa v referen‡n¡m bufferu

; ------ nalezen¡ p©ede¨l‚ zmˆny

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         std                                ; smˆr dol–
         repe      cmpsb                    ; nalezen¡ rozd¡ln˜ch dat
         cld                                ; (pro jistotu)
         pop       ds
         je        EdZLeft4                 ; rozd¡l nenalezen

         inc       di                       ; n vrat rozd¡ln‚ pozice
         mov       ds:[DZobBKur],di         ; nov˜ offset kurzoru
         jmp       short EdZCRgh4           ; bude 1. znak HEX

EdZCLft  ENDP

; -----------------------------------------------------------------------------
;        dal¨¡ zmˆna
; -----------------------------------------------------------------------------

EdZCRgh  PROC      NEAR

; ------ adresa kurzoru

         call      GetZBSeg                 ; adresa bufferu -> ES
         mov       di,ds:[DZobBKur]         ; offset kurzoru
         inc       di                       ; n sleduj¡c¡ bajt za kurzorem
         mov       si,ds:[DZobBRef]         ; offset referen‡n¡ho bufferu
         add       si,di                    ; adresa v referen‡n¡m bufferu
         mov       cx,ds:[DZobBNum]         ; po‡et bajt–
         sub       cx,di                    ; CX <- po‡et zbyl˜ch pozic
         jbe       EdZLeft4                 ; kurzor je na konci

; ------ nalezen¡ dal¨¡ zmˆny

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         cld                                ; smˆr nahoru
         repe      cmpsb                    ; nalezen¡ rozd¡ln˜ch dat
         pop       ds
         je        EdZLeft4                 ; rozd¡l nenalezen

         dec       di                       ; n vrat rozd¡ln‚ pozice
         mov       ds:[DZobBKur],di         ; nov˜ offset kurzoru
EdZCRgh4:jmp       short EdZEnd2            ; je 1. znak HEX

EdZCRgh  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru vlevo
; -----------------------------------------------------------------------------

EdZLeft  PROC      NEAR

         test      byte ptr ds:[DZAktMod],bit2 ; je HEX pole ?
         jnz       EdZLeft3                 ; je ASCII pole
         test      byte ptr ds:[DZAktMod],bit3 ; je 1. znak HEX ?
         jnz       EdZEnd2                  ; je 2. znak -> aktivn¡ 1. znak HEX

EdZLeft2:or        byte ptr ds:[DZAktMod],bit3 ; je 2. znak HEX
EdZLeft3:dec       word ptr ds:[DZobBKur]   ; sn¡‘en¡ ukazatele kurzoru
EdZLeft4:ret

EdZLeft  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru vpravo
; -----------------------------------------------------------------------------

EdZRght  PROC      NEAR

         inc       word ptr ds:[DZobBKur] ; zv˜¨en¡ ukazatele kurzoru
         test      byte ptr ds:[DZAktMod],bit2 ; je HEX pole ?
         jnz       EdZLeft4                 ; je ASCII pole
         test      byte ptr ds:[DZAktMod],bit3 ; je 1. znak HEX ?
         jnz       EdZEnd2                  ; je 2. znak HEX - bude 1. znak
         jmp       short EdZLeft2           ; bude 2. znak HEX (+n vrat kurzoru)

EdZRght  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru dol–
; -----------------------------------------------------------------------------

EdZDown  PROC      NEAR

         add       word ptr ds:[DZobBKur],16     ; posun kurzoru v˜¨e
         jmp       short EdZEnd2            ; aktivn¡ 1. znak HEX

EdZDown  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru nahoru
; -----------------------------------------------------------------------------

EdZUp    PROC      NEAR

         sub       word ptr ds:[DZobBKur],16 ; posun kurzoru n¡‘e
         jmp       short EdZEnd2            ; aktivn¡ 1. znak HEX

EdZUp    ENDP

; -----------------------------------------------------------------------------
;        str nka nahoru
; -----------------------------------------------------------------------------

EdZPgUp  PROC      NEAR

         mov       ax,ds:[DZobBV16]         ; zobrazeno dat
         sub       ax,16                    ; bez 1 © dku
         sub       word ptr ds:[DZobBKur],ax ; posun kurzoru
         sub       word ptr ds:[DZobBTop],ax ; posun po‡ tku
         jmp       short EdZEnd2            ; aktivn¡ 1. znak HEX

EdZPgUp  ENDP

; -----------------------------------------------------------------------------
;        str nka dol–
; -----------------------------------------------------------------------------

EdZPgDn  PROC      NEAR

         mov       ax,ds:[DZobBV16]         ; zobrazeno dat
         sub       ax,16                    ; bez 1 © dku
         add       word ptr ds:[DZobBKur],ax ; posun kurzoru
         add       word ptr ds:[DZobBTop],ax ; posun po‡ tku
         jmp       short EdZEnd2            ; aktivn¡ 1. znak HEX

EdZPgDn  ENDP

; -----------------------------------------------------------------------------
;        za‡ tek © dku
; -----------------------------------------------------------------------------

EdZHome  PROC      NEAR

         and       byte ptr ds:[DZobBKur],not 0fh ; kurzor na za‡ tek © dku
         jmp       short EdZEnd2            ; aktivn¡ 1. znak HEX

EdZHome  ENDP

; -----------------------------------------------------------------------------
;        konec © dku
; -----------------------------------------------------------------------------

EdZEnd   PROC      NEAR

         or        byte ptr ds:[DZobBKur],0fh    ; kurzor na konec © dku
EdZEnd2: and       byte ptr ds:[DZAktMod],not bit3 ; aktivn¡ 1. znak HEX
         ret

EdZEnd   ENDP

; -----------------------------------------------------------------------------
;        normalizace bufferu a kurzoru (CY=p©eru¨en¡)
; -----------------------------------------------------------------------------
;þ
ZobDNorm PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ korekce po‡ tku podle kurzoru

ZobDNrm1:mov       cx,ds:[DZobBKur]         ; kurzor
         mov       ax,ds:[DZobBTop]         ; po‡ tek
         add       cx,4000h                 ; korekce kurzoru
         add       ax,4000h                 ; korekce po‡ tku
         and       cl,not 0fh               ; © dek s kurzorem
         cmp       ax,cx                    ; je po‡ tek p©ed kurzorem ?
         jb        ZobDNrm2                 ; po‡ tek je p©ed kurzorem OK
         mov       ax,cx                    ; CX <- po‡ tek podle kurzoru
         sub       ax,16                    ; 1 © dek rezerva
ZobDNrm2:add       cx,32
         sub       cx,ds:[DZobBV16]         ; minim ln¡ po‡ tek
         jc        ZobDNrm3                 ; nˆjak‚ podte‡en¡ ?
         cmp       ax,cx                    ; je konec za kurzorem ?
         jae       ZobDNrm3                 ; konec je za kurzorem OK
         mov       ax,cx                    ; omezen¡ podle kurzoru
ZobDNrm3:sub       ax,4000h                 ; n vrat korekce po‡ tku
         mov       ds:[DZobBTop],ax         ; opraven˜ po‡ tek
         jnc       ZobDNrm5                 ; nen¡ podte‡en¡ po‡ tku

; ------ bude posun k ni‘¨¡m sektor–m - kontrola, zda je ji‘ za‡ tek disku

         mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor v bufferu
         or        ax,word ptr ds:[DZobBBeg+2] ; je ji‘ po‡ tek disku ?
         jnz       ZobDNrm4                 ; nen¡ je¨tˆ po‡ tek disku
         xor       ax,ax                    ; AX <- 0
         mov       ds:[DZobBTop],ax         ; omezen¡ zobrazen‚ho po‡ tku
         cmp       ds:[DZobBKur],ax         ; je kurzor platn˜ ?
         jge       ZobDNrm8                 ; kurzor je OK (je kladn˜)
         mov       ds:[DZobBKur],ax         ; omezen¡ kurzoru, je-li z porn˜
         jmp       short ZobDNrm8

; ------ posun k ni‘¨¡m sektor–m

ZobDNrm4:call      ZobDPred                 ; posun k ni‘¨¡m sektor–m
ZobDNr42:jnc       ZobDNrm1                 ; nov  kontrola
         jmp       short ZobDNrm9           ; CY = chyba

; ------ posun k vy¨¨¡m sektor–m

ZobDNr44:call      ZobDNext                 ; posun k vy¨¨¡m sektor–m
         jmp       short ZobDNr42

; ------ kontrola po‡ tku, zda je p©ete‡en¡

ZobDNrm5:add       ax,ds:[DZobBV16]         ; maxim ln¡ po‡ tek
         cmp       ax,ds:[DZobBNum]         ; je p©ete‡en¡ bufferu ?
         jbe       ZobDNrm8                 ; po‡ tek je OK

; ------ v˜po‡et maxim ln¡ho po‡ te‡n¡ho sektoru

         mov       ax,word ptr ds:[DskLNSkt] ; celkov˜ po‡et sektor– na disku
         mov       dx,word ptr ds:[DskLNSkt+2]
         sub       ax,ds:[DZobBSek]         ; maxim ln¡ ‡¡slo sektoru po‡ tku
         sbb       dx,0
         jnc       ZobDNrm6
         xor       ax,ax                    ; omezen¡ po‡ te‡n¡ho sektoru
         xor       dx,dx

; ------ test, zda je ji‘ maxim ln¡ sektor

ZobDNrm6:cmp       dx,word ptr ds:[DZobBBeg+2] ; je ji‘ maxim ln¡ sektor ?
         jne       ZobDNrm7                 ; nen¡ maxim ln¡ sektor
         cmp       ax,word ptr ds:[DZobBBeg]
ZobDNrm7:ja        ZobDNr44                 ; nen¡ je¨tˆ maxim ln¡ sektor

; ------ omezen¡ po‡ tku, je-li ji‘ konec disku

         mov       ax,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         sub       ax,ds:[DZobBV16]         ; maxim ln¡ po‡ tek
         jnc       ZobDNr72
         xor       ax,ax                    ; omezen¡ po‡ tku
ZobDNr72:mov       ds:[DZobBTop],ax         ; maxim ln¡ po‡ tek
ZobDNrm8:clc                                ; p©¡znak operace OK

; ------ omezen¡ po‡ tku

ZobDNrm9:pushf

         cmp       word ptr ds:[DZobBTop],-4000h ; je po‡ tek z porn˜ ?
         jb        ZobDNr90                 ; po‡ tek nen¡ z porn˜
         mov       word ptr ds:[DZobBTop],0 ; oprava po‡ tku
ZobDNr90:mov       ax,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         sub       ax,ds:[DZobBV16]         ; maxim ln¡ po‡ tek
         jnc       ZobDNr91
         xor       ax,ax
ZobDNr91:and       al,not 0fh               ; zarovn n¡ na © dek (pro jistotu)
         cmp       ax,ds:[DZobBTop]         ; vyhovuje po‡ tek ?
         jae       ZobDNr92                 ; po‡ tek vyhovuje OK
         mov       ds:[DZobBTop],ax         ; omezen¡ po‡ tku

; ------ omezen¡ kurzoru

ZobDNr92:mov       bx,ds:[DZobBTop]         ; po‡ tek
         mov       ax,ds:[DZobBKur]         ; kurzor
         cmp       ax,-4000h                ; je kurzor z porn˜ ?
         jb        ZobDNr93                 ; kurzor nen¡ z porn˜
         xor       ax,ax                    ; oprava kurzoru
ZobDNr93:cmp       ax,bx                    ; je p©ed po‡ tkem ?
         jae       ZobDNr94                 ; nen¡ p©ed po‡ tkem
         add       ax,16                    ; posun kurzoru o © dek v˜¨e
         jmp       short ZobDNr93

ZobDNr94:add       bx,ds:[DZobBV16]         ; zobrazen¡ konec
ZobDNr95:cmp       ax,bx                    ; je p©ed zobrazen˜m koncem ?
         jb        ZobDNr96                 ; je p©ed zobrazen˜m koncem
         sub       ax,16                    ; posun kurzoru o © dek n¡‘e
         jmp       short ZobDNr95

ZobDNr96:cmp       ax,ds:[DZobBNum]         ; je v platn˜ch datech ?
         jb        ZobDNr97                 ; je v platn˜ch datech
         mov       ax,ds:[DZobBNum]         ; konec dat
         or        ax,ax                    ; jsou nˆjak  data ?
         jz        ZobDNr97                 ; nejsou data
         dec       ax                       ; omezen¡ na posledn¡ bajt
ZobDNr97:mov       ds:[DZobBKur],ax         ; nov˜ kurzor

         popf

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZobDNorm ENDP

; -----------------------------------------------------------------------------
;        posun bufferu v disku dol– (k ni‘¨¡m sektor–m; CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

ZobDPred PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ stanoven¡ po‡tu sektor– k vlo‘en¡ -> CX

         mov       bx,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         mov       cx,ds:[DZobBSek]         ; CX <- velikost bufferu v sektorech
         shr       cx,1                     ; po‡et sektor– v polovinˆ bufferu
         mov       ax,word ptr ds:[DZobBBeg] ; zbyl˜ po‡et sektor–
         mov       dx,word ptr ds:[DZobBBeg+2]
         or        dx,dx
         jnz       ZobDPre2                 ; zb˜v  je¨tˆ mnoho sektor–
         cmp       ax,cx                    ; zb˜v  dost sektor– ?
         jae       ZobDPre2                 ; zb˜v  dost sektor–
         xchg      ax,cx                    ; CX <- omezen¡ po‡tu sektor–
ZobDPre2:clc                                ; p©¡znak operace OK
         jcxz      ZobDPre9                 ; je ji‘ za‡ tek disku

; ------ test, zda je v bufferu m¡sto pro na‡ten¡ dat

         mov       ax,bx                    ; po‡et bajt– na sektor
         mul       cx                       ; po‡et bajt– k vlo‘en¡
         add       ax,ds:[DZobBNum]         ; po‡et dat v bufferu po na‡ten¡
         jc        ZobDPre3                 ; nen¡ dost m¡sta
         cmp       ax,ds:[DZobBRef]         ; je dost m¡sta ?
         jbe       ZobDPre4                 ; v bufferu je dost m¡sta k na‡ten¡

; ------ ulo‘en¡ dat, pokud byla modifikovan 

ZobDPre3:call      ZobDWrit                 ; ulo‘en¡ obsahu bufferu
         jc        ZobDPre9                 ; p©eru¨en¡ operace

; ------ odsun zbytku dat

         mov       ax,bx                    ; po‡et bajt– na sektor
         mul       cx                       ; po‡et bajt– k vlo‘en¡
         sub       ds:[DZobBNum],ax         ; sn¡‘en¡ po‡tu bajt– v bufferu
         jnc       ZobDPre4
         mov       word ptr ds:[DZobBNum],0 ; omezen¡ dat p©i p©ete‡en¡
ZobDPre4:call      ZobDInsS                 ; odsun zbytku dat

; ------ na‡ten¡ bufferu (jako cel˜ £sek dat)

         xor       di,di                    ; DI <- 0 po‡ tek bufferu
         mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor
         mov       dx,word ptr ds:[DZobBBeg+2]
         call      ZobDXRea                 ; na‡ten¡ dat do bufferu
         jnc       ZobDPre9                 ; data na‡tena OK

; ------ p©¡prava ke ‡ten¡ obsahu bufferu po sektorech

         push      ax
         push      dx
         mov       ax,cx                    ; AX <- po‡et sektor– k na‡ten¡
         mul       bx                       ; AX <- po‡et bajt– k na‡ten¡
         xchg      ax,di                    ; DI <- konec dat k na‡ten¡
         pop       dx
         pop       ax
         add       ax,cx                    ; AX <- ‡¡slo n sleduj¡c¡ho sektoru
         adc       dx,0

; ------ na‡ten¡ dat po 1 sektoru

         mov       bx,cx                    ; BX <- po‡et sektor– k na‡ten¡
ZobDPre5:sub       di,ds:[DskLBSkt]         ; posun adresy v bufferu
         sub       ax,1                     ; posun ‡¡sla sektoru
         sbb       dx,0
ZobDPr55:mov       cx,1                     ; bude se ‡¡st po 1 sektoru
         call      ZobDXRea                 ; na‡ten¡ 1 sektoru
         jc        ZobDPre7                 ; chyba ‡ten¡ dat
ZobDPre6:dec       bx                       ; ‡¡ta‡ sektor– ke ‡ten¡
         jnz       ZobDPre5                 ; ‡ten¡ dal¨¡ho sektoru
         clc                                ; p©¡znak operace OK
         jmp       short ZobDPre9

; ------ hl ¨en¡ o chybˆ operace

ZobDPre7:call      ZobDRErr                 ; hl ¨en¡ o chybˆ operace
         jc        ZobDPre8                 ; p©eru¨en¡
         jz        ZobDPr55                 ; opakov n¡ operace
         jmp       short ZobDPre6           ; dal¨¡ sektor

; ------ p©i chybˆ zru¨en¡ m¡sta v bufferu

ZobDPre8:mov       cx,bx                    ; CX <- po‡et nena‡ten˜ch sektor–
         call      ZobDDelS                 ; zru¨en¡ m¡sta v bufferu
         stc                                ; p©¡znak chyby

; ------ n vrat registr–

ZobDPre9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZobDPred ENDP

; -----------------------------------------------------------------------------
;        posun bufferu v disku nahoru (k vy¨¨¡m sektor–m; CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------

ZobDNext PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ v˜po‡et maxim ln¡ho sektoru po‡ tku bufferu -> DX:AX

         mov       ax,word ptr ds:[DskLNSkt] ; celkov˜ po‡et sektor– na disku
         mov       dx,word ptr ds:[DskLNSkt+2]
         mov       cx,ds:[DZobBSek]         ; CX <- velikost bufferu v sektorech
         sub       ax,cx                    ; maxim ln¡ ‡¡slo sektoru po‡ tku
         sbb       dx,0
         jnc       ZobDNxt1
         xor       ax,ax                    ; omezen¡ p©i podte‡en¡
         xor       dx,dx

; ------ stanoven¡ po‡tu sektor– k posunu -> CX (asi tak o polovinu bufferu)

ZobDNxt1:shr       cx,1                     ; po‡et sektor– v polovinˆ bufferu
         sub       ax,word ptr ds:[DZobBBeg] ; zbyl˜ po‡et sektor–
         sbb       dx,word ptr ds:[DZobBBeg+2]
         jnc       ZobDNxt2                 ; nen¡ p©ete‡en¡
         xor       ax,ax                    ; AX <- 0 (nastav¡ se ZY)
ZobDNxt2:jnz       ZobDNxt3                 ; zb˜v  je¨tˆ mnoho sektor–
         cmp       ax,cx                    ; zb˜v  dost sektor– ?
         jae       ZobDNxt3                 ; zb˜v  dost sektor–
         xchg      ax,cx                    ; CX <- omezen¡ po‡tu sektor–
ZobDNxt3:clc                                ; p©¡znak operace OK
         jcxz      ZobDNxt9                 ; je ji‘ konec disku

; ------ nen¡ pot©eba posouvat, je-li v bufferu m lo dat (nap©. po chybˆ)

         mov       ax,ds:[DZobBSek]         ; velikost bufferu v sektorech
         shr       ax,1                     ; polovina bufferu
         adc       ax,0                     ; druh  polovina bufferu (+ lich˜)
         mul       word ptr ds:[DskLBSkt]   ; po‡et bajt– v polovinˆ bufferu
         cmp       ax,ds:[DZobBNum]         ; je v bufferu dost dat ?
         jae       ZobDNxt8                 ; v bufferu je m lo dat

; ------ ulo‘en¡ dat, pokud byla modifikovan 

         call      ZobDWrit                 ; ulo‘en¡ obsahu bufferu
         jc        ZobDNxt9                 ; p©eru¨en¡ operace

; ------ p©¡sun zbytku dat (CX sektor–)

         call      ZobDDelS                 ; p©¡sun zbytku dat

; ------ na‡ten¡ zbytku bufferu

ZobDNxt8:call      ZobDRead                 ; na‡ten¡ zbytku bufferu

; ------ n vrat registr–

ZobDNxt9:pop       dx
         pop       cx
         pop       ax
         ret

ZobDNext ENDP

; -----------------------------------------------------------------------------
;        vlo‘en¡ CX sektor– na za‡ tek bufferu (nesm¡ b˜t p©ete‡en¡ bufferu !)
; -----------------------------------------------------------------------------

ZobDInsS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ adresa bufferu -> ES

         call      GetZBSeg                 ; adresa bufferu

; ------ posun ukazatel–

         xchg      ax,cx                    ; AX <- po‡et sektor– k vlo‘en¡
         sub       word ptr ds:[DZobBBeg],ax ; sn¡‘en¡ po‡ te‡n¡ho sektoru
         sbb       word ptr ds:[DZobBBeg+2],0 ; p©enos HIGH
         mul       word ptr ds:[DskLBSkt]   ; po‡et bajt– k vlo‘en¡
         add       word ptr ds:[DZobBTop],ax ; posun po‡ tku
         add       word ptr ds:[DZobBKur],ax ; posun kurzoru

; ------ nov˜ po‡et bajt– v bufferu -> AX

         mov       cx,ds:[DZobBNum]         ; star˜ po‡et bajt– v bufferu
         add       ax,cx                    ; AX <- nov˜ po‡et bajt– v bufferu
         mov       ds:[DZobBNum],ax         ; nov˜ po‡et bajt– v bufferu

; ------ p©¡prava registr–

         mov       dx,ds:[DZobBRef]         ; offset referen‡n¡ho bufferu
         xchg      ax,di                    ; DI <- nov˜ po‡et bajt– v bufferu
         dec       di
         dec       di                       ; nov‚ posledn¡ slovo v bufferu
         mov       si,cx                    ; star˜ po‡et bajt– v bufferu
         dec       si
         dec       si                       ; star‚ posledn¡ slovo v bufferu
         push      es
         pop       ds                       ; DS <- segment bufferu

; ------ odsun dat v pracovn¡m bufferu

         shr       cx,1                     ; po‡et slov k odsunu
         push      si
         push      di
         push      cx
         std
         rep       movsw                    ; odsun zbytku dat
         pop       cx
         pop       di
         pop       si

; ------ odsun dat v referen‡n¡m bufferu

         add       si,dx
         add       di,dx
         rep       movsw                    ; odsun dat v referen‡n¡m bufferu
         cld                                ; (kdyby se na to nˆkde zapomnˆlo)

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

ZobDInsS ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ CX sektor– ze za‡ tku bufferu
; -----------------------------------------------------------------------------

ZobDDelS PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ adresa bufferu -> ES

         call      GetZBSeg                 ; adresa bufferu

; ------ posun ukazatel–

         xchg      ax,cx                    ; AX <- po‡et sektor– ke zru¨en¡
         add       word ptr ds:[DZobBBeg],ax ; zv˜¨en¡ po‡ te‡n¡ho sektoru
         adc       word ptr ds:[DZobBBeg+2],0 ; p©enos HIGH
         mul       word ptr ds:[DskLBSkt]   ; po‡et bajt– ke zru¨en¡
         sub       word ptr ds:[DZobBTop],ax ; posun po‡ tku
         sub       word ptr ds:[DZobBKur],ax ; posun kurzoru
         sub       word ptr ds:[DZobBNum],ax ; sn¡‘en¡ po‡tu bajt– v bufferu
         jnc       ZobDDlS2                 ; nen¡ podte‡en¡
         xor       ax,ax                    ; AX <- 0 (nejsou ‘ dn  data)
         mov       ds:[DZobBNum],ax

; ------ p©¡prava registr–

ZobDDlS2:mov       cx,ds:[DZobBNum]         ; nov˜ po‡et bajt– v bufferu
         mov       dx,ds:[DZobBRef]         ; offset referen‡n¡ho bufferu
         push      es
         pop       ds                       ; DS <- segment bufferu
         xor       di,di                    ; DI <- 0
         xchg      ax,si                    ; SI <- adresa zbyl˜ch dat

; ------ zru¨en¡ dat v pracovn¡m bufferu

         shr       cx,1                     ; po‡et slov k p©¡sunu
         push      si
         push      di
         push      cx
         cld
         rep       movsw                    ; p©¡sun zbytku dat
         pop       cx
         pop       di
         pop       si

; ------ zru¨en¡ dat v referen‡n¡m bufferu

         add       si,dx
         add       di,dx
         rep       movsw                    ; p©¡sun dat v referen‡n¡m bufferu

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

ZobDDelS ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu bufferu disku (na voln˜ konec; CY=p©eru¨en¡ operace)
; -----------------------------------------------------------------------------
;þ
ZobDRead PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ po‡et sektor– v bufferu -> BX

         xor       dx,dx                    ; DX <- 0
         mov       ax,ds:[DZobBNum]         ; AX <- po‡et bajt– v bufferu
         cmp       dx,ds:[DskLBSkt]         ; je platn˜ po‡et bajt– na sektor ?
         je        ZobDRea0                 ; neplatn˜ ukazatel
         div       word ptr ds:[DskLBSkt]   ; po‡et sektor– v bufferu
ZobDRea0:xchg      ax,bx                    ; BX <- po‡et sektor– v bufferu

; ------ po‡et sektor– k na‡ten¡ -> CX

         mov       cx,ds:[DZobBSek]         ; velikost prvn¡ho bufferu (sektor–)
         sub       cx,bx                    ; zbyl  velikost bufferu (sektor–)
         mov       ax,word ptr ds:[DskLNSkt] ; po‡et sektor– disku celkem
         mov       dx,word ptr ds:[DskLNSkt+2] ; po‡et sektor– disku HIGH
         sub       ax,bx                    ; ode‡ten¡ sektor– v bufferu
         sbb       dx,0
         sub       ax,word ptr ds:[DZobBBeg] ; ode‡ten¡ po‡ te‡n¡ho sektoru
         sbb       dx,word ptr ds:[DZobBBeg+2]
         ja        ZobDRea2                 ; zb˜v  dost sektor– k na‡ten¡
         je        ZobDRea1                 ; je m‚nˆ sektor– ne‘ 64 KB
         xor       ax,ax                    ; ochrana proti p©ete‡en¡
ZobDRea1:cmp       ax,cx                    ; zb˜v  m‚nˆ sektor– ?
         jae       ZobDRea2                 ; po‡et sektor– je OK
         xchg      ax,cx                    ; CX <- omezen¡ po‡tu sektor–
ZobDRea2:clc                                ; p©¡znak operace OK
         jcxz      ZobDRea9                 ; nejsou ‘ dn‚ sektory k na‡ten¡

; ------ po‡ te‡n¡ sektor k na‡ten¡ -> DX:AX

         mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor bufferu LOW
         mov       dx,word ptr ds:[DZobBBeg+2] ; po‡ te‡n¡ sektor bufferu HIGH
         add       ax,bx                    ; p©i‡ten¡ sektor– v bufferu
         adc       dx,0

; ------ na‡ten¡ obsahu bufferu z disku

         mov       di,ds:[DZobBNum]         ; adresa konce dat v bufferu
         call      ZobD0Rea                 ; na‡ten¡ dat z disku
         jnc       ZobDRea9                 ; operace ‡ten¡ OK

; ------ ‡ten¡ obsahu bufferu po sektorech

         mov       bx,cx                    ; BX <- po‡et sektor– k na‡ten¡
ZobDRea4:mov       cx,1                     ; bude se ‡¡st po 1 sektoru
         call      ZobD0Rea                 ; ‡ten¡ po 1 sektoru
         jc        ZobDRea6                 ; chyba ‡ten¡
ZobDRea5:dec       bx                       ; ‡¡ta‡ sektor– ke ‡ten¡
         jnz       ZobDRea4                 ; ‡ten¡ dal¨¡ho sektoru
         clc                                ; p©¡znak operace OK
         jmp       short ZobDRea9

; ------ hl ¨en¡ o chybˆ operace

ZobDRea6:call      ZobDRErr                 ; hl ¨en¡ o chybˆ ‡ten¡
         jc        ZobDRea9                 ; p©eru¨en¡ operace
         jz        ZobDRea4                 ; opakov n¡ operace, jinak ignorov n¡

; ------ ignorov n¡ chyby

         call      GetZBSeg                 ; adresa bufferu -> ES
         call      ZobD0Re0                 ; za©azen¡ sektoru
         jmp       short ZobDRea5           ; dal¨¡ sektor

; ------ n vrat registr–

ZobDRea9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZobDRead ENDP

; ------ hl ¨en¡ o rozd¡lu dat (CY=p©eru¨en¡, ZY=opakov n¡, NZ=ignorov n¡)
;     Procedura vol na z obsluhy porovn v n¡ disket !

CmpDRErr PROC      NEAR

         push      si
         mov       si,offset CmpD4Mnu       ; menu pro porovn n¡
         jmp       short ZobDREr1

CmpDRErr ENDP

; ------ hl ¨en¡ o chybˆ z pisu dat (CY=p©eru¨en¡, ZY=opakov n¡, NZ=ignorov n¡)
;     Procedura vol na t‚‘ z obsluhy kop¡rov n¡ disket !

ZobDWErr PROC      NEAR

         push      si
         mov       si,offset DZWMnLin       ; menu pro z pis
         jmp       short ZobDREr1

ZobDWErr ENDP

; ------ hl ¨en¡ o chybˆ ‡ten¡ dat (CY=p©eru¨en¡, ZY=opakov n¡, NZ=ignorov n¡)
;     Procedura vol na t‚‘ z obsluhy kop¡rov n¡ disket !

ZobDRErr PROC      NEAR

         push      si
         mov       si,offset DZCMnLin       ; menu pro ‡ten¡

ZobDREr1:call      far ptr TestBreak        ; je p©eru¨en¡ operace ?
         jc        ZobDREr9                 ; p©eru¨en¡ operace

         push      bx
         push      dx
         push      di
         push      es

         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset DZCMLPl2+1     ; buffer ‡¡sla sektoru
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla
         sub       di,offset DZCMLPl2+1     ; d‚lka textu
         mov       dx,di
         mov       ds:[DZCMLPl2],dl         ; d‚lka textu

         call      far ptr Lin0MenF         ; hl ¨en¡ o chybˆ ‡ten¡

         pushf
         call      far ptr InfoDisp         ; obnoven¡ informa‡n¡ho © dku
         popf

         jnc       ZobDREr8                 ; nen¡ p©eru¨en¡ operace
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku
         call      far ptr SetBreak         ; p©¡znak p©eru¨en¡ operace

ZobDREr8:dec       bx                       ; je opakov n¡ operace ?

         pop       es
         pop       di
         pop       dx
         pop       bx

ZobDREr9:pop       si
         ret

ZobDRErr ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ CX sektor– od DX:AX na adresu DI -> posun DX:AX/DI, CY=chyba
; -----------------------------------------------------------------------------

ZobD0Rea PROC      NEAR

; ------ na‡ten¡ bufferu

         call      ZobDXRea                 ; na‡ten¡ dat do bufferu
         jc        ZobD0Re8                 ; chyba ‡ten¡ dat

; ------ posun ukazatel– po na‡ten¡ dat

ZobD0Re0:push      ax
         push      dx

         mov       ax,ds:[DskLBSkt]         ; AX <- po‡et bajt– na sektor
         mul       cx                       ; AX <- po‡et na‡ten˜ch bajt–
         add       ds:[DZobBNum],ax         ; zv˜¨en¡ po‡tu bajt– v bufferu
         add       di,ax                    ; posun adresy v bufferu

         pop       dx
         pop       ax

         add       ax,cx                    ; posun ‡¡sla sektoru
         adc       dx,0
         clc                                ; p©¡znak operace OK

ZobD0Re8:ret

ZobD0Rea ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ dat z disku (adresa DI, sektor DX:AX, po‡et CX) -> CY=chyba
; -----------------------------------------------------------------------------

ZobDXRea PROC      NEAR

         call      far ptr TestBreak        ; je p©eru¨en¡ operace ?
         jc        ZobDXRe9                 ; p©eru¨en¡ operace

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es
         push      ds

; ------ hl ¨en¡ o na‡¡t n¡ dat z disku

         test      byte ptr ds:[DZAktMod],bit5 ; je hled n¡ ©etˆzce ?
         jz        ZobDXRe2                 ; nen¡ hled n¡ ©etˆzce
         call      ZobDHlIn                 ; zobrazen¡ hl ¨en¡ o hled n¡
         jmp       short ZobDXRe3
ZobDXRe2:mov       si,offset DZCMRead       ; informa‡n¡ text - na‡¡t n¡ dat
         call      far ptr InfDisp0         ; zobrazen¡ hl ¨en¡

; ------ na‡ten¡ dat z disku

ZobDXRe3:call      GetZBSeg                 ; adresa bufferu -> ES
         call      far ptr ReadLDsk         ; na‡ten¡ dat z disku

; ------ pro CD disk se p©i chybˆ sektor vynuluje, je-li < 16

         pushf

         jnc       ZobDXRe6                 ; operace byla OK
         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jz        ZobDXRe6                 ; nen¡ to CD disk
         cmp       cx,1                     ; ‡te se po 1 sektoru ?
         jne       ZobDXRe6                 ; nen¡ ‡ten¡ po 1 sektoru
         or        dx,dx                    ; je sektor < 16 ?
         jnz       ZobDXRe6                 ; nen¡ sektor < 16
         cmp       ax,16                    ; je sektor < 16 ?
         jae       ZobDXRe6                 ; nen¡ sektor < 16

         popf
         clc
         pushf

         push      ax
         push      cx
         push      di

         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
         mov       cx,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         shr       cx,1                     ; CX <- po‡et slov na sektor
         cld
         rep       stosw                    ; vymaz n¡ bufferu

         pop       di
         pop       cx
         pop       ax

; ------ kopie do referen‡n¡ho bufferu (i p©i chybˆ, aby nebyl rozd¡l buffer–)

ZobDXRe6:test      byte ptr ds:[DZAktMod],bit5 ; je hled n¡ ©etˆzce ?
         jnz       ZobDXRe7                 ; je hled n¡ ©etˆzce
         call      far ptr InfoClos         ; uzav©en¡ informa‡n¡ho © dku

ZobDXRe7:mov       ax,ds:[DskLBSkt]         ; AX <- po‡et bajt– na sektor
         mul       cx                       ; AX <- po‡et na‡ten˜ch bajt–
         xchg      ax,cx                    ; CX <- po‡et na‡ten˜ch bajt–

         mov       si,di                    ; SI <- novˆ na‡ten  data
         add       di,ds:[DZobBRef]         ; adresa v referen‡n¡m bufferu
         push      es
         pop       ds                       ; DS <- segment bufferu
         cld
         shr       cx,1                     ; velikost dat ve slovech
         rep       movsw                    ; kopie dat po slovech

         popf

; ------ n vrat registr–

         pop       ds
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
ZobDXRe9:ret

ZobDXRea ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ obsahu bufferu (pokud byl modifikov n; CY=chyba, p©eru¨en¡)
; -----------------------------------------------------------------------------

ZobDWrit PROC      NEAR

; ------ test, zda byla data modifikov na

         test      byte ptr ds:[DZAktMod],bit1 ; byla data modifikov na ?
         jnz       ZobDWrt1                 ; data byla modifikov na
         ret

; ------ £schova registr–

ZobDWrt1:push      ax

         mov       al,ds:[DIMnLDsk]         ; ‡¡slo disku
         mov       ah,bit3+bit4+bit5        ; v¨echna okna
         call      far ptr ModWDisk         ; aktualizace oken

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava registr–

         call      GetZBSeg                 ; adresa bufferu
         and       byte ptr ds:[DZAktMod],not bit4 ; nebyl dotaz pro z pis
         xor       si,si                    ; ukazatel dat v bufferu
         xor       bx,bx                    ; relativn¡ ‡¡slo sektoru

; ------ nalezen¡ zmˆnˆn‚ho sektoru

ZobDWrt2:cmp       si,ds:[DZobBNum]         ; je ji‘ konec bufferu ?
         jb        ZobDWrt3                 ; nen¡ je¨tˆ konec bufferu
         jmp       ZobDWrt8                 ; je ji‘ konec bufferu

ZobDWrt3:mov       cx,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         shr       cx,1                     ; po‡et slov na sektor
         mov       di,si                    ; adresa sektoru
         add       di,ds:[DZobBRef]         ; adresa referen‡n¡ch dat
         push      si
         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         cld
         repe      cmpsw                    ; porovn n¡ sektoru
         pop       ds
         jne       ZobDWrt4                 ; sektor byl modifikov n
         pop       ax                       ; zru¨en¡ adresy sektoru
         inc       bx                       ; zv˜¨en¡ ukazatele ‡¡sla sektoru
         jmp       short ZobDWrt2           ; porovn n¡ dal¨¡ho sektoru

ZobDWrt4:pop       si                       ; adresa za‡ tku sektoru

; ------ dotaz, zda se sektor m  ulo‘it

         test      byte ptr ds:[DZAktMod],bit4 ; byl ji‘ dotaz pro z pis ?
         jnz       ZobDWrt6                 ; byl ji‘ dotaz pro z pis
         or        byte ptr ds:[DZAktMod],bit4 ; p©¡znak dotazu pro z pis

         and       byte ptr ds:[DZRMnBlk],not bit0 ; nen¡ blokov n¡ z pisu
         test      byte ptr ds:[LicDPar0],bit4 ; je DEMO verze ?
         jz        ZobDWr42                 ; nen¡ DEMO verze
         inc       byte ptr ds:[DZRMnBlk]   ; blokov n¡ z pisu

ZobDWr42:push      bx
         push      si
         mov       si,offset DZRMnLin       ; menu dotazu pro z pis
         call      far ptr Lin0MenF         ; potvrzen¡ volby
         dec       bx                       ; maj¡ se zmˆny ulo‘it (=1) ?
         pop       si
         pop       bx
         jc        ZobDWr54                 ; p©eru¨en¡ operace
         jz        ZobDWrt5                 ; proveden‚ zmˆny se maj¡ ulo‘it

; ------ n vrat proveden˜ch zmˆn (v bufferu je sud˜ po‡et bajt–)

         push      ds
         mov       cx,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         mov       si,ds:[DZobBRef]         ; offset referen‡n¡ch dat
         xor       di,di                    ; DI <- 0
         push      es
         pop       ds                       ; DS <- segment bufferu
         shr       cx,1                     ; po‡et slov v bufferu
         cld
         rep       movsw                    ; n vrat p–vodn¡ch dat
         pop       ds
         jmp       short ZobDWrt8

; ------ test, zda je to syst‚mov  oblast

ZobDWrt5:mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor v bufferu
         mov       dx,word ptr ds:[DZobBBeg+2]
         add       ax,bx                    ; ‡¡slo sektoru k z pisu
         adc       dx,0
         jnz       ZobDWrt6                 ; nen¡ to syst‚mov  oblast
         cmp       ax,ds:[DskLBRot]         ; je to syst‚mov  oblast disku ?
         jae       ZobDWrt6                 ; nen¡ to syst‚mov  oblast disku

         push      si
         push      bx
         mov       si,offset DZSMnLin       ; menu - z pis do syst‚mov‚ oblasti
         call      far ptr Lin0MenF         ; potvrzen¡ volby
         pop       bx
         pop       si
ZobDWr54:jc        ZobDWrt9                 ; p©eru¨en¡ operace

; ------ z pis sektoru na disk

ZobDWrt6:mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor v bufferu
         mov       dx,word ptr ds:[DZobBBeg+2]
         add       ax,bx                    ; ‡¡slo sektoru k z pisu
         adc       dx,0
         mov       cx,1                     ; zap¡¨e se 1 sektor
         call      far ptr WritLDsk         ; z pis sektoru na disk
         jnc       ZobDWrt7                 ; data zaps na OK

; ------ hl ¨en¡ - chyba z pisu

ZobDWr64:call      ZobDWErr                 ; chyba z pisu
         jc        ZobDWrt9                 ; p©eru¨en¡ operace
         call      GetZBSeg                 ; adresa bufferu
         jz        ZobDWrt6                 ; opakov n¡ operace
         mov       di,si                    ; DI <- adresa bufferu
         call      far ptr ReadLDsk         ; pokus o na‡ten¡ sektoru
         jmp       short ZobDWr74           ; to co je, to bude platit

; ------ nov‚ na‡ten¡ sektoru z disku (t‚‘ pro verifikaci)

ZobDWrt7:mov       di,si                    ; DI <- adresa bufferu
         call      far ptr ReadLDsk         ; nov‚ na‡ten¡ sektoru z disku
         jc        ZobDWr64                 ; chyba z pisu

; ------ kopie sektoru do referen‡n¡ho bufferu

ZobDWr74:push      ds
         cld
         mov       cx,ds:[DskLBSkt]         ; po‡et bajt– na sektor
         add       di,ds:[DZobBRef]         ; adresa v referen‡n¡m bufferu
         push      es
         pop       ds                       ; DS <- segment bufferu
         shr       cx,1                     ; po‡et slov na sektor
         rep       movsw                    ; £schova na‡ten‚ho sektoru
         pop       ds
         inc       bx                       ; zv˜¨en¡ ‡¡sla sektoru
         jmp       ZobDWrt2                 ; nalezen¡ dal¨¡ho sektoru

; ------ data zaps na OK

ZobDWrt8:and       byte ptr ds:[DZAktMod],not bit1 ; nen¡ modifikace dat

; ------ n vrat registr–

ZobDWrt9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZobDWrit ENDP

; -----------------------------------------------------------------------------
;        test modifikace dat (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

ZobDModi PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ test modifikace dat

         mov       byte ptr ds:[DZMnLPl0],"x" ; p©¡znak z kazu z pisu
         and       byte ptr ds:[DZAktMod],not bit1 ; data nejsou modifikov na
         test      byte ptr ds:[DZAktMod],bit0 ; je m¢d editace ?
         jz        ZobDMod9                 ; nen¡ m¢d editace

         mov       byte ptr ds:[DZMnLPl0]," " ; data nejsou modifikov na
         mov       cx,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         shr       cx,1                     ; po‡et slov v bufferu
         jcxz      ZobDMod9                 ; v bufferu nejsou data

         call      GetZBSeg                 ; adresa bufferu -> ES
         xor       si,si                    ; ukazatel dat v bufferu
         mov       di,ds:[DZobBRef]         ; referen‡n¡ data v bufferu

         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         cld
         repe      cmpsw                    ; porovn n¡ buffer–
         pop       ds
         je        ZobDMod9                 ; buffery jsou shodn‚

         or        byte ptr ds:[DZAktMod],bit1 ; byla modifikace dat
         mov       byte ptr ds:[DZMnLPl0],"!" ; p©¡znak modifikace dat

; ------ n vrat registr–

ZobDMod9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         popf
         ret

ZobDModi ENDP

; -----------------------------------------------------------------------------
;        inicializace menu zobrazen¡ disku DS:SI
; -----------------------------------------------------------------------------

InitZMnu PROC      FAR

         push      ax
         mov       al,ds:[Radku]            ; po‡et © dk– obrazovky
         dec       ax
         mov       ds:[si+MnuVys],al        ; v˜¨ka okna
         call      far ptr CentMenu         ; vyst©edˆn¡ okna menu
         mov       byte ptr ds:[si+MnuRad],0

         cmp       byte ptr ds:[Pozic],80   ; pro > 80 znak– by ‡as ujel mimo
         jbe       InitZMn2
         mov       byte ptr ds:[si+MnuRad],1 ; po‡ te‡n¡ © dek okna menu
         sub       al,2
         mov       ds:[si+MnuVys],al

InitZMn2:sub       al,3
         mov       byte ptr ds:[DZobBVys],al ; zobrazen  v˜¨ka okna
         mov       ah,16
         mul       ah
         mov       ds:[DZobBV16],ax         ; zobrazen  velikost dat
         pop       ax
         ret

InitZMnu ENDP

; *****************************************************************************
;                  zobrazen¡ prohl¡‘e‡e disku DS:SI
; -----------------------------------------------------------------------------
; VSTUP: SI=definice menu
;        DS=datov˜ segment
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-1] (1) © dek na displeji
;                   SS:[BP-2] (1) pozice na displeji
;                   SS:[BP-3] (1) ‡¡ta‡ vnit©n¡ch © dk– k zobrazen¡
;                   SS:[BP-4] (1) ¨¡©ka okna
;                   SS:[BP-6] (2) hladina k zobrazen¡
;                   SS:[BP-8] (2) segment bufferu s daty
;                   SS:[BP-10] (2) ukazatel dat v bufferu
;                   SS:[BP-12] (2) ‡¡ta‡ zbyl˜ch dat v bufferu
;                   SS:[BP-14] (2) ‡¡ta‡ kurzoru
;                   SS:[BP-15] (1) barva rozd¡ln˜ch dat
;                   SS:[BP-16] (1) barva bˆ‘n˜ch dat
;                   SS:[BP-17] (1) barva rozd¡ln‚ho kurzoru
;                   SS:[BP-18] (1) barva kurzoru
;                   SS:[BP-22] (4) offset dat na disku (v bajtech)
;                   SS:[BP-23] (1) ‡¡ta‡ © dku s horn¡ ¨ipkou ukazatele
;                   SS:[BP-24] (1) ‡¡ta‡ © dku s kurzorem ukazatele
; *****************************************************************************
;þ
DispZMnu PROC      FAR

         call      far ptr DispRamM         ; zobrazen¡ horn¡ a doln¡ linky

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©¡prava bufferu v z sobn¡ku

         sub       sp,24                    ; buffer pro lok ln¡ promˆnn‚
         mov       al,ds:[si+MnuSir]        ; ¨¡©ka okna
         mov       ah,0
         shl       ax,1                     ; po‡et bajt– na © dek
         sub       sp,ax                    ; lok ln¡ buffer

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         mov       ax,word ptr ds:[si+MnuPoz] ; © dek a pozice menu
         inc       ah                       ; po‡ te‡n¡ © dek
         mov       ss:[bp-2],ax             ; © dek a pozice k zobrazen¡
         mov       ax,word ptr ds:[si+MnuSir] ; ¨¡©ka a v˜¨ka okna
         sub       ah,3                     ; vnit©n¡ v˜¨ka okna
         mov       ss:[bp-4],ax             ; ¨¡©ka a v˜¨ka okna
         mov       al,ds:[si+MnuLev]        ; hladina k zobrazen¡
         mov       ah,0
         mov       ss:[bp-6],ax             ; hladina k zobrazen¡
         call      GetZBSeg                 ; poskytnut¡ adresy bufferu
         mov       ss:[bp-8],es             ; segment adresy bufferu
         mov       ax,ds:[DZobBTop]         ; offset zobrazen‚ho po‡ tku
         mov       ss:[bp-10],ax            ; ukazatel dat v bufferu
         xchg      ax,cx                    ; CX <- po‡ tek dat v bufferu
         mov       ax,ds:[DZobBNum]         ; po‡et bajt– v bufferu
         sub       ax,cx                    ; po‡et zbyl˜ch dat v bufferu
         mov       ss:[bp-12],ax            ; ‡¡ta‡ zbyl˜ch dat v bufferu
         mov       ax,ds:[DZobBKur]         ; offset kurzoru v bufferu
         sub       ax,ds:[DZobBTop]         ; offset od po‡ tku
         inc       ax                       ; p©ednastaven¡ ‡¡ta‡e
         mov       ss:[bp-14],ax            ; ‡¡ta‡ kurzoru
         mov       ax,word ptr ds:[ColDZob1] ; bˆ‘n  barva
         mov       ss:[bp-16],ax            ; bˆ‘n  barva
         mov       ax,word ptr ds:[ColDZob3] ; barva kurzoru
         mov       ss:[bp-18],ax            ; barva kurzoru
         mov       ax,word ptr ds:[DZobBBeg+2] ; po‡ te‡n¡ sektor v bufferu HIGH
         mul       word ptr ds:[DskLBSkt]   ; p©epo‡et na offset HIGH
         mov       ss:[bp-22+2],ax          ; offset dat HIGH
         mov       ax,word ptr ds:[DZobBBeg] ; po‡ te‡n¡ sektor LOW
         mul       word ptr ds:[DskLBSkt]   ; p©epo‡et na offset LOW
         add       ax,ds:[DZobBTop]         ; p©i‡ten¡ offsetu po‡ tku dat
         mov       ss:[bp-22],ax            ; offset dat LOW
         adc       ss:[bp-22+2],dx          ; offset dat HIGH

; ------ p©¡prava ‡¡ta‡e ukazatele

         mov       ax,ds:[DZobBKur]         ; offset kurzoru v bufferu
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DskLBSkt]   ; p©epo‡et na sektory
         xor       dx,dx                    ; DX <- 0
         add       ax,word ptr ds:[DZobBBeg] ; + po‡ te‡n¡ sektor bufferu
         adc       dx,word ptr ds:[DZobBBeg+2]

         push      ax                       ; DX:AX = sektor s kurzorem
         push      dx

         mov       cx,word ptr ds:[DskLNSkt] ; celkov˜ po‡et sektor– LOW
         mov       bx,word ptr ds:[DskLNSkt+2] ; celkov˜ po‡et sektor– HIGH
         cmp       dx,bx                    ; je p©ete‡en¡ konce ?
         jne       DispZM01
         cmp       ax,cx
DispZM01:jbe       DispZM02                 ; ‡¡slo je OK
         mov       ax,cx                    ; AX <- omezen¡ kurzoru
         mov       dx,bx
DispZM02:or        bx,bx                    ; je ji‘ normalizov no ?
         jz        DispZM04                 ; je to ji‘ normalizov no
         shr       bx,1
         rcr       cx,1
         shr       dx,1
         rcr       ax,1
         jmp       short DispZM02

DispZM04:jcxz      DispZM08
         cmp       ax,cx
         jb        DispZM05
         mov       ax,cx
         dec       ax
DispZM05:xchg      ax,dx                    ; DX:AX = kurzor * 65K
         div       cx                       ; AX <- pomˆrn  ‡ st * 65K
         mov       cx,ds:[DZobBVys]         ; zobrazen  v˜¨ka editoru
         dec       cx
         dec       cx                       ; bez ¨ipek
         mul       cx                       ; v˜po‡et pozice ukazatele
         inc       dx                       ; korekce ‡¡ta‡e
         mov       dh,1                     ; ‡¡ta‡ ¨ipky
         mov       ss:[bp-24],dx            ; ‡¡ta‡ kurzoru a ‡¡ta‡ ¨ipky

DispZM08:pop       dx                       ; sektor s kurzorem
         pop       ax

;; ------ p©¡znak modifikace dat
;
;         mov       byte ptr ds:[DZMnLPl0]," " ; data nejsou modifikov na
;         test      byte ptr ds:[DZAktMod],bit1 ; byla modifikace dat ?
;         jz        DispZM09                 ; data nebyla modifikov na
;         mov       byte ptr ds:[DZMnLPl0],"*" ; p©¡znak modifikace dat
;
; ------ dek¢dov n¡ ‡¡sla sektoru kurzoru (DX:AX=sektor s kurzorem)

DispZM09:push      ds
         pop       es                       ; ES <- DS
         mov       di,offset DZMnLPl6+1     ; buffer ‡¡sla sektoru
         mov       bh,0                     ; barva nen¡
         mov       bl,ds:[OddelRad]         ; oddˆlova‡ © d–
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla
         sub       di,offset DZMnLPl6+1     ; d‚lka textu
         mov       cx,di
         mov       ds:[DZMnLPl6],cl         ; d‚lka textu

; ------ test, zda je to BOOT

         mov       word ptr ds:[DZMnLPl1],offset DZMnLPl2 ; je to BOOT
         sub       ax,ds:[DskLBFat]         ; ode‡ten¡ sektoru BOOT
         sbb       dx,0
         jb        DispZMn2                 ; je to ROOT

; ------ test, zda je to FAT

         mov       word ptr ds:[DZMnLPl1],offset DZMnLPl3 ; je to FAT
         mov       byte ptr ds:[DZMnLPl3+4],"1" ; ozna‡en¡ FAT 1
         mov       cl,ds:[DskLNFat]         ; po‡et tabulek FAT
         mov       ch,0
         jcxz      DispZM12                 ; nen¡ tabulka FAT (?)
DispZMn1:sub       ax,ds:[DskLSFat]         ; ode‡ten¡ sektor– jedn‚ FAT
         sbb       dx,0
         jb        DispZMn2                 ; je to FAT
         inc       byte ptr ds:[DZMnLPl3+4] ; zv˜¨en¡ ‡¡sla FAT
         loop      DispZMn1                 ; dal¨¡ tabulka FAT

; ------ test, zda je to ROOT

DispZM12:mov       word ptr ds:[DZMnLPl1],offset DZMnLPl4 ; je to ROOT
         sub       ax,ds:[DskLSRot]         ; ode‡ten¡ sektor– pro ROOT
         sbb       dx,0
         jb        DispZMn2                 ; je to ROOT

; ------ dek¢dov n¡ ‡¡sla bloku (BL=oddˆlova‡ © d–, BH=0)

         mov       word ptr ds:[DZMnLPl1],offset DZMnLPl5 ; je to blok
         cmp       dx,ds:[DskLSBlk]         ; bylo by p©ete‡en¡ ?
         jb        DispZM14                 ; nen¡ p©ete‡en¡
         mov       dx,ds:[DskLSBlk]         ; pro omezen¡
         xor       ax,ax
         sub       ax,1
         sbb       dx,0
         jc        DispZMn2                 ; nen¡ dosud inicializov no
DispZM14:div       word ptr ds:[DskLSBlk]   ; v˜po‡et ‡¡sla bloku relativnˆ
         inc       ax
         inc       ax                       ; korekce - ‡¡slo po‡ te‡n¡ho bloku
         mov       di,offset DZMnLPl5+1     ; buffer ‡¡sla bloku
         call      far ptr DekNumW          ; dek¢dov n¡ ‡¡sla
         sub       di,offset DZMnLPl5+1     ; d‚lka textu
         xchg      ax,di
         mov       ds:[DZMnLPl5],al         ; d‚lka textu

; ------ dek¢dov n¡ offsetu kurzoru (BL=oddˆlova‡ © d–, BH=0)

DispZMn2:mov       ax,ss:[bp-22]            ; offset dat LOW
         mov       dx,ss:[bp-22+2]          ; offset dat HIGH
         mov       cx,ss:[bp-14]            ; ‡¡ta‡ kurzoru
         dec       cx                       ; offset kurzoru od po‡ tku
         add       ax,cx                    ; offset kurzoru
         adc       dx,0
         mov       di,offset DZMnLPl7+1     ; buffer offsetu kurzoru
         call      far ptr DekNum           ; dek¢dov n¡ ‡¡sla
         sub       di,offset DZMnLPl7+1     ; d‚lka textu
         xchg      ax,di
         mov       ds:[DZMnLPl7],al         ; d‚lka textu

; ------ dek¢dov n¡ prvn¡ho © dku

         mov       si,offset DZMnLPol       ; definice © dku
         mov       dx,ss:[bp-2]             ; © dek a pozice
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         call      far ptr DispTxtM         ; zobrazen¡ © dku nadpisu
         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku

; ------ vymaz n¡ © dku

DispZMn3:push      ss
         pop       es
         mov       di,sp                    ; buffer v z sobn¡ku
         cld
         mov       ah,ds:[ColMnu1R]         ; bˆ‘n  barva menu
         mov       al,"³"                   ; "³"
         stosw                              ; lev˜ okraj
         push      di
         mov       ch,0
         mov       cl,ss:[bp-4]             ; ¨¡©ka okna
         dec       cx
         dec       cx                       ; bez okraj–
         mov       ah,ds:[ColDZob1]         ; bˆ‘n  barva
         mov       al," "
         rep       stosw                    ; vymaz n¡ © dku

         mov       ah,ds:[ColMnu1]
         mov       al,1eh                   ; ¨ipka nahoru
         dec       byte ptr ss:[bp-23]      ; ‡¡ta‡ © dku s ¨ipkou
         jz        DispZM31                 ; je © dek s ¨ipkou
         mov       al,1fh                   ; ¨ipka dol–
         cmp       byte ptr ss:[bp-3],1     ; je posledn¡ © dek ?
         je        DispZM31                 ; je posledn¡ © dek

         mov       al,4                     ; znak kurzoru
         dec       byte ptr ss:[bp-24]      ; ‡¡ta‡ © dku s kurzorem
         jz        DispZM31                 ; je kurzor
         mov       al,"²"                   ; jinak plocha ukazatele
DispZM31:stosw                              ; prav˜ okraj
         pop       di                       ; po‡ tek bufferu

; ------ test, zda jsou dal¨¡ data

         cmp       word ptr ss:[bp-12],0    ; jsou dal¨¡ data v bufferu ?
         jne       DispZM32                 ; jsou dal¨¡ data
         jmp       DispZMn8                 ; nejsou dal¨¡ data

; ------ dek¢dov n¡ po‡ te‡n¡ adresy © dky

DispZM32:mov       bh,ss:[bp-16]            ; barva bˆ‘n˜ch dat
         mov       ax,ss:[bp-22+2]          ; offset dat HIGH
         call      far ptr DekHWord         ; offset dat HIGH
         mov       ah,bh                    ; barva bˆ‘n˜ch dat
         mov       al,":"
         cld
         stosw                              ; oddˆlovac¡ znak
         mov       ax,ss:[bp-22]            ; offset dat LOW
         call      far ptr DekHWord         ; offset dat LOW

         mov       ah,ds:[ColDZob0]         ; barva oddˆlovac¡ ‡ ry
         mov       al,"³"
         cld
         stosw                              ; oddˆlovac¡ ‡ ra

; ------ dek¢dov n¡ dat HEX

         mov       si,ss:[bp-10]            ; ukazatel dat v bufferu
         mov       cx,16                    ; po‡et bajt– k dek¢dov n¡
         mov       bx,ds:[DZobBRef]         ; offset referen‡n¡ch dat
         push      ds
         mov       ds,ss:[bp-8]             ; segment bufferu s daty
         jmp       short DispZM44

; ------ oddˆlovac¡ mezera p©ed bajtem (AH=bˆ‘n  barva)

DispZMn4:mov       al," "                   ; oddˆlovac¡ mezera
         stosw

         test      cl,bit1+bit0             ; je ‡tve©ice ?
         jnz       DispZM44                 ; nen¡ ‡tve©ice
         test      cl,bit2
         jz        DispZM44
         stosw                              ; dopl¤uj¡c¡ oddˆlovac¡ mezera

; ------ na‡ten¡ dal¨¡ho znaku

DispZM44:lodsb                              ; na‡ten¡ bajtu k zobrazen¡

; ------ p©¡prava barvy znaku -> AH

         mov       dx,ss:[bp-16]            ; barva bˆ‘n˜ch dat
         dec       word ptr ss:[bp-14]      ; je to kurzor ?
         jnz       DispZMn5                 ; nen¡ to kurzor
         mov       dx,ss:[bp-18]            ; barva kurzoru
DispZMn5:mov       ah,dh                    ; barva rozd¡ln˜ch dat
         cmp       al,ds:[si+bx-1]          ; li¨¡ se bajt ?
         jne       DispZMn6                 ; bajt se li¨¡
         mov       ah,dl                    ; barva shodn˜ch dat

; ------ dek¢dov n¡ znaku ASCII

DispZMn6:push      di
         mov       di,sp                    ; DI <- buffer + 2
         add       di,2+2+2*78+2            ; konec bufferu
         sub       di,cx
         sub       di,cx                    ; adresa k ulo‘en¡ znaku ASCII
         stosw                              ; ulo‘en¡ znaku ASCII
         pop       di

; ------ dek¢dov n¡ znaku HEX

         call      far ptr DekHByte         ; dek¢dov n¡ bajtu v HEX k¢du

; ------ oddˆlovac¡ znak

         mov       ah,ss:[bp-16]            ; bˆ‘n  barva
         cmp       cl,8+1                   ; je st©ed © dku ?
         jne       DispZMn7                 ; nen¡ st©ed © dku
         mov       al," "
         stosw                              ; oddˆlovac¡ mezera
         mov       al,"-"
         stosw                              ; oddˆlovac¡ znak

; ------ dal¨¡ znak na © dku

DispZMn7:loop      DispZMn4                 ; dal¨¡ bajt
         pop       ds

; ------ oddˆlovac¡ ‡ ra mezi HEX a ASCII

         mov       ah,ds:[ColDZob0]         ; barva ‡ ry
         mov       al,"³"
         stosw                              ; oddˆlovac¡ ‡ ra

; ------ posun ukazatel– © dku

         mov       ax,16
         add       ss:[bp-22],ax            ; zv˜¨en¡ ukazatele dat LOW
         adc       word ptr ss:[bp-22+2],0  ; p©enos HIGH
         sub       ss:[bp-12],ax            ; sn¡‘en¡ zbyl˜ch dat v bufferu
         add       ss:[bp-10],ax            ; zv˜¨en¡ ukazatele dat v bufferu

; ------ zobrazen¡ © dku

DispZMn8:mov       si,sp                    ; buffer v z sobn¡ku
         mov       cl,ss:[bp-4]             ; ¨¡©ka © dku
         mov       ax,ss:[bp-6]             ; hladina k zobrazen¡
         mov       dx,ss:[bp-2]             ; © dek a pozice k zobrazen¡
         call      far ptr DispMStr         ; zobrazen¡ © dku

; ------ p©¡prava pro dal¨¡ © dek

         inc       byte ptr ss:[bp-1]       ; zv˜¨en¡ ukazatele © dku
         dec       byte ptr ss:[bp-3]       ; ‡¡ta‡ © dk– k zobrazen¡
         jz        DispZMn9                 ; jsou ji‘ v¨echny © dky
         jmp       DispZMn3                 ; zobrazen¡ dal¨¡ho © dku

; ------ n vrat registr–

DispZMn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispZMnu ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru (menu DS:SI)
; -----------------------------------------------------------------------------

DispZDK  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      dx

;; ------ vypnut¡ kurzoru, nen¡-li editace
;
;         test      byte ptr ds:[DZAktMod],bit0 ; je m¢d editace ?
;         jnz       DispZDK3                 ; je m¢d editace
;DispZDK2:call      far ptr KurzOff          ; vypnut¡ kurzoru
;         jmp       short DispZDK9

; ------ offset kurzoru od po‡ tku

DispZDK3:mov       ax,ds:[DZobBKur]         ; offset kurzoru v bufferu
         sub       ax,ds:[DZobBTop]         ; offset kurzoru od po‡ tku
;         jc        DispZDK2                 ; kurzor mimo
;         cmp       ax,ds:[DZobBNum]         ; je kurzor platn˜ ?
;         ja        DispZDK2                 ; kurzor mimo
         mov       dl,al
         and       dl,0fh                   ; offset kurzoru na © dku relativnˆ
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; offset/16 -> © dek kurzoru
         mov       dh,al                    ; © dek kurzoru relativnˆ
         add       dh,2                     ; korekce © dku s kurzorem
         test      byte ptr ds:[DZAktMod],bit2 ; je ASCII pole ?
         jnz       DispZDK5                 ; je ASCII pole

; ------ zobrazen¡ kurzoru, je-li HEX pole

         mov       al,dl                    ; AL <- pozice kurzoru relativnˆ
         add       dl,al
         add       dl,al                    ; pozice * 3
         shr       al,1
         shr       al,1
         add       dl,al
         shr       al,1
         add       dl,al
         add       dl,11 - (79-16)
         test      byte ptr ds:[DZAktMod],bit3 ; je 2. znak HEX ?
         jz        DispZDK5                 ; je 1. znak HEX
         inc       dx                       ; korekce - je 2. znak HEX

; ------ zobrazen¡ kurzoru, je-li ASCII pole

DispZDK5:add       dl,79-16
         add       dl,ds:[si+MnuPoz]        ; pozice kurzoru
         add       dh,ds:[si+MnuRad]        ; © dek s kurzorem
         call      far ptr SetKurz          ; zobrazen¡ kurzoru

; ------ n vrat registr–

DispZDK9:pop       dx
         pop       ax
         ret

DispZDK  ENDP

; -----------------------------------------------------------------------------
;        adresa bufferu diskov‚ho editoru (uchov v  registr p©¡znak– !)
; -----------------------------------------------------------------------------

GetZBSeg PROC      NEAR

         pushf
         push      ax
         mov       ax,ds:[DZobBSeg]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         pop       ax
         popf
         ret

GetZBSeg ENDP

CodeDisk ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                                 Data
;
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

; -----------------------------------------------------------------------------
;        Menu informace o disku
; -----------------------------------------------------------------------------

DIMnuLin label     byte                   ;* informace o souboru

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        18                       ; celkov˜ po‡et polo‘ek menu

         dw        DIMnLPol                 ; za‡ tek definice polo‘ek menu
         dw        ChbLnMeH                 ; adresa tabulky text– n povˆdy
         dw        Hlp@InformaceODisku      ; ‡¡slo str nky velk‚ n povˆdy
         dw        DIMnLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DIMnLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        21                       ; po‡ te‡n¡ pozice okna
         db        5                        ; po‡ te‡n¡ © dek okna
         db        60                       ; ¨¡©ka okna
         db        22                       ; v˜¨ka okna

         dw        250                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

DIMnLPol db        bit6,10
         db        'Jm‚no ',0,1
DIMJmenA dw        DIMJmeno

         db        bit6,18
         db        'S‚riov‚ ‡¡slo ',0,1
DIMSercA dw        DIMSerc

         db        bit6,0

         db        bit6,16
         db        2,3,'kapacita: ',0,1
         dw        DIMKapac

         db        bit6,13
         db        2,6,'voln‚: ',0,1
         dw        DIMVolne

         db        bit6,12
         db        'sektor: ',0,1
         dw        DIMSekt

         db        bit6,17
         db        'datov˜ blok: ',0,1
         dw        DIMBlok

         db        bit6,17
         db        'po‡et blok–: ',0,1
         dw        DIMNBlok

         db        bit6,12
         db        2,6,'ROOT: ',0,1
         dw        DIMRoot

         db        bit6,13
         db        2,9,'FAT1'
DIMFatT  db        '6: ',0,1
         dw        DIMFat

         db        bit6,15
         db        'popisova‡: ',0,1
         dw        DIMPopis

         db        bit6,0

         db        bit6,11
         db        2,8,'typ: ',0,1
         dw        DIMTyp

         db        bit6,11
         db        'v lc–: ',0,1
         dw        DIMValcu

         db        bit6,11
         db        'stran: ',0,1
         dw        DIMStran

         db        bit6,15
         db        2,4,'sektor–: ',0,1
         dw        DIMStopa

         db        bit6+bit7,0

         db        1,6,'N vrat'

DIMnLBlk db        0                        ; blokovac¡ tabulka

DIMnTxtC db        28,'Na‡¡t m informace o disku...'

DIMnLTit db        20,'informace o disku '
DIMnLTi1 db        'A:'

DIMnLDsk db        0                        ; disk

DInfSekt dw        0                        ; velikost sektoru (bajt–)
DInfSBlk dw        0                        ; po‡et sektor– na blok
DInfBlok dw        0                        ; velikost bloku (bajt–)
DInfCelk dw        0                        ; velikost disku v bloc¡ch
DInfRoot dw        0                        ; po‡et polo‘ek v ROOT
DInfNFAT db        0                        ; po‡et FAT
DInfFAT  dw        0                        ; po‡et sektor– na FAT
DInfPop  db        0                        ; popisova‡ m‚dia
DInfVal  dw        0                        ; po‡et v lc–
DInfStrn dw        0                        ; po‡et stran
DInfSekS dw        0                        ; po‡et sektor– na stopu

DIMNeni  db        4,'nem '
DIMJmeno db        1,11+1+2+10+3+8+1 dup(" ")
DIMSerc  db        9,'    -    '
DIMKapac db        16,16 dup(" ")
DIMVolne db        16,16 dup(" ")
DIMSekt  db        11,11 dup(" ")
DIMBlok  db        16,16 dup(" ")
DIMNBlok db        14,14 dup(" ")
DIMRoot  db        15,15 dup(" ")
DIMFat   db        21,21 dup(" ")
DIMPopis db        14,14 dup(" ")
DIMTyp   db        16,16 dup(" ")
DIMValcu db        10,10 dup(" ")
DIMStran db        10,10 dup(" ")
DIMStopa db        16,16 dup(" ")

DIMRootT db        0,' polo‘ek'
DIMRotT0 label     byte

DIMFatT1 db        0,' x ',0
DIMFatTT db        0,' sekt.'
DIMFatT0 label     byte

DIMStopT db        0,' na stopu'
DIMStop0 label     byte

DIMTypT  db        1,'-'                    ; 0: nezn m˜ disk
         db        10,'disketa '            ; 1: disketa
DIMTypTH db        'HD'
         db        10,'pevn˜ disk'          ; 2: pevn˜ disk
         db        8,'RAM disk'             ; 3: RAM disk
         db        11,'s¡Ÿov˜ disk'         ; 4: s¡Ÿov˜ disk
         db        10,'SUBST disk'          ; 5: SUBST disk
         db        11,'CD-ROM disk'         ; 6: CD-ROM disk
         db        1,'-'                    ; 7: ...zat¡m rezervov no

; -----------------------------------------------------------------------------
;        mapa disku
; -----------------------------------------------------------------------------
;þ
DMMnuLin label     byte

         db        13                       ; typ menu - mapa disku

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        1                        ; celkov˜ po‡et polo‘ek menu

         dw        DMMnLPol                 ; za‡ tek definice polo‘ek menu
         dw        DMMnLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@MapaDisku            ; ‡¡slo str nky velk‚ n povˆdy
         dw        DMMnLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DMMnLTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        21                       ; po‡ te‡n¡ pozice okna
         db        5                        ; po‡ te‡n¡ © dek okna
         db        70+4                     ; ¨¡©ka okna
         db        14+6                     ; v˜¨ka okna

; ------ polo‘ky voleb

DMMnLPol db        bit6,28,'Jedna pozice = ',0,1
         dw        DMMnLPlN
         db        0,' blok',1
DMMnLPl1 dw        DMMnLPl2

DMMnLPl2 db        0
DMMnLPl3 db        1,'y'
DMMnLPl4 db        1,'–'

DMMnLPlN db        1,'1     '

DMMnLPl5 db        'B = Boot, F = FAT, R = Root, x = vadn˜'
DMMnLPl6 label     byte

DMMnLPl8 db        '. = voln˜, ± = nezaplnˆn˜, ',7,' = obsazen˜'
DMMnLPl9 label     byte

DMMnLBlk label     byte                     ; blokovac¡ tabulka
;þ
DMMnLPSk db        bit6,65,'(sektor ',0,1
         dw        DMMnLPS1
         db        0,', blok ',0,1
         dw        DMMnLPS2
         db        0,', rychlost ',0,1
         dw        DMMnLPS3
         db        0,' KB/sekundu = ',0,1
         dw        DMMnLPS4
         db        0,'x CD)'

DMMnLPS1 db        13,13 dup("0")
DMMnLPS2 db        6,6 dup("0")
DMMnLPS3 db        13,13 dup("0")
DMMnLPS4 db        13,13 dup("0")

HelpS    SEGMENT   BYTE PUBLIC
DMMnLHlp db        31,'Stisknˆte libovolnou kl vesu...'
HelpS    ENDS

DMMnLTit db        13,'mapa disku '
DMMnLTi1 db        'A:'

DMapSegN dw        0                        ; po‡et bajt– segmentu mapy
DMapSeg  dw        0                        ; segment mapy disku
                                            ; velikost segmentu = SIRKA * VYSKA
                                            ;  1 bajt: bit 0: 1=obsazen‚ bloky
                                            ;          bit 1: 1=vadn‚ bloky
                                            ;          bit 2: 1=voln‚ bloky
                                            ;          (bit 3: 1=BOOT)
                                            ;          (bit 4: 1=FAT)
                                            ;          (bit 5: 1=BOOT)
                                            ;          (bit 6: 1=pat©¡ souboru)

DMapSir  dw        70                       ; ¨¡©ka mapy disku
DMapVys  dw        14                       ; v˜¨ka mapy disku
DMapSize dw        70*14                    ; velikost mapy disku (pozic)

DMapBlk  dw        1                        ; po‡et blok– na pozici mapy

;ColDMapS db        34h                      ; barva syst‚mov‚ pozice
;ColDMapF db        8                        ; barva voln‚ pozice
;ColDMapC db        30h                      ; barva obsazen‚ pozice
;ColDMapB db        4eh                      ; barva vadn‚ pozice
;ColDMapV db        1eh                      ; barva verifikace

DMMnTxt  db        26,'Na‡¡t m strukturu disku...'

; -----------------------------------------------------------------------------
;        Verifikace disku
; -----------------------------------------------------------------------------
;þ
DVMnuLin label     byte                   ;* informace o souboru

         db        13                       ; typ menu - mapa disku

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        1                        ; celkov˜ po‡et polo‘ek menu

         dw        DMMnLPol                 ; za‡ tek definice polo‘ek menu
         dw        DVBMnHl2                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Verifikacedisku      ; ‡¡slo str nky velk‚ n povˆdy
         dw        DMMnLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DVMnLTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        21                       ; po‡ te‡n¡ pozice okna
         db        5                        ; po‡ te‡n¡ © dek okna
         db        70+4                     ; ¨¡©ka okna
         db        14+6                     ; v˜¨ka okna

DVMnLTit db        19,'verifikace disku '
DVMnLTi1 db        'A:'

; ------ chyba ‡ten¡ p©i verifikaci

DVBMnLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        DVBMnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        DVBMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@Verifikacedisku      ; ‡¡slo str nky velk‚ n povˆdy
         dw        DVBMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DVBMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        54                       ; ¨¡©ka
         db        10                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

DVBMnPol db        bit6,0

         db        bit6,38,'Chyba ‡ten¡ sektoru ',0,1
         dw        DVBMnPl3                 ; ‡¡slo sektoru
         db        0,' (blok ',0,1
DVBMnPl1 dw        DVBMnPl4                 ; ‡¡slo bloku
         db        0,')'

         db        bit6,3,1
DVBMnPl2 dw        DVBMnPl5

         db        bit6,0
         db        bit6+bit7,0
         db        1,7,'Ozna‡it'
         db        1,5,'Dal¨¡'
         db        1,8,'P©eru¨it'

DVBMnPl3 db        13,'1.234.567.890'       ; ‡¡slo sektoru
DVBMnPl4 db        6,'12.345'               ; ‡¡slo bloku
DVBMnPlB db        4,'BOOT'
DVBMnPlF db        3,'FAT'
DVBMnPlR db        4,'ROOT'

DVBMnPl5 db        44,'Blok nen¡ voln˜, nelze jej ozna‡it za vadn˜.'
DVBMnPl6 db        28,'Blok lze ozna‡it jako vadn˜.'

HelpS    SEGMENT   BYTE PUBLIC
DVBMnHlp db        36,'Ozna‡en¡ nalezen‚ho bloku jako vadn˜'
         db        32,'Pokra‡ov n¡ v operaci verifikace'
         db        3,1
         dw        MenuHlP2
DVBMnHl2 db        56,'Stisknˆte: Enter=opakov n¡ verifikace, Esc=p©eru¨en¡'
HelpS    ENDS

DVBMnBlk db        0,0,0                    ; blokovac¡ tabulka
DVBMnTit db        16,'ne‡iteln˜ sektor'

; ------ data pro verifikaci

DVDskSeg dw        0                        ; buffer pro verifikaci bloku
DVDskSNm dw        0                        ; velikost bufferu v sektorech
DVDskOfs dw        -1                       ; uschovan˜ offset v mapˆ
DVDskDel dw        1                        ; d‚lka kurzoru operace
DVDskDl0 dw        1                        ; d‚lka kurzoru operace
DVDskCit dd        0                        ; ‡¡ta‡ zbyl˜ch sektor– k operaci
DVDsk1Sk dw        0                        ; ‡¡ta‡ 1-sektorov‚ operace (0=nen¡)

DVDskBeg dd        0                        ; ‡as po‡ tku operace verifikace
DVDskCt0 dd        0                        ; sektor po‡ tku operace verifikace

DVDSmart db        -1                       ; uschovan˜ stav SMARTDRV (-1=nen¡)

DVMnTxt  db        80,'Ovˆ©uji ‡itelnost dat disku (',0,'Mezera',0,'=restart mˆ©en¡, ',0,'kurzory',0,'=zmˆna pozice)...'

; -----------------------------------------------------------------------------
;        zobrazen¡/editace disku
; -----------------------------------------------------------------------------
;þ
DZMnuLin label     byte

         db        14                       ; typ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        1                        ; celkov˜ po‡et polo‘ek menu

         dw        DZMnLPol                 ; za‡ tek definice polo‘ek menu
         dw        DZMnLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZMnLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZMnLTit                 ; adresa titulu okna
         dw        LinMenTM                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        0                        ; po‡ te‡n¡ pozice okna
         db        1                        ; po‡ te‡n¡ © dek okna
         db        80                       ; ¨¡©ka okna
         db        22                       ; v˜¨ka okna

DZMnLPol db        bit6,offset(DZMnLPl2-DZMnLPol)-2
DZMnLPl0 db        '  blok: ',0,1
DZMnLPl1 dw        DZMnLPl5
         db        0,', sektor: ',0,1
         dw        DZMnLPl6
         db        0,', offset: ',0,1
         dw        DZMnLPl7

DZMnLPl2 db        4,'BOOT'
DZMnLPl3 db        4,'FAT1'
DZMnLPl4 db        4,'ROOT'
DZMnLPl5 db        6,'65.535'
DZMnLPl6 db        13,'1.234.234.234'
DZMnLPl7 db        13,'1.234.567.890'

DZMnLBlk db        0                        ; blokovac¡ tabulka

HelpS    SEGMENT   BYTE PUBLIC
DEMnLHlp db        91,'F2=ulo‘, F5=vlastn¡k, F6=skok, F7=hledej, Tab=HEX/ASC, BS=obnov, ',27,'Ctrl',26,' zmˆny'
DZMnLHlp db        80,'F5=vlastn¡k, F6=skok, F7=hledej, Tab=HEX/ASC, Ctrl-L=d le, Esc=konec'
HelpS    ENDS

DEMnLHlM label     byte
         db        9
         dw        3c00h                    ; F2
         db        13
         dw        3f00h                    ; F5
         db        9
         dw        4000h                    ; F6
         db        11
         dw        4100h                    ; F7
         db        13
         dw        0f09h                    ; Tab
         db        10
         dw        0e08h                    ; BS
         db        4
         dw        7300h                    ; Ctrl-vlevo
         db        -1
         dw        7400h                    ; Ctrl-vpravo

DZMnLHlM label     byte
         db        13
         dw        3f00h                    ; F5
         db        9
         dw        4000h                    ; F6
         db        11
         dw        4100h                    ; F7
         db        13
         dw        0f09h                    ; Tab
         db        13
         dw        260ch                    ; Ctrl-L
         db        -1
         dw        11bh                     ; Esc

DZMnLTit db        18,'zobrazen¡ disku '
DZMnLTi1 db        'A:'

DEMnLTit db        16,'editace disku '
DEMnLTi1 db        'A:'

DZCMRead db        24,'Na‡¡t m data z disku....'

; ------ chyba ‡ten¡ z disku

DZCMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        DZCMnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        DZCMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZCMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZCMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        10                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

DZCMnPol db        bit6,0
         db        bit6,8,0,'CHYBA !'
         db        bit6,25,'Chyba ‡ten¡ dat z disku !'
         db        bit6,14,'(sektor ',0,1
         dw        DZCMLPl2
         db        0,')'
         db        bit6+bit7,0
         db        1,8,'Opakovat'
         db        1,9,'Ignorovat'
         db        1,8,'P©eru¨it'

DZCMLPl2 db        13,'1.234.234.234'

HelpS    SEGMENT   BYTE PUBLIC
DZCMnHlp db        27,'Opakov n¡ operace ‡ten¡ dat'
         db        26,'Ignorov n¡ chyby ‡ten¡ dat'
         db        3,1
         dw        DZRMnHl2
HelpS    ENDS

DZCMnBlk db        0,0,0                    ; blokovac¡ tabulka
DZCMnTit db        11,'chyba ‡ten¡'

; ------ potvrzen¡ k ulo‘en¡ dat disku

DZRMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        DZRMnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        DZRMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZRMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZRMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        45                       ; ¨¡©ka
         db        10                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

DZRMnPol db        bit6,0
         db        bit6,29,'Data disku byla modifikov na.'
         db        bit6,39,'Chcete proveden‚ zmˆny ulo‘it na disk ?'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Ulo‘it'
         db        1,7,'Obnovit'
         db        1,8,'P©eru¨it'

HelpS    SEGMENT   BYTE PUBLIC

DZRMnHlp db        32,'Ulo‘en¡ proveden˜ch zmˆn na disk'
         db        49,'Obnoven¡ p–vodn¡ch dat - proveden‚ zmˆny se zru¨¡'
         db        3,1
         dw        DZRMnHl2
HelpS    ENDS

DZRMnHl2 db        35,'P©eru¨en¡ operace, n vrat k editaci'

DZRMnBlk db        0,0,0                    ; blokovac¡ tabulka

DZRMnTit db        12,'ulo‘en¡ zmˆn'

; ------ varov n¡, ‘e je to syst‚mov  oblast

DZSMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        2                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        DZSMnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        DZSMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZSMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZSMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        11                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

DZSMnPol db        bit6,0
         db        bit6,11,0,'VAROVN‹ !'
         db        bit6,43,'Prov d¡te z pis do syst‚mov‚ oblasti disku.'
         db        bit6,35,'Hroz¡ nebezpe‡¡ zni‡en¡ dat disku !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'Ulo‘it'
         db        1,8,'P©eru¨it'

HelpS    SEGMENT   BYTE PUBLIC
DZSMnHlp db        32,'Ulo‘en¡ proveden˜ch zmˆn na disk'
         db        3,1
         dw        DZRMnHl2
HelpS    ENDS

DZSMnBlk db        0,0                      ; blokovac¡ tabulka
DZSMnTit db        26,'z pis do syst‚mov‚ oblasti'

; ------ chyba z pisu na disk

DZWMnLin label     byte
         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        8                        ; celkov˜ po‡et polo‘ek menu

         dw        DZWMnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        DZWMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZWMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZWMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        49                       ; ¨¡©ka
         db        10                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

DZWMnPol db        bit6,0
         db        bit6,8,0,'CHYBA !'
         db        bit6,26,'Chyba z pisu dat na disk !'
         db        bit6,14,'(sektor ',0,1
         dw        DZCMLPl2
         db        0,')'
         db        bit6+bit7,0
         db        1,8,'Opakovat'
         db        1,9,'Ignorovat'
         db        1,8,'P©eru¨it'

HelpS    SEGMENT   BYTE PUBLIC
DZWMnHlp db        28,'Opakov n¡ operace z pisu dat'
         db        27,'Ignorov n¡ chyby z pisu dat'
         db        3,1
         dw        DZRMnHl2
HelpS    ENDS

DZWMnBlk db        0,0,0                    ; blokovac¡ tabulka
DZWMnTit db        12,'chyba z pisu'

; ------ skok p©i editaci disku

DZSMSLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka menu
         dw        3                        ; po‡et platn˜ch polo‘ek menu
         dw        5                        ; celkov˜ po‡et polo‘ek menu

         dw        DZSMLPol                 ; za‡ tek definice polo‘ek menu
         dw        DZSMLHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZSMLBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZSMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        20                       ; po‡ te‡n¡ pozice okna
         db        0                        ; po‡ te‡n¡ © dek okna
         db        40                       ; ¨¡©ka okna
         db        8                        ; v˜¨ka okna

         dw        FileMax                  ; maxim ln¡ d‚lka textu © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        1                        ; celkov˜ po‡et © dk–
         dw        1                        ; po‡et zobrazen˜ch © dk–

         db        bit3                     ; maska zad van˜ch znak– - souboru
         db        3,'?*+   '               ; zak zan‚ znaky

         db        HistCis                  ; historie ‡¡sel
         db        0                        ; po‡et p©edvoleb

; ------ polo‘ky voleb

DZSMLPol db        bit6,26,'Po‘adovan‚ m¡sto na disku:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Proveƒ'
         db        1,6,'N vrat'

DZSMLBlk db        0,0,0                    ; blokovac¡ tabulka

DZSMLTit db        4,'skok'

; ------ n povˆda

HelpS    SEGMENT   BYTE PUBLIC
DZSMLHlp db        90,'Zvolte (n=‡¡slo, $n=HEX): n=blok, Sn=sektor, On=offset, B=BOOT, Fn=FAT, R=ROOT'
         db        29,'Skok na zadan‚ m¡sto na disku'
         db        3,1
         dw        DZRMnHl2
HelpS    ENDS

DZHMLTxt db        25,'Vyhled v m data "',0,1
         dd        TextFnd0
         db        0,'"'

; ------ zobrazen¡ vlastn¡ka bloku

DZVMnLin label     byte

         db        3                        ; typ menu - © dkov‚ menu

         db        0                        ; hladina k zobrazen¡ menu
         dw        1                        ; aktivn¡ polo‘ka volby
         dw        1                        ; po‡et platn˜ch polo‘ek menu
         dw        7                        ; celkov˜ po‡et polo‘ek menu

         dw        DZVMnPol                 ; adresa defini‡n¡ tabulky polo‘ek
         dw        DZVMnHlp                 ; adresa tabulky text– n povˆdy
         dw        Hlp@EditaceDisku         ; ‡¡slo str nky velk‚ n povˆdy
         dw        DZVMnBlk                 ; adresa blokovac¡ tabulky
         dw        0                        ; adresa tabulky p©ep¡na‡–
         dw        DZVMnTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n vratov  adresa p©i p©eru¨en¡

         db        6                        ; po‡ te‡n¡ pozice
         db        7                        ; po‡ te‡n¡ © dek
         db        45                       ; ¨¡©ka
         db        11                       ; v˜¨ka

         dw        255                      ; maxim ln¡ d‚lka © dku
         dw        0                        ; prvn¡ zobrazen˜ © dek
         dw        0                        ; aktivn¡ zobrazen˜ © dek
         dw        0                        ; celkov˜ po‡et © dk–
         dw        0                        ; po‡et zobrazen˜ch © dk–

         db        bit2                     ; maska zad van˜ch znak–
         db        0,'      '               ; dopl¤uj¡c¡ zak zan‚ znaky

         db        0                        ; identifik tor historie
         db        0                        ; po‡et p©edvoleb

DZVMnPol db        bit6,0
         db        bit6,21,'Vlastn¡k bloku ',0,1
         dw        DZVMnPl2
         db        0,':'
         db        bit6,0

         db        bit6,4,0,1
DZVMnPl1 dw        DskLDir0                 ; adres © se souborem

         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N vrat'

DZVMnPl2 db        6,'12.345'

DZVMnPl3 db        10,'VOLN BLOK'
DZVMnPl4 db        10,'VADN BLOK'
DZVMnPl5 db        25,'NENALEZEN - ztracen˜ blok'

HelpS    SEGMENT   BYTE PUBLIC
DZVMnHlp db        16,'N vrat z funkce.'
HelpS    ENDS

DZVMnBlk db        0                        ; blokovac¡ tabulka
DZVMnTit db        14,'vlastn¡k bloku'

DZVMnTx1 db        33,'Vyhled v m vlastn¡ka bloku ',0,1
         dd        DZVMnPl2

;; ------ barvy pro zobrazen¡ disku
;
;ColDZob0 db        17h                      ; barva oddˆlovac¡ ‡ ry
;ColDZob1 db        1bh                      ; barva textu editace disku
;ColDZob2 db        1eh                      ; barva textu rozd¡ln˜ch dat
;ColDZob3 db        4fh                      ; barva kurzoru
;ColDZob4 db        4eh                      ; barva kurzoru na rozd¡ln˜ch datech

; ------ definice bufferu dat disku

DZobBSeg dw        0                        ; segment bufferu pro zobraz. disku
DZobBRef dw        0                        ; offset referen‡n¡ch dat v bufferu
DZobBSek dw        0                        ; po‡et sektor– na polovinu bufferu

DZobBBeg dd        0                        ; po‡ te‡n¡ sektor v bufferu
DZobBNum dw        0                        ; po‡et bajt– v polovinˆ bufferu

DZobBTop dw        0                        ; offset zobrazen‚ho po‡ tku
DZobBKur dw        0                        ; offset kurzoru v bufferu

DZobBVys dw        19                       ; zobrazen  v˜¨ka editoru disku
DZobBV16 dw        19*16                    ; zobrazen  kapacita na str nku

DZAktMod db        0                        ; aktivn¡ m¢d editoru disku
                                            ;   bit 0: 1=je m¢d editace
                                            ;   bit 1: 1=byla modifikace dat
                                            ;   bit 2: 0=HEX pole/1=ASCII pole
                                            ;   bit 3: 0=1.znak HEX/1=2.znak HEX
                                            ;   bit 4: 1=byl dotaz pro z pis
                                            ;   bit 5: 1=prob¡h  hled n¡ ©etˆzce

;TextFndN dw        0                        ; po‡et znak– hledan‚ho textu
;TextFnd0 db        0                        ; d‚lka textu pro zobrazen¡ hl ¨en¡
;TextFnd  db        TextFndX dup(0)          ; buffer hledan‚ho textu

Data     ENDS

         END

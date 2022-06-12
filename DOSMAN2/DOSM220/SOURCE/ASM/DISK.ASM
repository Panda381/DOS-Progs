
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                D I S K
;                      obsluha diskovòch za©°zen°
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeDisk SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDisk,ds:Data

; *****************************************************************************
;                               SetVol
;                      nastaven° n†và®t° disku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku (0=A, ...)
;        ES:SI=novÇ jmÇno disku (n†và®t°)
;        CL=dÇlka jmÇna disku (max. 11 znakñ, 0=n†và®t° se jen ru®°)
;        DS=datovò segment
; VùSTUP: CY=chyba operace
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) uschovanò pñvodn° aktivn° disk
;                   SS:[BP-FileMax] (FileMax-1) uschovanò aktivn° adres†©
;                   SS:[BP-FileMax-50] (50) buffer DTA s naátenou poloëkou
; *****************************************************************************

SetVol   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,2*50 + FileMax        ; buffer pracovn° poloëky FCB a DTA
         mov       ch,0                     ; CX = dÇlka jmÇna disku

; ------ £schova disku a aktivn°ho adres†©e modifikovanÇho disku

         push      es                       ; segment jmÇna disku
         push      cx                       ; dÇlka jmÇna disku
         push      si                       ; offset jmÇna disku

         push      ax                       ; AL = poëadovanò disk
         call      far ptr GetDisk          ; poskytnut° aktivn°ho disku
         mov       ss:[bp-1],al             ; £schova pñvodn°ho aktivn°ho disku
         pop       ax                       ; AL = poëadovanò disk

         push      ss
         pop       es                       ; ES <- segment v bufferu
         lea       di,[bp-FileMax]          ; buffer k £schovà adres†©e
         call      far ptr GetDir           ; poskytnut° adres†©e disku AL
         jc        SetVol0                  ; asi chybnò disk

; ------ nastaven° adres†©e ROOT disku

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset RootDir        ; text "A:\"
         add       al,"A"                   ; korekce na oznaáen° disku
         mov       ds:[si],al               ; oznaáen° disku
         call      far ptr SetDDir          ; nastaven° ROOT adres†©e disku

SetVol0: pop       si                       ; offset jmÇna disku
         pop       cx                       ; dÇlka jmÇna disku
         pop       es                       ; segment jmÇna disku
         jc        SetVol2                  ; chyba

; ------ p©°prava poloëky FCB pro nalezen° n†và®t° disku (CH=0)

         mov       di,sp                    ; DI <- buffer poloëky FCB
         push      es                       ; segment jmÇna disku
         push      si                       ; offset jmÇna disku
         push      cx                       ; dÇlka jmÇna disku

         push      ss
         pop       es                       ; ES <- z†sobn°k
         cld
         mov       al,0ffh                  ; p©°znak roz®°©enÇho FCB
         stosb
         xor       ax,ax                    ; AX <- 0
         stosw
         stosw
         stosb                              ; rezervovanÇ pole (5 bajtñ)
         mov       al,VOL
         stosb                              ; atributy poloëky
         mov       al,ds:[RootDir]          ; zadanò disk
         sub       al,"@"                   ; korekce na á°slo disku + 1
         stosb                              ; á°slo disku
         mov       cl,11
         mov       al,"?"
         rep       stosb                    ; jmÇno a p©°pona
         xor       ax,ax                    ; AX <- 0
         stosw                              ; aktu†ln° blok
         mov       al,80h
         stosw                              ; dÇlka z†znamu
         xor       ax,ax                    ; AX <- 0
         mov       cl,22/2
         rep       stosw                    ; vymaz†n° zbytku poloëky

; ------ nastaven° pracovn° adresy DTA

         lea       si,[bp-FileMax-50]       ; buffer DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA

         pop       cx                       ; dÇlka jmÇna disku
         pop       si                       ; offset jmÇna disku
         pop       es                       ; segment jmÇna disku

; ------ nalezen° starÇho n†và®t°

         mov       ah,11h                   ; funkce - nalezen° poloëky FCB
SetVol1: mov       dx,sp                    ; buffer FCB poloëky
         push      ds
         push      ss
         pop       ds                       ; DS <- segment bufferu FCB
         int       21h                      ; nalezen° starÇho n†và®t°
         pop       ds
         cmp       al,0ffh                  ; n†và®t° nalezeno OK ?
         je        SetVol3                  ; starÇ n†và®t° nenalezeno
         call      far ptr TestBreak        ; chyba za©°zen°
SetVol2: jc        SetVol26                 ; chyba

; ------ ovà©en°, zda bylo skuteánà nalezeno n†và®t°

         mov       al,ss:[bp-FileMax-50+6]  ; atributy
         and       al,VOL+SYS+HID
         cmp       al,VOL                   ; nalezeno n†và®t° ?
         je        SetVol24                 ; nalezeno n†và®t° OK
         mov       ah,12h                   ; funkce - nalezen° dal®° poloëky
         jmp       short SetVol1            ; novò pokus

; ------ zru®en° starÇho n†và®t°

SetVol24:lea       dx,[bp-FileMax-50]       ; buffer FCB nalezenÇ poloëky
         mov       ah,13h                   ; funkce zru®en° souboru
         push      ds
         push      ss
         pop       ds                       ; DS <- segment bufferu FCB
         int       21h                      ; zru®en° starÇho n†và®t°
         pop       ds
         call      far ptr TestBreak        ; chyba za©°zen°
SetVol26:jc        SetVol8                  ; chyba

; ------ sestaven° poloëky FCB novÇho n†và®t°

SetVol3: clc
         jcxz      SetVol8                  ; nen° novÇ n†và®t°

         mov       di,sp                    ; pracovn° buffer FCB
         push      ds

         push      es
         pop       ds                       ; DS <- segment jmÇna poloëky
         push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         cld
         mov       al,0ffh                  ; identifik†tor roz®°©enÇ FCB
         stosb
         xor       ax,ax                    ; AX <- 0
         stosw
         stosw
         stosb                              ; rezervovanÇ pole (5 bajtñ)
         mov       al,VOL
         stosb                              ; atributy poloëky
         mov       al,ds:[RootDir]          ; zadanò disk
         sub       al,"@"                   ; korekce na á°slo disku + 1
         stosb                              ; á°slo disku

         mov       bx,11                    ; maxim†ln° dÇlka n†và®t°
         sub       bx,cx                    ; zbylÇ mezery
         jnc       SetVol4
         xor       bx,bx                    ; omezen° p©i p©eteáen°
         mov       cl,11                    ; omezen° dÇlky jmÇna
SetVol4: rep       movsb                    ; p©enos novÇho jmÇna disku
         mov       al," "
         mov       cl,bl                    ; zbylÇ mezery
         rep       stosb                    ; vymaz†n° zbytku jmÇna

         xor       ax,ax                    ; AX <- 0
         stosw                              ; aktu†ln° blok
         mov       al,80h
         stosw                              ; dÇlka z†znamu
         xor       ax,ax                    ; AX <- 0
         mov       cl,22/2
         rep       stosw                    ; vymaz†n° zbytku poloëky

         pop       ds

; ------ vytvo©en° novÇho n†và®t°

         mov       dx,sp                    ; buffer FCB poloëky
         mov       ah,16h                   ; funkce vytvo©en° souboru
         push      ds
         push      ss
         pop       ds                       ; DS <- segment bufferu FCB
         int       21h                      ; vytvo©en° novÇho n†và®t°
         pop       ds
         cmp       al,0ffh                  ; bylo n†và®t° vytvo©eno OK ?
         stc
         je        SetVol8                  ; chyba vytvo©en° novÇho n†và®t°
         call      far ptr TestBreak        ; chyba za©°zen°
         jc        SetVol8

; ------ uzav©en° novÇho n†và®t°

         mov       dx,sp                    ; buffer FCB poloëky
         mov       ah,10h                   ; funkce uzav©en° souboru
         push      ds
         push      ss
         pop       ds                       ; DS <- segment bufferu FCB
         int       21h                      ; uzav©en° n†và®t°
         pop       ds
         cmp       al,0ffh                  ; bylo n†và®t° uzav©eno OK ?
         stc
         je        SetVol8                  ; n†và®t° bylo uzav©eno OK
         call      far ptr TestBreak        ; test p©eru®en° operace

; ------ n†vrat aktivn°ho adres†©e

SetVol8: pushf
         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       si,[bp-FileMax]          ; buffer k £schovà adres†©e
         call      far ptr SetDir           ; n†vrat pñvodn°ho adres†©e
         mov       al,ss:[bp-1]             ; pñvodn° disk
         call      far ptr SetDisk          ; n†vrat pñvodn°ho disku
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce
         popf

; ------ n†vrat registrñ

SetVol9: mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetVol   ENDP

; *****************************************************************************
;                                 GetVol
;                       poskytnut° n†và®t° disku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku (0=A, ...)
;        DS=datovò segment
;        ES:DI=adresa k uloëen° textu n†và®t° (11 znakñ)
; VùSTUP:CX=poáet platnòch znakñ textu n†và®t° (p©i chybà CX=0)
;        CY=chyba operace (CX=0)
;        ZY=nen° n†và®t° (NC, CX=0)
; *****************************************************************************

GetVol   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      si
         push      di
         push      bp
         mov       bp,sp
         sub       sp,DTAMax                ; buffer pro DTA

; ------ nastaven° adresy DTA

         mov       si,sp                    ; adresa bufferu DTA v z†sobn°ku
         push      es                       ; £schova ES
         push      ss
         pop       es                       ; ES <- segment bufferu DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA

; ------ nalezen° n†và®t°

         mov       si,offset AllDisk        ; specifikace k nalezen° n†và®t°
         add       al,"A"                   ; p©evod á°sla disku na znak ASCII
         mov       ds:[si],al               ; oznaáen° disku
         push      ds
         pop       es                       ; ES <- DS segment textu n†và®t°
         mov       cx,VOL                   ; atribut - n†và®t°
         call      far ptr SrcFirst         ; nalezen° souboru
         pop       es                       ; n†vrat ES

; ------ rozli®en° vòsledku operace

GetVol1: mov       cx,0                     ; dÇlka n†và®t° - nic
         jc        GetVol9                  ; chyba operace
         jnz       GetVol8                  ; n†và®t° nenalezeno

; ------ opakov†n° hled†n°, pokud nebylo nalezeno n†và®t°

         test      byte ptr ss:[bp-DTAMax+DTAAtrib],SYS+HID ; je dlouhÇ jmÇno ?
         jnz       GetVol2                  ; dlouhÇ jmÇno nebo skrytÇ
         test      byte ptr ss:[bp-DTAMax+DTAAtrib],VOL ; nalezeno n†và®t° ?
         jnz       GetVol3                  ; nalezeno n†và®t° OK
GetVol2: call      far ptr SrcNext          ; pokraáov†n° v hled†n°
         jmp       short GetVol1

; ------ p©enesen° textu n†và®t° do bufferu

GetVol3: mov       ax,ss:[bp-DTAMax+DTADate]    ; datum n†và®t°
         mov       ds:[VolDate],ax          ; datum n†và®t°
         mov       ax,ss:[bp-DTAMax+DTATime]    ; áas n†và®t°
         mov       ds:[VolTime],ax          ; áas n†và®t°
         lea       si,[bp-DTAMax+DTAName]       ; jmÇno n†và®t°
         cld                                ; smàr nahoru
GetVol4: lods      byte ptr ss:[si]         ; znak nalezenÇho n†và®t°
         cmp       al,0                     ; je konec textu ?
         je        GetVol8                  ; konec textu n†và®t°
         cmp       al,"."                   ; je oddàlovaá p©°pony ?
         jne       GetVol5                  ; ne - je platnò znak
         cmp       cl,8                     ; bylo jië jmÇno ?
         jae       GetVol4                  ; za jmÇnem se teáka ignoruje
         mov       al," "                   ; dopl§uj°c° mezera
         dec       si                       ; n†vrat znaku teáky
GetVol5: stosb                              ; uloëen° platnÇho znaku
         inc       cx                       ; zvò®en° á°taáe platnòch znakñ
         cmp       cl,11                    ; jsou jië v®echny znaky ?
         jb        GetVol4                  ; jsou moënÇ je®tà dal®° znaky

; ------ n†vrat registrñ

GetVol8: or        cx,cx                    ; je n†và®t° ?
GetVol9: call      far ptr SrcClose         ; uzav©en° starÇho hled†n°
         mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       ax
         ret

GetVol   ENDP

; *****************************************************************************
;                               GetSerN
;                     poskytnut° sÇriovÇho á°sla disku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku (A=0,...)
;        DS=datovò segment
; VùSTUP: CY=nen° sÇriovÇ á°slo
;         DX:CX=sÇriovÇ á°slo disku
; -----------------------------------------------------------------------------
; sÇriovÇ á°slo:  LOW = sekundy/setiny + màs°c/den
;                 HIGH = hodiny/minuty + rok
; *****************************************************************************

GetSerN  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,30

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        GetSerN9                 ; je p©eru®en° operace

; ------ kontrola verze systÇmu

         cmp       byte ptr ds:[VerzeOS+1],4 ; minim†ln° verze 4.x
         jb        GetSerN9                 ; je n°zk† verze systÇmu

; ------ naáten° sÇriovÇho á°sla disku

         inc       ax                       ; korekce á°sla disku
         mov       ah,0                     ; AH <- 0 informaán° £rove§ 0
         xchg      ax,bx                    ; BL <- á°slo disku, BH <- 0
         mov       ax,6900h
         mov       dx,sp                    ; DX <- adresa bufferu
         mov       di,dx                    ; DI takÇ adresa (pro jistotu)

         push      ds

         push      ss
         pop       ds                       ; DS <- segment bufferu

         push      dx                       ; adresa bufferu
         mov       word ptr ds:[di],0       ; p©ednastaven° - informaán° £rove§
         mov       word ptr ds:[di+2],0     ; inicializace á°sla
         mov       word ptr ds:[di+4],0
         mov       si,ds
         stc                                ; p©ednastaven° - chyba
         int       21h                      ; naáten° n†và®t° disku
         pop       si                       ; adresa bufferu

         mov       cx,ds:[si+2]             ; sÇriovÇ á°slo LOW
         mov       dx,ds:[si+4]             ; sÇriovÇ á°slo HIGH

         pop       ds

; ------ n†vrat registrñ

GetSerN9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       bx
         pop       ax
         ret

GetSerN  ENDP

; *****************************************************************************
;                                  GetDInfo
;                        poskytnut° informac° o disku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku (0=disk A,...)
;        DS=datovò segment
; VùSTUP:CY=chyba disku nebo neplatnÇ diskovÇ informace
;        AX=poáet sektorñ na alokaán° blok (p©i chybà = 1)
;        BX=poáet volnòch alokaán°ch blokñ disku (p©i chybà = 0)
;        CX=poáet bajtñ na sektor (p©i chybà = 512)
;        DX=celkovò poáet alokaán°ch blokñ na disku (p©i chybà = 0)
; *****************************************************************************

GetDInfo PROC      FAR

; ------ £schova á°sla disku -> SI

         push      si
         mov       ah,0
         mov       si,ax                    ; SI <- á°slo disku

         mov       word ptr ds:[GetCDMxS+2],0 ; p©°znak neplatnÇ velikosti CD

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        GetDInfA                 ; je p©eru®en° operace

; ------ poskytnut° parametrñ disku
; Podle INTERRUPT je moënÇ, ëe p©i p©esmàrov†n° pomoc° ASSIGN bude £daj
; celkovÇ kapacity disku nespr†vnò (z©ejmà zñst†v† £daj pro aktu†ln° disk)

         mov       bx,-1                    ; BX <- voln† kapacita neplatn†
         xor       cx,cx                    ; CX <- 0 poáet bajtñ na sektor
         inc       ax                       ; korekce á°sla disku
         xchg      ax,dx                    ; DL <- á°slo disku
         mov       ah,36h                   ; funkce poskytnut° parametrñ disku
         int       21h                      ; poskytnut° parametrñ disku
         call      far ptr TestBreak
         jc        GetDInfA                 ; byla chyba

; ------ chyba - zad†n neplatnò disk

         inc       ax                       ; je neplatnò disk ?
         jnz       GetDInf1                 ; nen° chybnÇ zad†n° disku
         mov       ax,Err_Inv_Disk          ; chyba - neplatnò disk
         jmp       short GetDInf8           ; chyba operace

; ------ kontrola poátu sektorñ na alokaán° blok

GetDInf1:dec       ax                       ; n†vrat £daje poátu sektorñ
         jz        GetDInf9                 ; chyba (=0)

; ------ kontrola poátu volnòch alokaán°ch blokñ

         cmp       bx,dx                    ; maxim†lnà velikost disku
         ja        GetDInf9                 ; chyba

; ------ kontrola poátu bajtñ na sektor

         inc       cx                       ; poáet bajtñ na sektor
         jz        GetDInf9                 ; chyba (=0ffffh)
         dec       cx
         jz        GetDInf9                 ; chyba (=0)

; ------ kontrola celkovÇ kapacity disku

         inc       dx                       ; je platn† velikost disku ?
         jz        GetDInf9                 ; neplatn† velikost disku (=0ffffh)
         dec       dx
         jz        GetDInf9                 ; neplatn† velikost disku (=0)
         clc                                ; p©°znak operace OK
         pop       si
         ret

; ------ chyba operace

GetDInf8:mov       ds:[LastErr],ax          ; £schova k¢du chyby

; ------ test, zda je CD-ROM

GetDInf9:mov       al,ds:[si+DiskITab]      ; parametry disku
         and       al,7                     ; typ disku
         cmp       al,6                     ; je to CD-ROM ?
         je        GetDInfD                 ; je to CD-ROM disk

; ------ implicitn° parametry p©i chybà

GetDInfA:mov       ax,1                     ; poáet sektorñ na alok. blok = 1
         xor       bx,bx                    ; voln† kapacita = 0
         mov       cx,512                   ; poáet bajtñ na sektor = 512
         xor       dx,dx                    ; celkovò poáet alok. blokñ = 0
         stc                                ; p©°znak chyby operace
         pop       si
         ret

; ------ detekce parametrñ pro CD-ROM disk

GetDInfD:xchg      ax,si                    ; AX <- á°slo disku
         call      far ptr GetCDMax         ; naáten° velikosti disku

         mov       bx,1                     ; bude 1 sektor na blok
GetDInfE:or        dx,dx                    ; je jië dostateánà m†lo blokñ ?
         jnz       GetDInfF                 ; je je®tà mnoho blokñ
         cmp       ax,0fff6h                ; maxim†ln° poáet blokñ
         jb        GetDInfH                 ; poáet blokñ je jië OK
GetDInfF:cmp       bx,32                    ; je jië maxim†ln° poáet blokñ ?
         jae       GetDInfG                 ; je jië maxim†ln° poáet blokñ
         shl       bx,1                     ; zvò®en° velikosti bloku
         shr       dx,1                     ; sn°ëen° poátu blokñ
         rcr       ax,1
         jmp       short GetDInfE

GetDInfG:mov       ax,0fff5h                ; omezen° poátu blokñ
GetDInfH:xchg      ax,dx                    ; DX <- velikost disku
         xor       ax,ax                    ; AX <- 0
         xchg      ax,bx                    ; AX <- poáet sektorñ na blok
         mov       cx,2048                  ; velikost sektoru pro CD-ROM
         cmp       dx,1                     ; test platnosti £daje (CY=chyba)
         pop       si
         ret

GetDInfo ENDP

;; *****************************************************************************
;;                                  GetRBook
;;                         naáten° á°sla r†meáku CD-ROM
;; -----------------------------------------------------------------------------
;; VSTUP: DS:SI=á°slo r†mce CD-ROM v Red Book form†tu
;; VùSTUP: DX:AX=á°slo r†mce
;; *****************************************************************************
;
;GetRBook PROC      FAR
;
;         mov       al,60                    ; poáet sekund na minutu
;         mul       byte ptr ds:[si+2]       ; p©epoáet minut na sekundy
;         add       al,ds:[si+1]             ; p©iáten° sekund
;         adc       ah,0
;         mov       dx,75                    ; poáet r†meákñ na sekundu
;         mul       dx                       ; p©epoáet sekund na r†meáky
;         add       al,ds:[si]               ; p©iáten° poátu r†meákñ
;         adc       ah,0
;         adc       dx,0
;         ret
;
;GetRBook ENDP

; *****************************************************************************
;                                 GetCDMax
;                       zji®tàn° poátu sektorñ CD disku
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo disku (0=A:,...)
;        DS=datovò segment
; VùSTUP: DX:AX=poáet sektorñ CD disku
; *****************************************************************************

GetCDMax PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      es

; ------ p©°prava á°sla disku -> CX

         mov       ah,0
         xchg      ax,cx                    ; CX <- á°slo disku

; ------ vytvo©en° bufferu pro sektor 2KB

         mov       bx,2048                  ; velikost bufferu
         call      far ptr CreatDat         ; vytvo©en° bufferu
         jc        GetCDMx6                 ; chyba pamàti
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ naáten° sektoru popisovaáe

         push      ax                       ; segment datovÇho bufferu
         xor       bx,bx                    ; offset poá†tku bufferu
         xor       dx,dx                    ; index prvn°ho popisovaáe
         mov       es:[bx+50h],dx           ; p©ednastaven° - neplatnò sektor
         mov       es:[bx+50h+2],dx
         mov       al,5                     ; funkce áten° VTOC
         push      cx                       ; á°slo disku
         call      IntCD                    ; obsluha funkce CD
         pop       cx                       ; á°slo disku
         mov       bx,es:[50h]              ; poáet sektorñ LOW
         mov       dx,es:[50h+2]            ; poáet sektorñ HIGH
         pop       ax                       ; segment datovÇho bufferu
         pushf
         call      far ptr DelSeg           ; zru®en° datovÇho bufferu
         popf
         xchg      ax,bx                    ; AX <- sektor LOW
         jc        GetCDMx6                 ; byla chyba

; ------ test, zda byl naáten platnò £daj

         or        dx,dx                    ; je to platnò £daj ?
         jnz       GetCDMx9                 ; je to platnò £daj OK
         cmp       ax,50                    ; minim†lnà asi tak 100 KB
         jae       GetCDMx9                 ; je to asi OK

; ------ naáten° velikosti disku z celkovÇ velikosti (CX=á°slo disku)

GetCDMx6:mov       byte ptr ds:[ZahlCD],8   ; funkce informace o disku
         mov       word ptr ds:[ZahlCD+1],0 ; neplatn† velikost disku
         mov       word ptr ds:[ZahlCD+3],0
         xchg      ax,cx                    ; AX <- á°slo disku
         mov       cx,4                     ; poáet bajtñ k naáten°
         call      far ptr InpIOCD          ; naáten° velikosti disku
         mov       ax,word ptr ds:[ZahlCD+1] ; poáet sektorñ LOW
         mov       dx,word ptr ds:[ZahlCD+3] ; poáet sektorñ HIGH
         sub       ax,150                   ; bez z†hlav° CD
         sbb       dx,0

; ------ n†vrat registrñ

GetCDMx9:pop       es
         pop       cx
         pop       bx

         push      ax
         push      dx

         mov       dh,dl
         mov       dl,ah
         mov       ah,al
         mov       al,0                     ; * 256
         shl       ax,1
         rcl       dx,1                     ; * 512
         shl       ax,1
         rcl       dx,1                     ; * 1024
         shl       ax,1
         rcl       dx,1                     ; * 2048
         mov       word ptr ds:[GetCDMxS],ax ; mezi£schova kapacity CD
         mov       word ptr ds:[GetCDMxS+2],dx

         pop       dx
         pop       ax
         ret

GetCDMax ENDP

; *****************************************************************************
;                                 InpIOCD
;                          vstup IOCTL z CD-ROM
; -----------------------------------------------------------------------------
; VSTUP: AL=disk
;        CX=dÇlka poëadavku pro áten° ze za©°zen°
;        DS=datovò segment
; VùSTUP: CY=chyba
; *****************************************************************************

InpIOCD  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ sestaven° poëadavku o p©°stup

         push      cx                       ; poáet átenòch bajtñ ze za©°zen°

         push      ax                       ; disk
         call      far ptr NulIOCD          ; nulov†n° poëadavku
         mov       bx,di                    ; buffer poëadavku
         mov       al,26                    ; dÇlka poëadavku
         stosb                              ; dÇlka poëadavku
         pop       ax                       ; AL = poëadovanò disk
         push      ax
         stosb                              ; poëadovanò disk
         mov       al,3                     ; povel pro áten° z IOCTL
         stosb
         mov       di,offset PozadCD+0eh    ; pokraáov†n° - p©enosov† adresa
         mov       ax,offset ZahlCD         ; adresa poëadavku
         stosw                              ; offset adresy
         mov       ax,ds
         stosw                              ; segment adresy
         pop       cx                       ; CL = disk
         pop       ax                       ; poáet átenòch bajtñ
         stosw                              ; poáet bajtñ k naáten°

; ------ vysl†n° poëadavku (CL=disk, ES:BX=adresa bufferu poëadavku)

         mov       al,10h                   ; podfunkce ovl†d†n° za©°zen°
         mov       ch,0
         call      far ptr IntCD            ; vysl†n° poëadavku

; ------ kontrola navr†cenÇho stavu

         test      byte ptr ds:[PozadCD+3+1],80h ; byla chyba ?
         jz        InpIOCD6                 ; nebyla chyba
InpIOCD4:stc                                ; p©°znak chyby

; ------ n†vrat registrñ

InpIOCD6:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InpIOCD  ENDP

; *****************************************************************************
;                               NulIOCD
;         nulov†n° bufferu poëadavku pro áten° IOCTL z CD-ROM
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: ES:DI=buffer poëadavku p©°stupu k CD
;         AX=0
;         CX=0
;         CLD
; *****************************************************************************

NulIOCD  PROC      FAR

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset PozadCD        ; buffer poëadavku p©°stupu k CD
         mov       cx,30/2                  ; dÇlka bufferu
         xor       ax,ax                    ; AX <- 0
         cld
         push      di
         rep       stosw                    ; vynulov†n° bufferu
         pop       di
         ret

NulIOCD  ENDP

; *****************************************************************************
;                               IntCD
;                       obsluha p©eru®en° CD-ROM
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo sluëby
; *****************************************************************************

IntCD    PROC      FAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ah,15h
         int       2fh

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

IntCD    ENDP

; *****************************************************************************
;                              IniLDskZ
;              inicializace parametrñ zadanÇho logickÇho disku
; -----------------------------------------------------------------------------
; VSTUP: AL=poëadovanò disk
;        DS=datovò segment
; VùSTUP: CY=chyba nebo p©eru®en°
; *****************************************************************************

IniLDskZ PROC      FAR

         push      ax
         jmp       short InitLDsZ

IniLDskZ ENDP

; *****************************************************************************
;                             InitLDsk
;             inicializace parametrñ aktivn°ho logickÇho disku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba nebo p©eru®en°
; *****************************************************************************
;˛
InitLDsk PROC      FAR

; ------ £schova registrñ

         push      ax

         mov       al,ds:[AktPath]          ; aktivn° disk
         sub       al,"A"                   ; á°slo aktivn°ho disku

InitLDsZ:mov       ds:[DskLDisk],al         ; £schova á°sla disku
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ naáten° parametrñ aktivn°ho disku

         and       byte ptr ds:[DskLPar],not bit0+bit1+bit5+bit6 ; je FAT 12, nen° paket, nen° odemknut, nen° CD disk

         call      far ptr GetParB          ; poskytnut° bloku parametrñ disku
         jc        IniLDs02                 ; chyba
         jmp       IniLDsk1                 ; v®e je OK

IniLDs01:jmp       IniLDsk8                 ; nàjak† chyba

; ------ test, zda je CD-ROM

IniLDs02:mov       al,ds:[DskLDisk]         ; á°slo disku
         mov       ah,0
         xchg      ax,bx                    ; BX <- á°slo disku
         mov       al,ds:[bx+DiskITab]      ; parametry disku
         and       al,7                     ; typ disku
         cmp       al,6                     ; je to CD-ROM ?
         jne       IniLDs01                 ; nen° to CD disk

; ------ naáten° velikosti sektoru

         mov       word ptr ds:[ZahlCD],7   ; funkce naáten° velikosti sektoru,
                                            ; m¢d sektorñ "Cooked"
         mov       word ptr ds:[ZahlCD+2],0 ; p©ednastaven° na nesmysl
         mov       cx,3                     ; poáet bajtñ k naáten°
         mov       al,ds:[DskLDisk]         ; á°slo disku
         call      far ptr InpIOCD          ; naáten° velikosti sektoru
         jc        IniLDs01                 ; byla chyba

         mov       ax,word ptr ds:[ZahlCD+2] ; navr†cen† velikost sektoru
         mov       ds:[DskLBSkt],ax         ; poáet bajtñ na sektor
         cmp       ax,32                    ; minim†ln° velikost sektoru
         jb        IniLDs01                 ; neplatn† velikost sektoru
         cmp       ax,4000h                 ; maxim†ln° velikost sektoru
         ja        IniLDs01                 ; neplatn† velikost sektoru
         mov       cl,4
         shr       ax,cl                    ; p©evod na odstavce
         mov       ds:[DskLOSkt],ax         ; poáet odstavcñ na sektor

; ------ stanoven° celkovÇho poátu sektorñ CD disku

         mov       al,ds:[DskLDisk]         ; á°slo disku
         call      far ptr GetCDMax         ; naáten° velikosti disku
         mov       word ptr ds:[DskLNSkt],ax ; celkovò poáet sektorñ LOW
         mov       word ptr ds:[DskLNSkt+2],dx ; celkovò poáet sektorñ HIGH

; ------ implicitn° parametry CD disku

         call      IniLDCD                  ; implicitn° parametry CD
         jc        IniLDs01                 ; chyba

; ------ p©°znak, ëe je CD disk

         or        byte ptr ds:[DskLPar],bit6 ; p©°znak CD disku
         jmp       IniLDsk9                 ; NC=operace OK

IniLDsk0:jmp       IniLDs02

; ------ poáet bajtñ na sektor (-> CX)

IniLDsk1:mov       ax,es:[si+2]             ; poáet bajtñ na sektor
         mov       ds:[DskLBSkt],ax         ; poáet bajtñ na sektor
         mov       cx,ax                    ; CX <- poáet bajtñ na sektor
         cmp       ax,32                    ; minim†ln° velikost sektoru
         jb        IniLDsk0                 ; neplatn† velikost sektoru
         cmp       ax,4000h                 ; maxim†ln° velikost sektoru
         ja        IniLDsk0                 ; neplatn† velikost sektoru
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         mov       ds:[DskLOSkt],ax         ; poáet odstavcñ na sektor

; ------ poáet sektorñ na alokaán° blok (-> BX)

         mov       ah,0
         mov       al,es:[si+4]             ; maxim†ln° sektor v alok. bloku
         inc       ax                       ; poáet sektorñ
         jz        IniLDsk0                 ; neplatnò poáet sektorñ
         mov       bx,ax                    ; BX <- poáet sektorñ na alok. blok
         mov       ds:[DskLSBlk],ax         ; poáet sektorñ na alokaán° blok

; ------ poáet bajtñ na alokaán° blok

         mul       cx                       ; vòpoáet poátu bajtñ na alok. blok
         or        dx,dx                    ; je p©eteáen° ?
         jnz       IniLDsk0                 ; p©eteáen°
         cmp       ax,32                    ; minim†ln° velikost alok. bloku
         jb        IniLDsk0                 ; chybn† velikost bloku
         mov       ds:[DskLBBlk],ax         ; poáet bajtñ na alokaán° blok

; ------ stanoven° ©†du velikosti alokaán°ho bloku (AX nesm° bòt = 0 !)

         xor       dx,dx                    ; á°taá ©†du velikosti alok. bloku
         dec       dx                       ; p©ednastaven° á°taáe
         push      ax
IniLDsk2:inc       dx                       ; zvò®en° á°taáe ©†du bloku
         shr       ax,1                     ; poáet bajtñ / 2
         jnc       IniLDsk2                 ; dal®° rotace
         pop       ax
         jnz       IniLDsk0                 ; neplatn† velikost alokaán°ho bloku
         mov       ds:[DskLRBlk],dl         ; ©†d alokaán°ho bloku

; ------ poáet odstavcñ na alokaán° blok

         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       ds:[DskLOBlk],ax         ; poáet odstavcñ na alokaán° blok

; ------ poáet poloëek ROOT

         mov       ax,es:[si+9]             ; poáet poloëek ROOT
         mov       ds:[DskLNRot],ax         ; poáet poloëek ROOT
         or        ax,ax                    ; je ROOT ?
         jz        IniLDsk0                 ; nen° ROOT - neplatnò disk

; ------ poáet tabulek FAT

         mov       al,es:[si+8]             ; poáet tabulek FAT
         mov       ds:[DskLNFat],al         ; poáet tabulek FAT
         cmp       al,0                     ; je tabulka FAT ?
         je        IniLDsk0                 ; nen° tabulka FAT - neplat°
         cmp       al,10                    ; nàjak† rozumn† hodnota ?
         ja        IniLDsk0                 ; to nen° rozumn† hodnota

; ------ poáet rezervovanòch sektorñ = poá†teán° sektor FAT

         mov       ax,es:[si+6]             ; poáet rezervovanòch sektorñ
         mov       ds:[DskLBFat],ax         ; poá†teán° sektor FAT
         or        ax,ax                    ; je BOOT ?
         jz        IniLDsk0                 ; to je nesmysl

; ------ poáet alokaán°ch blokñ (minim†lnà 1)

         mov       ax,es:[si+13]            ; maxim†ln° á°slo alok. bloku
         cmp       ax,2                     ; minim†ln° hodnota á°sla max. bloku
         jb        IniLDsk8                 ; nesmysl
         mov       ds:[DskLMBlk],ax         ; maxim†ln° á°slo alokaán°ho bloku
         dec       ax                       ; poáet blokñ
         mov       ds:[DskLNBlk],ax         ; celkovò poáet alokaán°ch blokñ

; ------ detekov†n°, zda je tabulka FAT 12 nebo FAT 16

         cmp       ax,0ff6h                 ; je v°ce blokñ neë 0ff6h ?
         jb        IniLDsk3                 ; je m†lo blokñ - je FAT 12
         or        byte ptr ds:[DskLPar],bit0 ; jinak je tabulka FAT 16

; ------ vòpoáet celkovÇho poátu sektorñ disku

IniLDsk3:mul       bx                       ; vòpoáet poátu dat. sektorñ celkem
         add       ax,es:[si+11]            ; p©iáten° prvn°ho datovÇho sektoru
         adc       dx,0                     ; p©enos HIGH
         jc        IniLDsk8                 ; nàjak† chyba
         mov       word ptr ds:[DskLNSkt],ax ; celkovò poáet sektorñ LOW
         mov       word ptr ds:[DskLNSkt+2],dx ; celkovò poáet sektorñ HIGH

; ------ stanoven°, zda je obsluha paketem (souáasnà je automaticky FAT 16)

         jz        IniLDsk4                 ; nen° obsluha paketem (m†lo sekt.)
         or        byte ptr ds:[DskLPar],bit0+bit1 ; je obsluha paketem a FAT 16

; ------ poáet sektorñ na jednu FAT

IniLDsk4:mov       ah,0
         mov       al,es:[si+15]            ; poáet sektorñ na FAT
         cmp       byte ptr ds:[VerzeOS+1],4 ; je verze systÇmu 4.xx a v°ce ?
         jb        IniLDsk5                 ; je nië®° verze systÇmu
         mov       ah,es:[si+16]            ; poáet sektorñ na FAT - HIGH
IniLDsk5:mov       ds:[DskLSFat],ax         ; poáet sektorñ na jednu FAT
         or        ax,ax                    ; je platnò £daj ?
         jz        IniLDsk8                 ; neplatnò £daj

; ------ poáet sektorñ na FAT celkem

         mov       dl,ds:[DskLNFat]         ; poáet tabulek FAT
         mov       dh,0
         mul       dx                       ; poáet sektorñ na FAT celkem
         or        dx,dx
         jnz       IniLDsk8                 ; neplatnò £daj
         mov       ds:[DskLCFat],ax         ; poáet sektorñ na FAT celkem

; ------ poá†teán° sektor ROOT

         add       ax,ds:[DskLBFat]         ; p©iáten° poá†teán°ho sektoru FAT
         jc        IniLDsk8                 ; chyba
         mov       ds:[DskLBRot],ax         ; poá†teán° sektor ROOT

; ------ poá†teán° datovò sektor

         mov       ax,es:[si+11]            ; prvn° datovò sektor
         mov       ds:[DskLBDat],ax         ; poá†teán° datovò sektor

; ------ poáet sektorñ na ROOT

         sub       ax,ds:[DskLBRot]         ; poáet sektorñ na ROOT
         jbe       IniLDsk8                 ; chyba
         mov       ds:[DskLSRot],ax         ; poáet sektorñ ROOT

; ------ poáet poloëek adres†©e na jeden sektor

         xchg      ax,cx                    ; AX <- poáet bajtñ na sektor
         mov       cl,5                     ; poáet rotac° (pro dàlen° / 32)
         shr       ax,cl                    ; poáer adres. poloëek na sektor
         mov       ds:[DskLASkt],ax         ; poáet adres. poloëek na sektor
         clc
         jnz       IniLDsk9                 ; £daj je OK

; ------ n†vrat registrñ

IniLDsk8:stc                                ; p©°znak chyby
IniLDsk9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitLDsk ENDP

; -----------------------------------------------------------------------------
;        p©°prava implicitn°ch parametrñ CD disku
; -----------------------------------------------------------------------------
;˛
IniLDCD  PROC      NEAR

; ------ implicitn° parametry

         mov       byte ptr ds:[DskLNFat],1 ; poáet tabulek FAT = 1
         mov       word ptr ds:[DskLBFat],1 ; poá†teán° sektor FAT = 1
         mov       word ptr ds:[DskLSFat],15 ; poáet sektorñ na jednu FAT = 15
         mov       word ptr ds:[DskLCFat],15 ; poáet sektorñ na FAT celkem = 15

         mov       word ptr ds:[DskLBRot],16 ; poá†teán° sektor ROOT = 2
         mov       word ptr ds:[DskLSRot],2  ; poáet sektorñ ROOT = 2

         mov       word ptr ds:[DskLBDat],18 ; poá†teán° datovò sektor = 3
         mov       word ptr ds:[DskLASkt],64 ; poáet adres. poloëek na sektor
         mov       word ptr ds:[DskLNRot],128 ; poáet poloëek ROOT

         mov       ax,word ptr ds:[DskLNSkt] ; poáet sektorñ LOW
         mov       dx,word ptr ds:[DskLNSkt+2] ; poáet sektorñ HIGH
         sub       ax,18
         sbb       dx,0
         mov       word ptr ds:[DskLSBlk],1 ; poáet sektorñ na alok. blok
         mov       byte ptr ds:[DskLRBlk],1 ; ©†d alokaán°ho bloku
IniLDCD2:or        dx,dx                    ; je mnoho sektorñ ?
         jnz       IniLDCD3                 ; je mnoho sektorñ
         cmp       ax,0fff7h                ; max. blokñ
         jb        IniLDCD4                 ; je to OK
IniLDCD3:shr       dx,1                     ; poáet sektorñ / 2
         rcr       ax,1
         shl       word ptr ds:[DskLSBlk],1 ; zvò®en° sektorñ na blok
         inc       byte ptr ds:[DskLRBlk]   ; zvò®en° ©†du bloku
         cmp       byte ptr ds:[DskLRBlk],15 ; maxim†ln° ©†d velikosti bloku
         jb        IniLDCD2
         stc                                ; chyba
         ret

IniLDCD4:mov       ax,word ptr ds:[DskLNSkt] ; poáet sektorñ LOW
         mov       dx,word ptr ds:[DskLNSkt+2] ; poáet sektorñ HIGH
         div       word ptr ds:[DskLSBlk]   ; vòpoáet poátu blokñ
         mov       ds:[DskLNBlk],ax         ; poáet alokaán°ch blokñ
         inc       ax
         mov       ds:[DskLMBlk],ax         ; maxim†ln° á°slo alok. bloku

         mov       ax,ds:[DskLSBlk]         ; poáet sektorñ na blok
         mul       word ptr ds:[DskLBSkt]   ; vòpoáet velikosti bloku
         mov       ds:[DskLBBlk],ax         ; poáet bajtñ na alokaán° blok
         mov       cl,4
         shr       ax,cl
         mov       ds:[DskLOBlk],ax         ; poáet odstavcñ na alok. blok

         clc
         ret

IniLDCD  ENDP

; *****************************************************************************
;                             GetAClus
;            poskytnut° alokaán°ho bloku aktivn°ho adres†©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: AX=á°slo alokaán°ho bloku zaá†tku adres†©e
;         CY=chyba
; *****************************************************************************

GetAClus PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,FileMax               ; buffer v z†sobn°ku

; ------ nastaven° adresy DTA

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset BuffDTA        ; buffer DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA
         mov       word ptr ds:[si+0fh],0   ; p©ednastaven° pro p©°pad chyby
         mov       word ptr ds:[si+13h],0

; ------ p©enesen° aktivn°ho adres†©e do z†sobn°ku

         mov       cx,ds:[AktPathN]         ; dÇlka aktivn°ho adres†©e
         xor       ax,ax                    ; AX <- alokaán° blok ROOT
         cmp       cl,3                     ; je to ROOT adres†© ?
         jbe       GetACls8                 ; je to ROOT adres†©
         mov       si,offset AktPath        ; aktivn° adres†©
         push      ss
         pop       es                       ; ES <- buffer v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         cld
         rep       movsb                    ; p©enos aktivn°ho adres†©e

; ------ p©id†n° textu "\*.*"

         mov       si,offset AllDir         ; text "\*.*"
         mov       cl,5                     ; pocet bajtñ
         rep       movsb                    ; p©id†n° textu "\*.*"

; ------ nalezen° nàjakÇho souboru z adres†©e (je AX=0)

         mov       cx,DIR+SYS+HID+RO+ARC    ; atributy
         mov       si,sp                    ; specifikace poloëek
         mov       al,ds:[Win95Par]         ; parametr
         push      ax
         or        byte ptr ds:[Win95Par],bit2 ; z†kaz dlouhòch jmen
         call      far ptr SrcFirst         ; nalezen° jakÇkoliv poloëky
         pop       ax
         mov       ds:[Win95Par],al         ; n†vrat p©°znaku
         jc        GetACls9                 ; nàjak† chyba (je AX=0)

; ------ á°slo alokaán°ho bloku adres†©e

         mov       ax,word ptr ds:[BuffDTA+0fh] ; alok. blok pro verze >= 3.20
         cmp       word ptr ds:[VerzeOS],3*HI + 20 ; je verze alespo§ 3.20 ?
         jae       GetACls8                 ; je verze systÇmu vy®®° neë 3.20
         mov       ax,word ptr ds:[BuffDTA+13h] ; alok. blok pro verze < 3.20
GetACls8:clc

; ------ n†vrat registrñ

GetACls9:call      far ptr SrcClose         ; uzav©en° starÇho hled†n°

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

GetAClus ENDP

; *****************************************************************************
;                             OpenLDir
;              otev©en° bufferu adres†©e logickÇho disku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti nebo chyba áten° adres†©e ROOT (hl†s°)
; *****************************************************************************

OpenLDir PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ vytvo©en° segmentu bufferu

         call      far ptr CreatSeg         ; vytvo©en° datovÇho bloku
         jc        OpenLDr8                 ; chyba - nedostatek pamàti
         mov       ds:[DskLDirS],ax         ; á°slo datovÇho bloku

; ------ nastaven° velikosti datovÇho bloku

         mov       bx,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         call      far ptr ModiSegS         ; nastaven° velikosti bufferu
         jc        OpenLDr7                 ; chyba pamàti

; ------ inicializace ukazatelñ

         call      far ptr IniLDir          ; inicializace ukazatelñ adres†©e
         jnc       OpenLDr9                 ; operace OK

; ------ p©i chybà zru®en° bufferu adres†©e

OpenLDr7:call      far ptr ClosLDir         ; zru®en° bufferu adres†©e
OpenLDr8:call      far ptr MemErr           ; chyba pamàti
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

OpenLDr9:pop       bx
         pop       ax
         ret

OpenLDir ENDP

; *****************************************************************************
;                               ClosLDir
;                uzav©en° bufferu adres†©e logickÇho disku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ClosLDir PROC      FAR

         push      ax
         mov       ax,ds:[DskLDirS]         ; á°slo segmentu bufferu adres†©e
         call      far ptr DelSeg           ; zru®en° datovÇho bloku
         mov       ds:[DskLDirS],ax         ; zru®en° á°sla segmentu
         pop       ax
         ret

ClosLDir ENDP

; *****************************************************************************
;                               IniLDir
;                   inicializace ukazatelñ adres†©e na ROOT
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba áten° sektoru ROOT
; *****************************************************************************

IniLDir  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ inicializace ukazatelñ

         mov       ah,":"
         mov       al,ds:[DskLDisk]         ; aktivn° disk
         add       al,"A"                   ; korekce na znak ASCII
         mov       word ptr ds:[DskLDir],ax ; zaá†tek textu adres†©e
         mov       word ptr ds:[DskLDir+2],"\" ; oznaáen° konce textu
         mov       word ptr ds:[DskLDirN],3 ; dÇlka textu adres†©e
         mov       bx,offset DskLDirT       ; ukazatel poloëek adres†©e
         mov       ds:[DskLDirM],bx         ; aktivn° poloëka ROOT
         and       byte ptr ds:[DskLPar],not bit3 ; nen° modifikace

; ------ inicializace popisovaáe prvn°ho adres†©e

         xor       ax,ax                    ; AX <- 0
         mov       ds:[bx],ax               ; poá†teán° alokaán° blok = ROOT
         mov       ds:[bx+2],ax             ; aktu†ln° alokaán° blok = ROOT
         mov       ds:[bx+4],ax             ; á°slo sektoru v bloku = 0
         mov       word ptr ds:[bx+6],-32   ; offset poloëky v bloku

; ------ naáten° poá†teán°ho sektoru ROOT

         call      ReadLDir                 ; naáten° sektoru adres†©e ROOT

; ------ n†vrat registrñ

         pop       bx
         pop       ax
         ret

IniLDir  ENDP

; *****************************************************************************
;                                   ResLDir
;               resetov†n° ukazatele na zaá†tek aktivn°ho adres†©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nàjak† chyba
; *****************************************************************************

ResLDir  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ p©°prava ukazatelñ aktivn°ho adres†©e

         mov       bx,ds:[DskLDirM]         ; adresa posledn° poloëky
         mov       ax,ds:[bx]               ; poá†teán° alokaán° blok
         mov       word ptr ds:[bx+6],-32   ; offset poloëky v sektoru

; ------ test, zda je jië prvn° sektor adres†©e

         cmp       ax,ds:[bx+2]             ; souhlas° aktu†ln° blok ?
         jne       ResLDir2                 ; aktu†ln° blok nesouhlas°
         cmp       word ptr ds:[bx+4],0     ; souhlas° aktu†ln° sektor ?
         je        ResLDir4                 ; aktu†ln° sektor je jië naáten OK

; ------ naáten° novÇho poá†teán°ho sektoru

ResLDir2:mov       ds:[bx+2],ax             ; aktu†ln° alokaán° blok
         mov       word ptr ds:[bx+4],0     ; aktu†ln° sektor v bloku
         call      ReadLDir                 ; naáten° aktivn°ho sektoru

; ------ n†vrat registrñ

ResLDir4:pop       bx
         pop       ax
         ret

ResLDir  ENDP

; *****************************************************************************
;                              SrcLDir
;                 nalezen° dal®°ho adres†©e (kromà ROOT)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: BX=á°slo poá†teán°ho alokaán°ho bloku adres†©e
;         CY=nen° dal®° adres†©
; *****************************************************************************

SrcLDir  PROC      FAR

; ------ £schova registrñ

         push      si
         push      es

; ------ p©°prava dal®° poloëky aktivn°ho adres†©e

SrcLDir1:call      far ptr NextLDir         ; nalezen° dal®° poloëky
         jc        SrcLDir6                 ; nen° dal®° poloëka (nebo chyba)

; ------ test, zda je to platn† poloëka adres†©e (nesm° bòt SYS ani HID)

         cmp       byte ptr es:[si],0       ; je konec adres†©e ?
         je        SrcLDir6                 ; je konec adres†©e
         cmp       byte ptr es:[si],0e5h    ; je zru®en† poloëka ?
         je        SrcLDir1                 ; zru®en† poloëka - dal®° poloëka
         cmp       byte ptr es:[si],"."     ; je to nadadres†© ?
         je        SrcLDir1                 ; je to nadadres†© - dal®° poloëka
         test      byte ptr es:[si+11],DIR  ; je to podadres†© ?
         jz        SrcLDir1                 ; nen° podadres†© - dal®° poloëka
         test      byte ptr es:[si+11],HID+SYS ; systÇmovò adres†© ?
         jnz       SrcLDir1                 ; je to systÇmovò adres†©

; ------ vno©en° do dal®°ho podadres†©e

         mov       bx,es:[si+26]            ; poá†teán° alokaán° blok adres†©e
         call      far ptr AddLDir          ; vno©en° do podadres†©e
         jc        SrcLDir1                 ; chyba - dal®° poloëka
         jmp       short SrcLDir9           ; operace OK

; ------ konec adres†©e - sn°ëen° hloubky adres†©e

SrcLDir6:call      far ptr SubLDir          ; sn°ëen° hloubky adres†©e
         jnc       SrcLDir1                 ; operace OK - dal®° poloëka
         cmp       word ptr ds:[DskLDirM],offset DskLDirT+1 ; je jië ROOT ?
         jae       SrcLDir6                 ; nen° je®tà ROOT (chyba) - zp†tky

; ------ n†vrat registrñ

SrcLDir9:pop       es
         pop       si
         ret

SrcLDir  ENDP

; *****************************************************************************
;                                 AddLDir
;                    vno©en° ukazatele do podadres†©e
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno podadres†©e FCB (je-li v bufferu adres†©e, zru®° se !)
;        BX=á°slo bloku podadres†©e
;        DS=datovò segment
; VùSTUP: CY=chyba (hloubka adres†©e nezmànàna)
; *****************************************************************************

AddLDir  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      di
         push      es
         xchg      ax,bx                    ; AX <- á°slo bloku podadres†©e

; ------ test, zda je jië maxim†ln° hloubka adres†©e

         mov       bx,ds:[DskLDirM]         ; adresa posledn° poloëky
         cmp       bx,offset DskLDirT + DirMax*8 ; je jië maxim†ln° poáet ?
         cmc
         jc        AddLDir9                 ; je jië maxim†ln° poáet poloëek

; ------ test, zda je jië maxim†ln° dÇlka cesty adres†©e

         cmp       word ptr ds:[DskLDirN],FileMax+4 ; asi tak maxim†ln° dÇlka
         cmc
         jc        AddLDir9                 ; je jië maxim†ln° dÇlka adres†©e

; ------ inicializace novÇho popisovaáe

         add       bx,8                     ; adresa dal®°ho popisovaáe
         mov       ds:[DskLDirM],bx         ; adresa novÇ posledn° poloëky
         mov       ds:[bx],ax               ; poá†teán° alokaán° blok
         mov       ds:[bx+2],ax             ; aktu†ln° alokaán° blok
         mov       word ptr ds:[bx+4],0     ; aktu†ln° sektor v bloku
         mov       word ptr ds:[bx+6],-32   ; offset poloëky v sektoru (bude 1.)

; ------ zaji®tàn° oddàlovac°ho znaku "\"

         mov       di,ds:[DskLDirN]         ; dÇlka textu adres†©e
         add       di,offset DskLDir        ; adresa konce textu adres†©e
         cmp       byte ptr ds:[di-1],"\"   ; je jië koncovò "\" ?
         je        AddLDir2                 ; je jië koncovò znak "\"
         mov       byte ptr ds:[di],"\"     ; oddàlovac° znak "\"
         inc       di

; ------ p©id†n° jmÇna adres†©e k cestà

AddLDir2:push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- poloëka FCB
         pop       es                       ; ES <- buffer k dek¢dov†n°
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna adres†©e
         pop       ds
         sub       di,offset DskLDir        ; nov† dÇlka textu adres†©e
         mov       ds:[DskLDirN],di         ; nov† dÇlka textu adres†©e

; ------ naáten° novÇho adres†©e

         call      ReadLDir                 ; novÇ naáten° adres†©e
         jnc       AddLDir9                 ; operace OK

; ------ p©i chybà navr†cen° £rovnà adres†©e

         call      far ptr SubLDir          ; navr†cen° £rovnà adres†©e
         stc                                ; p©°znak chyby operace

; ------ n†vrat registrñ

AddLDir9:pop       es
         pop       di
         pop       bx
         pop       ax
         ret

AddLDir  ENDP

; *****************************************************************************
;                                 SubLDir
;                   n†vrat o jednu £rove§ adres†©e n°ëe
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° dal®° £rove§ nebo chyba áten°
; *****************************************************************************

SubLDir  PROC      FAR

; ------ test, zda je jië ROOT

         cmp       word ptr ds:[DskLDirM],offset DskLDirT+1 ; je jië ROOT ?
         jb        SubLDir9                 ; je jië ROOT

; ------ sn°ëen° ukazatele poloëek

         sub       word ptr ds:[DskLDirM],8 ; adresa novÇ poloëky

; ------ sn°ëen° dÇlky cesty adres†©e

         push      si
         mov       si,ds:[DskLDirN]         ; dÇlka textu adres†©e
         add       si,offset DskLDir        ; adresa konce textu adres†©e
SubLDir2:dec       si
         cmp       byte ptr ds:[si],"\"
         jne       SubLDir2
         cmp       byte ptr ds:[si-1],":"   ; je to ROOT ?
         jne       SubLDir3                 ; nen° ROOT
         inc       si                       ; znak "\" se zachov†
SubLDir3:mov       byte ptr ds:[si],0       ; oznaáen° novÇho konce cesty
         sub       si,offset DskLDir        ; dÇlka textu cesty
         mov       ds:[DskLDirN],si         ; nov† dÇlka textu cesty
         pop       si

; ------ novÇ naáten° sektoru adres†©e

         call      ReadLDir                 ; naáten° aktivn°ho sektoru adres†©e
SubLDir9:ret

SubLDir  ENDP

; *****************************************************************************
;                                 NextLDir
;             nalezen° dal®° poloëky v adres†©i logickÇho disku
;                  vyëaduje obsluhu pomoc° tabulky FAT !!!
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: ES:SI=adresa dal®° poloëky v bufferu adres†©e
;         CY=konec adres†©e nebo chyba (buffer nedefinov†n)
; *****************************************************************************

NextLDir PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ zvò®en° ukazatele poloëek v sektoru

         mov       bx,ds:[DskLDirM]         ; adresa posledn° poloëky
         add       word ptr ds:[bx+6],32    ; zvò®en° ukazatele poloëek

         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jnz       NextLDr1                 ; je to CD disk

; ------ test, zda je poloëka je®tà v bufferu

         mov       ax,ds:[bx+6]             ; ukazatel poloëek v sektoru
         cmp       ax,ds:[DskLBSkt]         ; je poloëka je®tà v sektoru ?
         jb        NextLDr8                 ; poloëka je je®tà v sektoru

; ------ zvò®en° ukazatele sektorñ

         mov       word ptr ds:[bx+6],0     ; novò offset poloëky v sektoru
         inc       word ptr ds:[bx+4]       ; zvò®en° á°sla sektoru
         mov       ax,ds:[bx+4]             ; á°slo novÇho sektoru

; ------ test, zda je platnò sektor ROOT

         cmp       word ptr ds:[bx],0       ; je to ROOT adres†© ?
         jne       NextLDr2                 ; nen° ROOT adres†©
         cmp       ax,ds:[DskLSRot]         ; je to platnò sektor ROOT ?
         jb        NextLDr7                 ; je to platnò sektor ROOT
NextLDr1:stc                                ; p©°znak konce adres†©e
         jmp       short NextLDr9           ; nen° dal®° sektor

; ------ test, zda je platnò sektor v bloku

NextLDr2:cmp       ax,ds:[DskLSBlk]         ; je to platnò sektor ?
         jb        NextLDr7                 ; je to platnò sektor

; ------ nalezen° dal®°ho alokaán°ho bloku

         push      bx
         mov       bx,ds:[bx+2]             ; aktu†ln° alokaán° blok
         call      far ptr GetClust         ; dal®° alokaán° blok
         pop       bx
         jc        NextLDr9                 ; nen° dal®° blok
         stc
         jz        NextLDr9                 ; na ROOT nesm° ukazovat
         mov       ds:[bx+2],ax             ; novò alokaán° blok
         mov       word ptr ds:[bx+4],0     ; sektor v bloku

; ------ naáten° novÇho aktivn°ho sektoru

NextLDr7:call      ReadLDir                 ; naáten° novÇho aktivn°ho sektoru
         jc        NextLDr9                 ; chyba

; ------ operace OK - adresa poloëky (ukazatel DS:BX)

NextLDr8:mov       ax,ds:[DskLDirS]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         mov       si,ds:[bx+6]             ; adresa poloëky

; ------ n†vrat registrñ

NextLDr9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NextLDir ENDP

; -----------------------------------------------------------------------------
;                                ReadLDir
;                  naáten° aktivn°ho sektoru adres†©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò sektor
; VùSTUP: CY=chyba
; -----------------------------------------------------------------------------

ReadLDir PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ adresa bufferu sektoru -> ES:DI

         mov       ax,ds:[DskLDirS]         ; segment bufferu
         call      far ptr GetDat           ; adresa bufferu
         jc        ReadLDr9
         xor       di,di                    ; ukl†dac° adresa do bufferu

; ------ vòpoáet á°sla poá†teán°ho sektoru

         mov       bx,ds:[DskLDirM]         ; adresa posledn° poloëky
         mov       cx,ds:[bx+4]             ; á°slo sektoru v bloku
         mov       bx,ds:[bx+2]             ; á°slo alokaán°ho bloku
         call      far ptr ClstSekt         ; vòpoáet á°sla sektoru
         jc        ReadLDr9                 ; neplatnÇ á°slo sektoru
         add       ax,cx                    ; á°slo sektoru v bloku
         adc       dx,0                     ; p©enos HIGH

; ------ naáten° poá†teán°ho sektoru

         mov       cx,1                     ; naáte se 1 sektor
         call      far ptr ReadLDsk         ; naáten° sektoru adres†©e
         jnc       ReadLDr9                 ; sektor naáten OK
         mov       bx,ds:[DskLDirM]         ; adresa posledn° poloëky
         mov       word ptr ds:[bx+6],-64   ; poloëka je neplatn†

; ------ n†vrat registrñ

ReadLDr9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadLDir ENDP

; *****************************************************************************
;                               ClstSekt
;               p©epoáet alokaán°ho bloku na absolutn° sektor
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo alokaán°ho bloku (0,2...)
;        DS=datovò segment
; VùSTUP: DX:AX=á°slo absolutn°ho sektoru logickÇho disku
;         CY=neplatnÇ á°slo bloku
; *****************************************************************************

ClstSekt PROC      FAR

         push      bx

         xor       dx,dx                    ; DX <- 0
         sub       bx,2                     ; korekce á°sla alokaán°ho bloku
         jc        ClstSkt3                 ; je ROOT
         cmp       bx,ds:[DskLNBlk]         ; povolenÇ á°slo bloku ?
         jae       ClstSkt3                 ; nepovolenÇ á°slo bloku

         mov       ax,ds:[DskLSBlk]         ; poáet sektorñ na alokaán° blok
         mul       bx                       ; relativn° á°slo sektoru
         add       ax,ds:[DskLBDat]         ; p©iáten° poá†teán°ho dat. sektoru
         adc       dx,0                     ; p©enos HIGH

         pop       bx
         ret

ClstSkt3:cmc
         mov       ax,ds:[DskLBRot]         ; poá†teán° sektor ROOT
         pop       bx
         ret

ClstSekt ENDP

; *****************************************************************************
;                               GetClust
;    poskytnut° alokaán°ho bloku z tabulky FAT (pouë°v† INT 25h a INT 26h !)
; -----------------------------------------------------------------------------
; VSTUP: BX=poëadovanò alokaán° blok
;        DS=datovò segment
; VùSTUP: AX=n†sleduj°c° alokaán° blok (FFF7=vadnò blok, FFFF=konec, 0=volnò)
;         CY, NZ = vadnò blok, posledn° blok nebo chyba
;         NC, NZ = blok OK
;         NC, ZY = volnò alokaán° blok
; *****************************************************************************

GetClust PROC      FAR

; ------ £schova registrñ

         push      dx
         push      di
         push      es

; ------ kontrola platnosti á°sla alokaán°ho bloku

         cmp       bx,ds:[DskLMBlk]         ; maxim†ln° á°slo alokaán°ho bloku
         ja        GetClst6                 ; konec disku
         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jnz       GetClst6                 ; je to CD disk

; ------ rozli®en°, zda je FAT 12

         mov       ax,bx                    ; AX <- poëadovanò alokaán° blok
         xor       dx,dx                    ; DX <- 0
         test      byte ptr ds:[DskLPar],bit0 ; je FAT 16 ?
         jnz       GetClst3                 ; je FAT 16

; ------ dal®° alokaán° blok pro FAT 12

         shr       ax,1                     ; á°slo bloku / 2
         add       ax,bx                    ; á°slo bloku * 1.5
         adc       dx,dx                    ; p©enos HIGH
         call      far ptr OffsFat          ; zaji®tàn° offsetu ve FAT
         jc        GetClst6                 ; nàjak† chyba
         mov       ax,es:[di]               ; n†sleduj°c° alokaán° blok
         test      bl,1                     ; lichò alokaán° blok ?
         jz        GetClst2                 ; je to sudò alokaán° blok
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; rotace o 4 bity
GetClst2:and       ax,0fffh                 ; maskov†n° á°sla alok. bloku

; ------ rozli®en° typu bloku

         cmp       ax,0ff7h                 ; je to vadnò blok ?
         jmp       short GetClst4

; ------ dal®° alokaán° blok pro FAT 16

GetClst3:shl       ax,1                     ; á°slo bloku * 2
         rcl       dx,1                     ; p©enos HIGH
         call      far ptr OffsFat          ; zaji®tàn° offsetu ve FAT
         jc        GetClst6                 ; nàjak† chyba
         mov       ax,es:[di]               ; n†sleduj°c° alokaán° blok

; ------ rozli®en° typu bloku

         cmp       ax,0fff7h                ; je to vadnò blok ?
GetClst4:je        GetClst7                 ; vadnò alokaán° blok
         ja        GetClst6                 ; konec ©etàzce
         or        ax,ax                    ; je volnò alokaán° blok ?
         jmp       short GetClst9

; ------ konec ©etàzce

GetClst6:mov       al,0ffh

; ------ vadnò alokaán° blok, konec nebo chyba

GetClst7:mov       ah,0ffh
GetClst8:or        ax,ax                    ; p©°znak NZ
         stc                                ; p©°znak konce ©etàzce

; ------ n†vrat registrñ

GetClst9:pop       es
         pop       di
         pop       dx
         ret

GetClust ENDP

; *****************************************************************************
;                               SetClust
;    nastaven° alokaán°ho bloku v tabulce FAT (pouë°v† INT 25h a INT 26h !)
; -----------------------------------------------------------------------------
; VSTUP: AX=hodnota k uloëen° do poloëky (FFF7=vadnò blok, FFFF=konec, 0=volnò)
;        BX=poëadovanò alokaán° blok (2 a v°ce)
;        DS=datovò segment
; VùSTUP: CY=chyba z†pisu
; *****************************************************************************

SetClust PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ kontrola platnosti á°sla alokaán°ho bloku

         cmp       bx,2                     ; minim†ln° á°slo bloku = 2
         jb        SetClst9                 ; neplatnÇ á°slo bloku
         mov       dx,ds:[DskLMBlk]         ; maxim†ln° á°slo alokaán°ho bloku
         inc       dx                       ; max. á°slo alok. bloku + 1
         cmp       bx,dx                    ; kontrola á°sla bloku
         cmc
         jc        SetClst9                 ; konec disku

; ------ rozli®en°, zda je FAT 12

         xchg      ax,cx                    ; CX <- £schova poëadovanÇ hodnoty
         mov       ax,bx                    ; AX <- poëadovanò alokaán° blok
         xor       dx,dx                    ; DX <- 0
         test      byte ptr ds:[DskLPar],bit0 ; je FAT 16 ?
         jnz       SetClst5                 ; je FAT 16

; ------ alokaán° blok pro FAT 12

         and       cx,0fffh                 ; maskov†n° hodnoty k uloëen°
         shr       ax,1                     ; á°slo bloku / 2
         add       ax,bx                    ; á°slo bloku * 1.5
         adc       dx,dx                    ; p©enos HIGH
         call      far ptr OffsFat          ; zaji®tàn° offsetu ve FAT
         jc        SetClst9                 ; nàjak† chyba
         mov       ax,0f000h                ; maska pro sudò alokaán° blok
         test      bl,1                     ; lichò alokaán° blok ?
         jz        SetClst2                 ; je to sudò alokaán° blok
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; rotace o 4 bity
         mov       ax,0fh                   ; maska pro lichò alokaán° blok
SetClst2:and       es:[di],ax               ; maskov†n° starÇ hodnoty
         or        es:[di],cx               ; nastaven° novÇ hodnoty
         jmp       short SetClst8

; ------ alokaán° blok pro FAT 16

SetClst5:shl       ax,1                     ; á°slo bloku * 2
         rcl       dx,1                     ; p©enos HIGH
         call      far ptr OffsFat          ; zaji®tàn° offsetu ve FAT
         jc        SetClst9                 ; nàjak† chyba
         mov       es:[di],cx               ; uloëen° poëadovanÇ hodnoty
SetClst8:or        byte ptr ds:[DskLPar],bit2 ; p©°znak modifikace FAT

; ------ n†vrat registrñ

SetClst9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

SetClust ENDP

; *****************************************************************************
;                               OffsFat
;        zaji®tàn° offsetu v tabulce FAT (pouë°v† INT 25h a INT 26h !)
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=poëadovanò offset v tabulce FAT
;        DS=datovò segment
; VùSTUP: ES:DI=adresa v bufferu FAT
;         CY=chyba operace
; *****************************************************************************

OffsFat  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ adresa datovÇho bufferu

         call      far ptr GetLFat          ; adresa datovÇho bufferu FAT
         jc        OffsFat9                 ; chyba ?

; ------ vòpoáet offsetu v sektoru a á°sla sektoru

         cmp       dx,ds:[DskLBSkt]         ; je povolenò offset ?
         cmc
         jc        OffsFat9                 ; bylo by p©eteáen°
         div       word ptr ds:[DskLBSkt]   ; vòpoáet sektoru a offsetu
         mov       di,dx                    ; DI <- offset v sektoru

; ------ kontrola, zda je sektor jië v bufferu

         cmp       ax,ds:[DskLFatA]         ; je sektor jië v bufferu ?
         je        OffsFat9                 ; sektor je jië v bufferu OK

; ------ test, zda je to alespo§ druhò sektor

         mov       cx,ax                    ; CX <- poëadovanò sektor
         jcxz      OffsFat4                 ; je sektor 0
         dec       cx                       ; korekce sektoru pro druhò sektor
         cmp       cx,ds:[DskLFatA]         ; je alespo§ druhò sektor ?
         jne       OffsFat4                 ; nen° ani druhò sektor - naáten°

; ------ test offsetu v sektoru, zda vyhovuje (mus° bòt rezerva 1 slovo)

         mov       cx,di                    ; CX <- offset v sektoru
         inc       cx                       ; 2 bajty rezerva
         cmp       cx,ds:[DskLBSkt]         ; je ukazatel je®tà v sektoru ?
         jae       OffsFat4                 ; ukazatel jië nen° v sektoru
         add       di,ds:[DskLBSkt]         ; korekce adresy na druhò sektor
         jmp       short OffsFat9           ; NC = operace OK

; ------ zaji®tàn° z†pisu starÇho sektoru FAT

OffsFat4:call      far ptr WritFat          ; uloëen° starÇ tabulky FAT
         jc        OffsFat9                 ; chyba z†pisu

; ------ p©°prava registrñ k naáten° novÇ tabulky FAT (relativn° sektor AX)

         mov       ds:[DskLFatA],ax         ; novÇ á°slo sektoru tabulky FAT
         mov       cx,ax                    ; CX <- rel. á°slo sektoru FAT
         add       ax,ds:[DskLBFat]         ; absolutn° á°slo sektoru FAT
         xor       dx,dx                    ; DX <- 0 á°slo sektoru HIGH
         mov       bl,ds:[DskLNFat]         ; poáet tabulek FAT
         inc       cx                       ; rel. á°slo sektoru + 1
         cmp       cx,ds:[DskLSFat]         ; je to posledn° sektor FAT ?
         mov       cx,1                     ; naáte se 1 sektor
         jae       OffsFat6                 ; je to posledn° sektor FAT
         inc       cx                       ; jinak se naátou 2 sektory

; ------ naáten° poëadovanòch sektorñ

OffsFat6:test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jnz       OffsFat9                 ; je to CD disk
         push      di
         xor       di,di                    ; DI <- 0 poá†tek bufferu FAT
         call      far ptr ReadLDsk         ; áten° sektoru z disku
         pop       di
         jnc       OffsFat9                 ; data naátena OK
         add       ax,ds:[DskLSFat]         ; á°slo sektoru pro dal®° FAT
         adc       dx,0
         dec       bl                       ; á°taá tabulek FAT
         jnz       OffsFat6                 ; áten° z dal®° tabulky FAT
         stc                                ; p©°znak chyby operace

; ------ n†vrat registrñ

OffsFat9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OffsFat  ENDP

; *****************************************************************************
;                                WritFat
;         z†pis tabulky FAT, pokud byla modifikov†na (pouë°v† INT 26h !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba z†pisu FAT
; *****************************************************************************

WritFat  PROC      FAR

; ------ test, zda byl sektor modifikov†n

         test      byte ptr ds:[DskLPar],bit2 ; je nutnò z†pis tabulky FAT ?
         jz        WritFat9                 ; nen° nutnò z†pis tabulky FAT

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ p©°prava registrñ

         and       byte ptr ds:[DskLPar],not bit2+bit4 ; zru®en° modifikace+chyba
         call      far ptr GetLFat          ; poskytnut° adresy tabulky FAT
         jc        WritFat8                 ; chyba ?
         xor       si,si                    ; SI <- 0 poá†tek bufferu
         mov       bl,ds:[DskLNFat]         ; poáet tabulek FAT
         mov       cx,ds:[DskLFatA]         ; relativn° á°slo sektoru FAT
         mov       ax,cx                    ; relativn° á°slo sektoru FAT
         xor       dx,dx                    ; DX <- 0
         add       ax,ds:[DskLBFat]         ; absolutn° á°slo sektoru FAT
         inc       cx                       ; rel. á°slo sektoru + 1
         cmp       cx,ds:[DskLSFat]         ; je to posledn° sektor FAT ?
         mov       cx,1                     ; zap°®e se 1 sektor
         jae       WritFat2                 ; je to posledn° sektor FAT
         inc       cx                       ; jinak se zap°®ou 2 sektory

; ------ z†pis bufferu tabulky FAT

WritFat2:mov       bh,2                     ; poáet pokusñ o z†pis
WritFat3:call      far ptr WritLDsk         ; z†pis sektorñ FAT
         jnc       WritFat4                 ; operace z†pisu OK
         dec       bh                       ; á°taá pokusñ
         jnz       WritFat3                 ; dal®° pokus o z†pis
         jmp       short WritFat5
WritFat4:or        byte ptr ds:[DskLPar],bit4 ; p©°znak z†pisu FAT OK
WritFat5:add       ax,ds:[DskLSFat]         ; á°slo sektoru pro dal®° FAT
         adc       dx,0
         dec       bl                       ; á°taá tabulek FAT
         jnz       WritFat2                 ; z†pis dal®° tabulky FAT

; ------ p©°znak chyby operace

         test      byte ptr ds:[DskLPar],bit4 ; z†pis OK ?
         jnz       WritFat8                 ; z†pis byl OK
         stc                                ; p©°znak chyby z†pisu

; ------ n†vrat registrñ

WritFat8:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
WritFat9:ret

WritFat  ENDP

; *****************************************************************************
;                             OpenLFat
;              otev©en° bufferu tabulky FAT logickÇho disku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nedostatek pamàti (hl†s° chybu pamàti)
; *****************************************************************************

OpenLFat PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ vytvo©en° segmentu bufferu

         mov       word ptr ds:[DskLFatA],-1 ; neplatnÇ á°slo sektoru FAT
         call      far ptr CreatSeg         ; vytvo©en° datovÇho bloku
         jc        OpenLFt8                 ; chyba - nedostatek pamàti
         mov       ds:[DskLFatS],ax         ; á°slo datovÇho bloku

; ------ nastaven° velikosti datovÇho bloku

         mov       bx,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; velikost pro 2 sektory
         call      far ptr ModiSeg          ; nastaven° velikosti bufferu
         jnc       OpenLFt9                 ; operace OK

; ------ p©i chybà zru®en° bufferu FAT

         call      far ptr ClosLFat         ; zru®en° bufferu FAT
OpenLFt8:call      far ptr MemErr           ; chybovÇ hl†®en°
         stc                                ; p©°znak chyby

; ------ n†vrat registrñ

OpenLFt9:pop       bx
         pop       ax
         ret

OpenLFat ENDP

; *****************************************************************************
;                               ClosLFat
;                uzav©en° bufferu tabulky FAT logickÇho disku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ClosLFat PROC      FAR

         push      ax
         mov       ax,ds:[DskLFatS]         ; á°slo segmentu bufferu FAT
         call      far ptr DelSeg           ; zru®en° datovÇho bloku
         mov       ds:[DskLFatS],ax         ; zru®en° á°sla segmentu
         pop       ax
         ret

ClosLFat ENDP

; *****************************************************************************
;                                  GetLFat
;                      poskytnut° adresy tabulky FAT
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: ES=segment bufferu tabulky FAT
; *****************************************************************************

GetLFat  PROC      FAR

         push      ax
         mov       ax,ds:[DskLFatS]         ; á°slo segmentu bufferu FAT
         call      far ptr GetDat           ; adresa bufferu FAT
         pop       ax
         ret

GetLFat  ENDP

; *****************************************************************************
;                                ReadLDsk
;                  áten° z logickÇho disku (pomoc° INT 25h !)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa bufferu k naáten° dat
;        DX:AX=á°slo poá†teán°ho sektoru
;        CX=poáet sektorñ k naáten° (nesm° bòt v°ce dat neë 64 KB)
;        DS=datovò segment
; VùSTUP: CY=chyba áten°
; *****************************************************************************

ReadLDsk PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ test, zda je obsluha CD disku

         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jz        ReadLDC9                 ; nen° to CD disk

; ------ p©°prava registrñ ke áten° z CD disku

         xchg      ax,di                    ; DI <- poá†t.sektor LOW, AX<-adresa
         xchg      ax,bx                    ; BX <- offset adresy bufferu
         mov       si,dx                    ; SI <- poá†teán° sektor HIGH
         mov       dx,cx                    ; DX <- poáet sektorñ k naáten°
         mov       ch,0
         mov       cl,ds:[DskLDisk]         ; á°slo aktivn°ho disku

; ------ áten° dat z CD disku

         mov       al,8
         call      far ptr IntCD            ; áten° sektorñ z CD
         jmp       short ReadLDs8           ; CY=chyba

; ------ uloëen° registrñ do bufferu paketu

ReadLDC9:mov       word ptr ds:[DskLPakS],ax ; á°slo sektoru LOW
         mov       word ptr ds:[DskLPakS+2],dx ; á°slo sektoru HIGH
         mov       ds:[DskLPakN],cx         ; poáet sektorñ
         mov       word ptr ds:[DskLPakA],di ; adresa bufferu LOW
         mov       word ptr ds:[DskLPakA+2],es ; adresa bufferu HIGH
         clc
         jcxz      ReadLDs8                 ; nen° ë†dnò sektor ke áten°

; ------ £schova registrñ 2

ReadLDs0:mov       bp,2                     ; á°taá pokusñ
ReadLDs1:push      cx
         push      bp
         push      ds

; ------ rozli®en°, zda je operace paketem

         mov       al,ds:[DskLDisk]         ; á°slo aktivn°ho disku
         test      byte ptr ds:[DskLPar],bit1 ; je obsluha paketem ?
         jnz       ReadLDs2                 ; je obsluha paketem

; ------ nen° obsluha paketem

         mov       dx,word ptr ds:[DskLPakS] ; á°slo sektoru LOW
         mov       cx,ds:[DskLPakN]         ; poáet sektorñ ke áten°
         lds       bx,ds:[DskLPakA]         ; DS:BX <- adresa bufferu
         jmp       short ReadLDs3

; ------ je obsluha paketem

ReadLDs2:mov       bx,offset DskLPak        ; adresa paketu
         mov       cx,-1                    ; p©°znak operace paketem

; ------ operace áten° dat

ReadLDs3:mov       word ptr cs:[ReadLDsS],sp ; £schova SP
         mov       word ptr cs:[ReadLDsS+2],ss ; £schova SS
         int       25h                      ; áten° sektoru
         mov       ss,word ptr cs:[ReadLDsS+2] ; n†vrat SS
         mov       sp,word ptr cs:[ReadLDsS] ; n†vrat SP

; ------ n†vrat registrñ 2

         pop       ds
         pop       bp
         pop       cx

; ------ chyba operace

         jnc       ReadLDs8                 ; operace OK
         dec       bp                       ; á°taá pokusñ
         jnz       ReadLDs1                 ; dal®° pokus o áten°

; ------ n†vrat registrñ

ReadLDs8:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadLDsk ENDP

ReadLDsS dd        0                        ; uschovanò ukazatel z†sobn°ku SS:SP

; *****************************************************************************
;                                WritLDsk
;                  z†pis na logickò disk (pomoc° INT 26h !)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bufferu k z†pisu dat
;        DX:AX=á°slo poá†teán°ho sektoru
;        CX=poáet sektorñ k z†pisu (nesm° bòt v°ce dat neë 64 KB)
;        DS=datovò segment
; VùSTUP: CY=chyba z†pisu
; *****************************************************************************

WritLDsk PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ test, zda je obsluha CD disku

         test      byte ptr ds:[DskLPar],bit6 ; je to CD disk ?
         jz        WritLD01                 ; nen° to CD disk
         stc                                ; p©°znak chyby
         jmp       WritLDs8

; ------ odemknut° disku pro z†pis (DOS 7 a WINDOWS 95)

WritLD01:test      byte ptr ds:[DskLPar],bit5 ; byl disk jië odemknut ?
         jnz       WritLD04                 ; disk byl jië odemknut
         or        byte ptr ds:[DskLPar],bit5 ; p©°znak odemknut° disku

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
;˛
         mov       bh,4                     ; £rove§ uzamknut° disku
WritLD02:mov       bl,ds:[DskLDisk]         ; á°slo disku
         inc       bx                       ; korekce á°sla disku
         mov       ax,440dh                 ; á°slo funkce
         mov       cx,84ah                  ; kategorie
         mov       dx,bit0                  ; p©°znak - povolen z†pis
         stc                                ; p©°znak chyby
         push      bx
         int       21h                      ; odemknut° disku
         pop       bx
         jnc       WritLD03                 ; disk odemknut OK
         dec       bh                       ; zvò®en° £rovnà uzamknut°
         jns       WritLD02

WritLD03:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; ------ uloëen° registrñ do bufferu paketu

WritLD04:mov       word ptr ds:[DskLPakS],ax ; á°slo sektoru LOW
         mov       word ptr ds:[DskLPakS+2],dx ; á°slo sektoru HIGH
         mov       ds:[DskLPakN],cx         ; poáet sektorñ
         mov       word ptr ds:[DskLPakA],si ; adresa bufferu LOW
         mov       word ptr ds:[DskLPakA+2],es ; adresa bufferu HIGH
         clc
         jcxz      WritLDs8                 ; nen° ë†dnò sektor k z†pisu

; ------ £schova registrñ 2

WritLDs0:mov       bp,2                     ; á°taá pokusñ
WritLDs1:push      cx
         push      bp
         push      ds

; ------ rozli®en°, zda je operace paketem

         mov       al,ds:[DskLDisk]         ; á°slo aktivn°ho disku
         test      byte ptr ds:[DskLPar],bit1 ; je obsluha paketem ?
         jnz       WritLDs2                 ; je obsluha paketem

; ------ nen° obsluha paketem

         mov       dx,word ptr ds:[DskLPakS] ; á°slo sektoru LOW
         mov       cx,ds:[DskLPakN]         ; poáet sektorñ k z†pisu
         lds       bx,ds:[DskLPakA]         ; DS:BX <- adresa bufferu
         jmp       short WritLDs3

; ------ je obsluha paketem

WritLDs2:mov       bx,offset DskLPak        ; adresa paketu
         mov       cx,-1                    ; p©°znak operace paketem

; ------ operace z†pisu sektoru

WritLDs3:mov       word ptr cs:[WritLDsS],sp ; £schova SP
         mov       word ptr cs:[WritLDsS+2],ss ; £schova SS
         int       26h                      ; z†pis sektoru
         mov       ss,word ptr cs:[WritLDsS+2] ; n†vrat SS
         mov       sp,word ptr cs:[WritLDsS] ; n†vrat SP

; ------ n†vrat registrñ 2

         pop       ds
         pop       bp
         pop       cx

; ------ chyba operace

         jnc       WritLDs8                 ; operace OK
         dec       bp                       ; á°taá pokusñ
         jnz       WritLDs1                 ; dal®° pokus

; ------ n†vrat registrñ

WritLDs8:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritLDsk ENDP

WritLDsS dd        0                        ; uschovanò ukazatel z†sobn°ku SS:SP

; *****************************************************************************
;                                    GetParB
;         poskytnut° bloku parametrñ disku (informace se naátou z disku)
; -----------------------------------------------------------------------------
; VSTUP: AL=disk (0=A, ...)
; VùSTUP:ES:SI=adresa bloku parametrñ disku
;        CY=neplatnò disk nebo sluëba nen° obsluhovan†
; *****************************************************************************
;Notes:  the OS/2 compatibility box supports the DOS 3.3 version of this call
;          except for the DWORD at offset 12h
;        this call updates the DPB by reading the disk; the DPB may be accessed
;          via the DOS list of lists (see #0840 at AH=52h) if disk access is not
;          desirable.
;        undocumented prior to the release of DOS 5.0; only the DOS 4.0+
;          version of the DPB has been documented, however
;        supported by DR-DOS 3.41+; DR-DOS 3.41-6.0 return the same data as
;          MS-DOS 3.31
;SeeAlso: AH=1Fh,AH=52h
;
;Format of DOS Drive Parameter Block:
;Offset  Size    Description     (Table 0620)
; 00h    BYTE    drive number (00h = A:, 01h = B:, etc)
; 01h    BYTE    unit number within device driver
; 02h    WORD    bytes per sector
; 04h    BYTE    highest sector number within a cluster
; 05h    BYTE    shift count to convert clusters into sectors
; 06h    WORD    number of reserved sectors at beginning of drive
; 08h    BYTE    number of FATs
; 09h    WORD    number of root directory entries
; 0Bh    WORD    number of first sector containing user data
; 0Dh    WORD    highest cluster number (number of data clusters + 1)
;                16-bit FAT if greater than 0FF6h, else 12-bit FAT
; 0Fh    BYTE    number of sectors per FAT
; 10h    WORD    sector number of first directory sector
; 12h    DWORD   address of device driver header
; 16h    BYTE    media ID byte (see #0581)
; 17h    BYTE    00h if disk accessed, FFh if not
; 18h    DWORD   pointer to next DPB
;---DOS 2.x---
; 1Ch    WORD    cluster containing start of current directory, 0000h=root,
;                FFFFh = unknown
; 1Eh 64 BYTEs   ASCIZ pathname of current directory for drive
;---DOS 3.x---
; 1Ch    WORD    cluster at which to start search for free space when writing
; 1Eh    WORD    number of free clusters on drive, FFFFh = unknown
;---DOS 4.0-6.0---
; 0Fh    WORD    number of sectors per FAT
; 11h    WORD    sector number of first directory sector
; 13h    DWORD   address of device driver header
; 17h    BYTE    media ID byte (see #0581)
; 18h    BYTE    00h if disk accessed, FFh if not
; 19h    DWORD   pointer to next DPB
; 1Dh    WORD    cluster at which to start search for free space when writing,
;                usually the last cluster allocated
; 1Fh    WORD    number of free clusters on drive, FFFFh = unknown

GetParB  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp

         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        GetParB8                 ; p©eru®en° operace

; ------ poskytnut° bloku parametrñ disku -> ES:SI

         xchg      ax,dx                    ; DL <- poëadovanò disk
         push      dx                       ; DL=poëadovanò disk
         inc       dx                       ; korekce á°sla disku
         push      ds                       ; £schova datovÇho segmentu
         mov       bx,-1                    ; p©ednastaven° na nesmysl
         mov       ax,32ffh                 ; AL=p©ednastaven° na neplatnò disk
         int       21h                      ; poskytnut° tabulky disku
         mov       si,bx                    ; SI <- offset adresy
         push      ds                       ; DS=segment adresy
         pop       es                       ; ES <- segment adresy
         pop       ds                       ; n†vrat datovÇho segmentu
         pop       dx                       ; DL=poëadovanò disk

; ------ kontrola vòsledku operace

         cmp       al,0ffh                  ; n†vratovò k¢d
         je        GetParB8                 ; FF=neplatnò disk
         cmp       bx,0ffe0h                ; nepovolen† adresa
         jae       GetParB8                 ; neplatn† adresa
         mov       cx,ds                    ; CX <- datovò segment
         mov       ax,es                    ; datovò segment adresy
         cmp       ax,cx                    ; zmànil se datovò segment ?
         je        GetParB8                 ; nezmànil - sluëba neplatn†
         cmp       dl,es:[si]               ; souhlas° á°slo disku ?
         je        GetParB9                 ; á°slo disku souhlas° OK

; ------ n†vrat registrñ

GetParB8:stc                                ; p©°znak chyby operace
GetParB9:pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetParB  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° velikosti cache SMARTDRV
; -----------------------------------------------------------------------------
; VùSTUP: BX=velikost v elementech
;         CX=velikost jednoho elementu v bajtech
;         DX=velikost v elementech pro WINDOWS
; -----------------------------------------------------------------------------

SmartSiz PROC      FAR

         mov       bl,4
         push      ax
         call      SmartInt                 ; poskytnut° informac°
         pop       ax
         ret

SmartSiz ENDP

; -----------------------------------------------------------------------------
;        nastaven° stavu SMARTDRV pro disk AL
; -----------------------------------------------------------------------------
; VSTUP/VùSTUP: AH=stav
;                  bit 6: 1=nen° z†pisovò cache
;                  bit 7: 1=nen° átec° cache
; -----------------------------------------------------------------------------

SmartSet PROC      FAR

         push      dx

         mov       dl,3                     ; z†pisovò cache zapnout
         test      ah,bit6                  ; m† bòt z†pisovò cache ?
         jz        SmartSt2                 ; z†pisovò cache zapnut
         mov       dl,4                     ; z†pisovò cache vypnout
SmartSt2:push      ax
         call      far ptr SmartGt0         ; nastaven° z†pisovÇho cache
         pop       ax

         mov       dl,1                     ; átec° cache zapnout
         test      ah,bit7                  ; m† bòt átec° cache ?
         jz        SmartSt4                 ; átec° cache zapnut
         mov       dl,2                     ; átec° cache vypnout
SmartSt4:push      ax
         call      far ptr SmartGt0         ; nastaven° átec°ho cache
         pop       ax

         pop       dx
         ret

SmartSet ENDP

SmartGt0:push      dx
         jmp       short SmartGt2

; -----------------------------------------------------------------------------
;        poskytnut° stavu SMARTDRV pro disk AL
; -----------------------------------------------------------------------------
; VùSTUP: AH=stav
;                  bit 0-5: skuteánÇ á°slo disku
;                  bit 6: 1=nen° z†pisovò cache
;                  bit 7: 1=nen° átec° cache
; -----------------------------------------------------------------------------

SmartGet PROC      FAR

         push      dx
         mov       dl,0                     ; poskytnut° informac°

SmartGt2:push      ax
         push      bx
         push      cx
         push      bp

         mov       ah,0
         xchg      ax,bp                    ; BP <- poëadovanò disk
         mov       bl,3
         call      SmartInt                 ; poskytnut° stavu

         pop       bp
         pop       cx
         pop       bx
         pop       ax

         mov       ah,dl                    ; AH <- navr†cenò stav
         pop       dx
         ret

SmartGet ENDP

; -----------------------------------------------------------------------------
;        resetov†n° SMARTDRV
; -----------------------------------------------------------------------------

SmartRes PROC      FAR

         push      bx

         mov       bl,2
         jmp       short SmartDt2

SmartRes ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° SMARTDRV
; -----------------------------------------------------------------------------

SmartFls PROC      FAR

         push      bx

         mov       bl,1
         jmp       short SmartDt2

SmartFls ENDP

; -----------------------------------------------------------------------------
;        test instalace SMARTDRV verze 4.00 a vò®e -> AX verze BCD
; -----------------------------------------------------------------------------

SmartDet PROC      FAR

         push      bx

         mov       bl,0                     ; test instalace
SmartDt2:push      cx
         push      dx
         call      SmartInt                 ; test instalace
         pop       dx
         pop       cx

         pop       bx
         ret

SmartDet ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru®en° pro SMARTDRV (funkce BL) -> CY chyba
; -----------------------------------------------------------------------------

SmartInt PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       ax,4a10h
         mov       bh,0
         mov       cx,0ebabh
         int       2fh

         cmp       ax,0babeh                ; je instalov†n ?
         je        SmrtInt2                 ; je instalov†n OK
         stc                                ; p©°znak chyby

SmrtInt2:xchg      ax,bp                    ; AX <- registr BP

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

SmartInt ENDP

CodeDisk ENDS

;INCLUDE  ASM\DISK1.ASM                     ; parkov†n°, jmenovka, form†tov†n°
;INCLUDE  ASM\DISK2.ASM                     ; informace, mapa, editace
;INCLUDE  ASM\DISK3.ASM                     ; nulov†n°

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
Data     SEGMENT

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - obsluha disku
; -----------------------------------------------------------------------------

DMnuVert label     byte                   ;* menu disku

         db        1                        ; typ menu - vertik†ln° menu hlavn°

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        13                       ; poáet platnòch poloëek menu
         dw        13                       ; celkovò poáet poloëek menu

         dw        DMnuVPol                 ; adresa definice poloëek menu
         dw        DMnuVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuDisk          ; á°slo str†nky velkÇ n†povàdy
         dw        DMnuVBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        DMnuVTit                 ; adresa titulu okna
         dw        DMnuVExe                 ; tabulka obsluh voleb menu
         dw        DMnuVAdr                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        39                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        15                       ; vò®ka

DMnuVPol db        1,4,'Disk'
         db        1,7,'Editace'
         db        1,11,'Form†tov†n°'
         db        1,9,'Informace'
         db        1,5,'JmÇno'
         db        1,5,'Kopie'
         db        1,4,'Mapa'
         db        1,17,'Nulov†n°        ',16
;         db        1,15,'Operaán° systÇm'
         db        1,9,'Parkov†n°'
         db        1,6,'Ru®en°'
         db        1,8,'Srovn†n°'
;         db        1,4,'Test'
;         db        1,17,'Unfragmentace   ',16
         db        1,10,'Verifikace'
         db        1,9,'Zobrazen°'

; Pozor - tabulka DMnuVBlk je nastavov†na p©i inicializaci a testov†na
;         s jednotlivòch procedur !

DMnuVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0

DMnuVTit db        7,'disk @:'

HelpS    SEGMENT   BYTE PUBLIC
DMnuVHlp db        50,'Volba novÇho aktivn°ho disku (Alt-F1 a Alt-F2)'
         db        48,'Editace obsahu disku (CD disk pouze zobrazen°)'
         db        46,'Form†tov†n° (inicializace) diskety (Ctrl-F8)'
         db        24,'Blië®° informace o disku'
         db        62,'P©ejmenov†n° disku - zmàna jmenovky (Volume Label) (Ctrl-F6)'
         db        36,'Kop°rov†n° obsahu disket (Ctrl-F5)'
         db        29,'Zobrazen° mapy zaplnàn° disku'
         db        67,'Nulov†n° nevyuëitÇho prostoru disku (pro zamezen° obnoven° souborñ)'
;         db        66,'P©enesen° operaán°ho systÇmu na disk - vytvo©en° systÇmovÇho disku'
         db        73,'Uloëen° konfigurace, vypr†zdnàn° CACHE, parkov†n° diskñ, poá°taá do klidu'
         db        29,'RychlÇ zru®en° obsahu diskety'
         db        28,'Porovn†n° obsahu dvou disket'
;         db        73,'Test struktury disku (ztracenÇ bloky, k©°ëov† spojen°, neplatnÇ adres†©e)'
;         db        60,'Unfragmentace - komprese disku (spojen° nespojitòch souborñ)'
         db        31,'Ovà©en° áitelnosti obsahu disku'
         db        34,'Zobrazen° obsahu disku (Ctrl-F3)'
HelpS    ENDS

DMnuVExe label     dword                    ; tabulka obsluh menu
         dd        AWMOL1D                  ; disk
         dd        EdiDisk                  ; editace
         dd        Format                   ; form†tov†n°
         dd        DiskDInf                 ; informace
         dd        Labs                     ; jmÇno
         dd        KopDisk                  ; kopie
         dd        DiskMap                  ; mapa
         dd        NulDisk                  ; nulov†n°
;         dd        0                        ; systÇm
         dd        Parkov                   ; parkov†n°
         dd        RusDisk                  ; ru®en° disku
         dd        CmpDisk                  ; srov†n°
;         dd        0                        ; unfragmentace
         dd        DiskVer                  ; verifikace
         dd        ZobDisk                  ; zobrazen°

DMnuVAdr label     word                     ; tabulka adres podmenu
         dw        0                        ; disk
         dw        0                        ; editace
         dw        0                        ; form†tov†n°
         dw        0                        ; informace
         dw        0                        ; jmÇno
         dw        0                        ; kopie
         dw        0                        ; mapa
         dw        NulDMnu                  ; nulov†n°
;         dw        0                        ; systÇm
         dw        0                        ; parkov†n°
         dw        0                        ; ru®en°
         dw        0                        ; srov†n°
;         dw        0                        ; unfragmentace
         dw        0                        ; verifikace
         dw        0                        ; zobrazen°


VolDate  dw        0                        ; datum nalezenÇho n†và®t° disku
VolTime  dw        0                        ; áas nalezenÇho n†và®t° disku

; ------ mezi£schova velikosti CD disku v bajtech

GetCDMxS dd        0                        ; velikost CD disku v bajtech
                                            ;  HIGH=0 neplatnò £daj

; ------ parametry aktivn°ho logickÇho disku

DskLDisk db        0                        ; á°slo aktivn°ho logickÇho disku
DskLPar  db        0                        ; parametry aktiv. logickÇho disku
                                            ;   bit 0: 1=je FAT 16
                                            ;   bit 1: 1=je obsluha paketem
                                            ;   bit 2: 1=nutnò z†pis tabulky FAT
                                            ;   bit 3: 1=nutnò z†pis adres†©e
                                            ;   bit 4: 1=jeden z†pis FAT OK
                                            ;   bit 5: 1=odemknut pro z†pis LOCK
                                            ;   bit 6: 1=je to CD disk

DskLBSkt dw        0                        ; poáet bajtñ na sektor
DskLOSkt dw        0                        ; poáet odstavcñ na sektor
DskLASkt dw        0                        ; poáet adres. poloëek na sektor
DskLNSkt dd        0                        ; celkovò poáet sektorñ na disku

DskLSBlk dw        0                        ; poáet sektorñ na alokaán° blok
DskLOBlk dw        0                        ; poáet odstavcñ na alokaán° blok
DskLBBlk dw        0                        ; poáet bajtñ na alokaán° blok
DskLRBlk db        0                        ; ©†d velikosti alok. bloku (9<-512)
DskLNBlk dw        0                        ; celkovò poáet alokaán°ch blokñ
DskLMBlk dw        0                        ; maxim†ln° á°slo alokaán°ho bloku

DskLBFat dw        0                        ; poá†teán° sektor FAT
DskLNFat db        0                        ; poáet tabulek FAT
DskLSFat dw        0                        ; poáet sektorñ na jednu FAT
DskLCFat dw        0                        ; poáet sektorñ na FAT celkem

DskLBRot dw        0                        ; poá†teán° sektor ROOT
DskLNRot dw        0                        ; poáet poloëek ROOT
DskLSRot dw        0                        ; poáet sektorñ ROOT

DskLBDat dw        0                        ; poá†teán° datovò sektor

; ------ buffer tabulky FAT (obsahuje 2 sektory)

DskLFatS dw        0                        ; segment bufferu tabulky FAT
DskLFatA dw        0                        ; relativn° á°slo sektoru v buf.FAT

; ------ obsluha p©°stupu k adres†©ñm logickÇho disku

DskLDirS dw        0                        ; segment bufferu sektoru adres†©e
DskLDirN dw        3                        ; dÇlka textu adres†©e

DskLDir0 db        0                        ; dÇlka textu adres†©e (po©ad° !)
DskLDir  label     byte
         db        'A:\',FileMax+15 dup(0)  ; buffer aktivn°ho adres†©e

DskLDirM dw        DskLDirT                 ; adresa posledn° poloëky adres†©e
DskLDirT label     word
         dw        DirMax+1 dup(0,0,0,0)    ; tabulka ©etàzce adres†©e
                                            ;   0: (2) poá†teán° alokaán° blok
                                            ;   2: (2) aktu†ln° alokaán° blok
                                            ;   4: (2) á°slo sektoru v bloku
                                            ;   6: (2) offset poloëky v sektoru
                                            ;           (-32=bude prvn° poloëka)
                                            ;           (-64=poloëka neplatn†)

; ------ paket pro p©°stup na disk

DskLPak  label     byte
DskLPakS dd        0                        ; á°slo sektoru
DskLPakN dw        1                        ; poáet sektorñ
DskLPakA dd        0                        ; adresa bufferu

; ------ buffery pro p©°stup k CD (pozor - velikosti natvrdo v programu !)

PozadCD  label     byte
         db        30 dup (?)               ; poëadavek na ovladaá CD-ROM
ZahlCD   label     byte
         db        30 dup (?)               ; z†hlav° p©°stupu k za©°zen° CD

Data     ENDS

         END

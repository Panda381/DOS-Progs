
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      Prohl°ëeá souborñ n†povàdy
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

BUFFSIZE EQU       2000h                    ; velikost vstupn°ho bufferu
MAXFND   EQU       15                       ; maxim†ln° dÇlka textu k hled†n°

; ------ definice k¢dovac° tabulky

MAXLENX  EQU       25                       ; min. dÇlka dlouhÇho ©etàzce
MAXLEN   EQU       MAXLENX+254              ; maxim†ln° dÇlka ©etàzce

SUBSTLEN EQU       7                        ; dÇlka nahrazen† dlouhòm k¢dem


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zmen®en° bloku programu na minimum

Start:   mov       dx,offset MemTxt         ; chyba - nedostatek pamàti
         cmp       sp,offset Zasob          ; je pamàü OK ?
         jb        Start3                   ; chyba pamàti
         mov       sp,offset Zasob          ; p©edefinov†n° ukazatele z†sobn°ku
         mov       bx,offset(ViewEnd-Start+10fh)/16 ; konec programu
         mov       ah,4ah
         int       21h                      ; zmen®en° velikosti bloku programu
         jc        Start3                   ; nepravdàpodobn† chyba

; ------ vytvo©en° vstupn°ho bufferu

         mov       bx,BUFFSIZE/16           ; velikost vstupn°ho bufferu
         mov       ah,48h
         int       21h                      ; vytvo©en° vstupn°ho bufferu
         jc        Start3                   ; chyba - nedostatek pamàti
         mov       ds:[InpSegm],ax          ; adresa vstupn°ho bufferu

; ------ vytvo©en° datovÇho bufferu

         mov       ah,48h
         mov       bx,0ffffh                ; velikost bufferñ
         int       21h                      ; vytvo©en° datovÇho bufferu
         mov       ah,48h
         int       21h                      ; vytvo©en° men®°ho bufferu
         jc        Start3                   ; nedostatek pamàti

; ------ inicializace ukazatelñ bufferñ

         cmp       bx,8                     ; minim†ln° velikost pamàti
         jb        Start3                   ; chyba - nedostatek pamàti
         mov       ds:[DatSegm],ax          ; adresa datovÇho segmentu
         mov       word ptr ds:[TopADr+2],ax ; adresa poá†teán°ho ©†dku
         mov       ds:[DatSize],bx          ; velikost datovÇho bufferu
         mov       dx,bx                    ; velikost datovÇho bufferu
         and       dx,0f000h                ; maxim†ln° segment
         add       dx,ax                    ; maxim†ln° segment
         mov       cl,4                     ; poáet rotac°
         shl       bx,cl                    ; maxim†ln° offset
         mov       ds:[MaxOffs],bx          ; maxim†ln° offset
         mov       ds:[MaxSegm],dx          ; maxim†ln° segment

; ------ inicializace konfiguraán°ho souboru

         call      InitCNF                  ; inicializace konfigurace

; ------ rozbor p©°kazovÇho ©†dku

         call      Rozbor                   ; rozbor p©°kazovÇho ©†dku
         jnc       Start4                   ; zad†n° OK

; ------ chyba zad†n°

Start2:  mov       dx,offset HelpTxt        ; text n†povàdy
Start3:  push      cs
         pop       ds
         push      dx
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h
         pop       dx
         mov       ah,9
         int       21h                      ; zobrazen° n†povàdy
         int       20h                      ; konec textu

; ------ otev©en° vstupn°ho souboru

Start4:  mov       dx,offset Soubor1        ; jmÇno vstupn°ho souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
Start62: mov       dx,offset SoubTxt
         jc        Start3                   ; chyba - soubor nenalezen
         mov       ds:[SoubIdnt],ax         ; identifik†tor souboru

; ------ £schova data a áasu souboru

         mov       bx,ax                    ; identifik†tor souboru
         mov       ax,5700h
         int       21h                      ; poskytnut° data a áasu souboru
         mov       ds:[FileDate],dx         ; datum souboru
         mov       ds:[FileTime],cx         ; áas souboru

; ------ £schova atributñ souboru

         mov       ax,4300h
         mov       dx,offset Soubor1        ; jmÇno souboru
         int       21h                      ; poskytnut° atributñ souboru
         mov       ds:[FileAtr],cx          ; atributy souboru

; ------ test, zda je zkomprimovanò soubor

         mov       es,ds:[DatSegm]          ; datovò segment
         xor       di,di                    ; ukl†dac° adresa do bufferu
         mov       ds,ds:[InpSegm]          ; segment vstupn°ho bufferu
         xor       si,si                    ; átec° adresa z bufferu
         cld                                ; smàr nahoru

         call      ReadByte                 ; naáten° bajtu
         cmp       dh,27                    ; prvn° identifikaán° bajt
         jne       Start7                   ; nen° komprimovanò soubor

         call      ReadByte                 ; naáten° bajtu
         cmp       dh,"X"                   ; druhò identifikaán° bajt
         jne       Start7                   ; nen° komprimovanò soubor

         call      ReadByte                 ; naáten° bajtu
         cmp       dh,"C"                   ; t©et° identifikaán° bajt
         jne       Start7                   ; nen° komprimovanò soubor

         call      ReadByte                 ; naáten° bajtu
         cmp       dh,"D"                   ; átvrtò identifikaán° bajt
         je        Start8                   ; je komprimovanò soubor OK

; ------ nen° komprimace - naáten° souboru

Start7:  ;or        byte ptr cs:[Prepin],3   ; je k¢d IBM
         xor       si,si                    ; zaá†tek dat v souboru
Start71: call      ReadByte                 ; naáten° bajtu
         jz        Start9                   ; konec souboru
         call      WritByte                 ; uloëen° do bufferu
         jnz       Start71                  ; dal®° bajt
         jmp       short Start86            ; soubor nen° naáten celò

; ------ dekomprese dat

Start8:  call      ReadByte
         jz        Start9
         mov       byte ptr cs:[Prepin],dh
         call      ReadByte
         jz        Start9
         mov       byte ptr cs:[Prepin+1],dh

         call      ZadHesl                  ; p©°padnÇ zad†n° hesla
         jnc       Start82
         int       20h                      ; p©eru®en° programu

Start82: call      DeKomp                   ; dekomprese dat

; ------ test, zda je jië konec souboru

Start88: call      ReadByte                 ; test, zda je dal®° bajt
         jz        Start9                   ; je konec souboru - OK

; ------ soubor nebyl naáten celò

Start86: push      cs
         pop       ds
         mov       dx,offset CelyTxt
         mov       ah,9
         int       21h                      ; zobrazen° chybovÇho hl†®en°
         mov       ax,0c01h
         int       21h                      ; áek†n° na zad†n° kl†vesy

; ------ nastaven° ukazatele konce dat v bufferu

Start9:  push      cs
         pop       ds
         mov       word ptr ds:[MaxOffs],di ; maxim†ln° offset v bufferu
         mov       word ptr ds:[MaxSegm],es ; maxim†ln° segment v bufferu

; ------ test, zda byl vòstupn° soubor zad†n

         test      byte ptr ds:[Param],8    ; byl vòstupn° soubor zad†n ?
         jnz       View201                  ; vòstupn° soubor byl zad†n

; ------ odstranàn° koncovÇho EOF souboru

         or        di,di                    ; jsou nàjak† data ?
         jz        View2                    ; je poá†tek segmentu
         dec       di                       ; adresa posledn°ho bajtu
         cmp       byte ptr es:[di],26      ; je EOF ?
         jne       View2                    ; nen° EOF
         mov       word ptr ds:[MaxOffs],di ; odstranàn° EOF z bufferu
View2:   jmp       View21

; ------ test, zda vòstupn° soubor jië existuje

View201: mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         mov       ax,3d02h
         int       21h                      ; test, zda soubor existuje
         jc        View204                  ; neexistuje
         mov       si,dx                    ; jmÇno souboru

; ------ vòstupn° soubor existuje

         mov       bx,ax                    ; identifik†tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

         mov       dx,offset Exis1Txt
         mov       ah,9
         int       21h                      ; text "Vystupni soubor"

View2031:cld
         lodsb
         cmp       al,0
         je        View2032
         mov       dl,al
         mov       ah,2
         int       21h
         jmp       short View2031

View2032:mov       dx,offset Exis2Txt
         mov       ah,9
         int       21h

         mov       ah,1
         int       21h

         call      UpCase                   ; konverze na velkÇ p°smeno

         push      ax
         mov       dx,offset CRTxt
         mov       ah,9
         int       21h
         pop       ax

         cmp       al,"A"
         je        View204

         int       20h

; ------ otev©en° vòstupn°ho souboru

View204: mov       dx,offset Soubor2        ; jmÇno souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en° vòstupn°ho souboru
         jnc       View206                  ; operace OK

         mov       dx,offset VystTxt
View205: jmp       Start3                   ; chyba

; ------ z†pis souboru na disk

View206: mov       bx,ax                    ; identifik†tor souboru

         mov       si,ds:[MaxSegm]          ; maxim†ln° segment
         sub       si,ds:[DatSegm]          ; velikost v segmentech
         xor       di,di
         shl       si,1
         rcl       di,1
         shl       si,1
         rcl       di,1
         shl       si,1
         rcl       di,1
         shl       si,1
         rcl       di,1
         add       si,ds:[MaxOffs]
         adc       di,0                     ; DI:SI=á°taá dat k z†pisu

         mov       bp,ds:[DatSegm]

View207: mov       cx,0f000h
         or        di,di
         jnz       View208
         cmp       cx,si
         jbe       View208
         mov       cx,si                    ; omezen° velikosti

View208: xor       dx,dx
         mov       ah,40h
         mov       ds,bp
         int       21h                      ; z†pis bloku na disk
         mov       dx,offset WritTxt        ; text - chyba z†pisu
         jc        View205                  ; chyba z†pisu
         cmp       ax,cx
         jne       View205                  ; chyba - disk plnò

         add       bp,0f00h
         sub       si,0f000h
         sbb       di,0
         jnc       View207

         push      cs
         pop       ds

; ------ nastaven° data a áasu souboru

         mov       ax,5701h
         mov       dx,ds:[FileDate]         ; datum souboru
         mov       cx,ds:[FileTime]         ; áas souboru
         int       21h                      ; nastaven° data a áasu souboru

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21H

; ------ nastaven° atributñ souboru

         mov       dx,offset Soubor2        ; jmÇno souboru
         mov       cx,ds:[FileAtr]          ; pñvodn° atributy souboru
         mov       ax,4301h
         int       21h                      ; nastaven° atributñ souboru

         int       20h




; ------ inicializace videom¢du

View21:  mov       ah,0fh
         int       10h
         cmp       al,7
         je        View22
         mov       word ptr ds:[AdrVRAM+3],0b8h
         mov       byte ptr ds:[Barva],1bh  ; barva - barevnò videom¢d
         mov       byte ptr ds:[Barva1],30h ; barva nadpisu
         mov       byte ptr ds:[Barva2],30h ; barva nadpisu
         cmp       al,2
         je        View23
         cmp       al,3
         je        View23
         mov       al,3
View22:  mov       ah,0
         int       10h                      ; inicializace videom¢du

; ------ stanoven° parametrñ videom¢du

View23:  mov       ah,12h
         mov       bx,0c310h
         int       10h                      ; test, zda je karta EGA/VGA

         push      ds
         xor       ax,ax
         mov       ds,ax

         cmp       bh,2
         ja        View25                   ; nen° EGA/VGA
         cmp       bl,5
         ja        View25
         mov       bl,ds:[484h]             ; posledn° ©†dek na displeji
         cmp       bl,15                    ; je je®tà rozumnÇ á°slo ©†dku ?
         jb        View25                   ; neplatnò poáet ©†dkñ
         mov       cs:[MaxRow],bl           ; posledn° ©†dek na displeji
         inc       bx
         mov       cs:[Radku],bl            ; poáet ©†dkñ displeje
View25:  mov       ax,ds:[44eh]             ; adresa videostr†nky
         pop       ds
         mov       word ptr ds:[AdrVRAM],ax ; adresa videopamàti

; ------ £schova á°sla aktivn° str†nky

         mov       ah,0fh
         int       10h                      ; poskytnut° videostr†nk
         mov       ds:[AktPage],bh          ; aktivn° videostr†nka

; ------ definice INT 23h a INT 24h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h
         mov       dx,offset INT24
         mov       ax,2524h
         int       21h

; ------ zmen®en° velikosti datovÇho bloku

         mov       cl,4
         mov       es,ds:[DatSegm]          ; datovò segment
         mov       ax,ds:[MaxOffs]          ; maxim†ln° offset
         add       ax,0fh
         shr       ax,cl                    ; p©epoáet na odstavce
         mov       bx,ds:[MaxSegm]          ; maxim†ln° segment
         sub       bx,ds:[DatSegm]          ; poáet blokñ 64 KB
         add       bx,ax                    ; velikost datovÇho bloku
         mov       ah,4ah
         int       21h                      ; zmen®en° velikosti dat. bloku

; ------ vytvo©en° datovÇho bloku displeje

         mov       al,160
         mul       byte ptr ds:[Radku]      ; poáet ©†dkñ na displej
         add       ax,0fh
         shr       ax,cl                    ; velikost bloku v odstavc°ch
         jnz       View27
         mov       ax,0ffffh
View27:  mov       bx,ax
         mov       ah,48h
         int       21h                      ; vytvo©en° datovÇho bloku
         mov       word ptr ds:[InpNum],0   ; p©ednastaven° - nic nen°
         jnc       View28
         mov       ah,48h
         int       21h                      ; druhò pokus
         jc        View29                   ; ani tak se nepovedlo
View28:  mov       ds:[InpSegm],ax          ; adresa segmentu
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; velikost ve slovech
         mov       cx,bx
         mov       word ptr ds:[InpNum],bx  ; velikost ve slovech

; ------ £schova obsahu obrazovky

         push      ds
         mov       es,ax                    ; adresa segmentu
         xor       di,di                    ; zaá†tek bufferu
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds

; ------ £schova pozice kurzoru

View29:  mov       ah,3
         call      Int10P                   ; áten° pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ inicializace konverzn°ch tabulek

         call      InitTab                  ; prvn° inicializace tabulek

; ------ zobrazen° nadpisu

View30:

; ------ zobrazen° aktivn° str†nky

View3:
         call      DispUkaz                 ; zobrazen° ukazatele polohy v soub.

         call      DispNadp                 ; zobrazen° nadpisu

         call      Disp                     ; zobrazen° aktivn° str†nky
         call      KurzOff                  ; vypnut° kurzoru

; ------ obsluha kl†vesnice

View32:  mov       ah,0
         int       16h                      ; áek†n° na stisk kl†vesy
         cmp       al,0
         je        View33
         mov       ah,0
View33:  or        ax,ax
         jz        INT23                    ; p©eru®en° Ctrl-Break
         cmp       al,27
         je        INT23                    ; kone ESC

; ------ skok na funkci

         mov       di,offset TabKey
         mov       cx,offset(TabKey0-TabKey)/4
View4:   cmp       ax,ds:[di]
         je        View5
         add       di,4
         loop      View4
         jmp       short View32

View5:   mov       si,word ptr ds:[TopADr]  ; adresa str†nky - offset
         mov       dx,word ptr ds:[TopAdr+2] ; adresa str†nky - segment
         mov       bp,ds:[TopLine]          ; á°slo poá†teán°ho ©†dku str†nky
         mov       bx,ds:[RadkuTxt]         ; poáet ©†dkñ celkem
         sub       bx,1                     ; á°slo posledn°ho ©†dku
;         sub       bx,ds:[DispRow]          ; á°slo posledn°ho ©†dku
         jnc       View53
         xor       bx,bx                    ; á°slo posledn°ho ©†dku
View53:  call      word ptr ds:[di+2]       ; obsluha funkce kl†vesy
         mov       word ptr ds:[TopAdr+2],dx ; adresa str†nky - segment
         mov       word ptr ds:[TopAdr],si  ; adresa str†nky - offset
         mov       ds:[TopLine],bp          ; novÇ á°slo prvn°ho ©†dku str†nky
         jmp       short View3

; ------ vymaz†n° videostr†nky

INT23:   push      cs
         pop       ds
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       byte ptr ds:[Radku]      ; poáet znakñ na videostr†nku
         mov       cx,ax                    ; poáet znakñ na videostr†nku
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       ax,720h                  ; mazac° slovo
         cld
         rep       stosw                    ; vymaz†n° obrazovky

; ------ navr†cen° obsahu obrazovky

         push      ds
         mov       di,word ptr ds:[AdrVRAM] ; adresa videopamàti
         mov       cx,ds:[InpNum]           ; poáet slov v bufferu
         mov       ds,ds:[InpSegm]          ; adresa segmentu
         cld
         xor       si,si                    ; zaá†tek bufferu
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds

; ------ nastaven° pozice kurzoru

         mov       dx,ds:[OldKurz]          ; pñvodn° pozice kurzoru
         mov       ah,2
         call      Int10P                   ; nastaven° pozice kurzoru

         call      StorCNF                  ; £schova konfigurace

         int       20h

INT24    PROC      FAR

         mov       al,0
         iret

INT24    ENDP

; -----------------------------------------------------------------------------
;        inicializace konfigurace
; -----------------------------------------------------------------------------
;˛
InitCNF  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kontrola verze systÇmu

         push      ds
         pop       es
         mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         mov       di,offset HLPBuff        ; buffer jmÇna souboru
         cmp       al,3
         jb        InitCNF6                 ; je n°zk† verze systÇmu

; ------ adresa prost©ed°

         push      ds
         mov       cx,ds:[2ch]              ; segment prost©ed°
         jcxz      InitCNF5                 ; neplatnÇ prost©ed°
         mov       ds,cx                    ; segment prost©ed°

; ------ nalezen° textu cesty

         xor       si,si                    ; zaá†tek prost©ed°
         mov       cx,7fffh                 ; max. dÇlka prost©ed°
         xor       ax,ax                    ; hledanÇ slovo
InitCNF2:inc       si                       ; zvò®en° ukazatele v prost©ed°
         cmp       word ptr ds:[si-1],ax    ; je konec prost©ed° ?
         loopne    InitCNF2                 ; dal®° bajt prost©ed°

; ------ p©enesen° textu cesty

         add       si,3                     ; zaá†tek textu cesty
         cld
InitCNF3:mov       dx,di                    ; £schova adresy k uloëen° jmÇna
InitCNF4:lodsb                              ; naáten° znaku
         stosb                              ; uloëen° znaku
         cmp       al,"\"                   ; byl to oddàlovaá cesty ?
         je        InitCNF3                 ; byl oddàlovaá cesty - £schova
         cmp       al,0                     ; konec textu ?
         jne       InitCNF4                 ; dal®° znak
         mov       di,dx                    ; adresa k uloëen° jmÇna souboru
InitCNF5:pop       ds

; ------ p©id†n° jmÇna souboru

InitCNF6:mov       si,offset HLPName        ; jmÇno souboru
         mov       cx,8                     ; dÇlka jmÇna souboru
         cld
         rep       movsb                    ; p©id†n° jmÇna souboru

; ------ otev©en° souboru

         mov       dx,offset HLPBuff        ; jmÇno souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° pro áten°
         jc        InitCNF7                 ; soubor nen°
         mov       bx,ax                    ; identifik†tor souboru

; ------ naáten° konfiguraán°ho souboru

         mov       dx,offset HLPCnf0        ; konfiguraán° buffer
         mov       cx,offset(HLPCnf0-HLPCnf) ; dÇlka konfigurace
         mov       ah,3fh
         int       21h                      ; naáten° souboru do bufferu

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ kontrola, zda je to platnò soubor

InitCNF7:mov       si,offset HLPCnf         ; vzorek
         mov       di,offset HLPCnf0        ; naátenò soubor
         mov       cx,7                     ; dÇlka z†hlav°
         cld
         repe      cmpsb                    ; porovn†n° z†hlav° souboru

; ------ £schova souboru nebo plat° starò soubor

         mov       si,offset HLPCnf         ; star† konfigurace
         mov       di,offset HLPCnf0        ; nov† konfigurace
         mov       cx,offset(HLPCnf0-HLPCnf) ; dÇlka konfigurace
         jne       InitCNF8                 ; soubor nen° platnò
         xchg      si,di                    ; jinak se uschov† nov† konfigurace
InitCNF8:rep       movsb                    ; zdvojen° konfigurace


; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitCNF  ENDP

; -----------------------------------------------------------------------------
;        uloëen° konfigurace
; -----------------------------------------------------------------------------

StorCNF  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kontrola, zda byla konfigurace zmànàna

         push      ds
         pop       es
         mov       si,offset HLPCnf         ; souáasn† konfigurace
         mov       di,offset HLPCnf0        ; star† konfigurace
         mov       cx,offset(HLPCnf0-HLPCnf) ; dÇlka konfigurace
         cld
         repe      cmpsb                    ; porovn†n° konfigurac°
         je        StorCNF9                 ; nebyla zmànàna

; ------ vytvo©en° konfiguraán°ho souboru

         mov       dx,offset HLPBuff        ; buffer jmÇna souboru
         xor       cx,cx
         mov       ah,3ch
         int       21h                      ; vytvo©en° souboru
         jc        StorCNF9                 ; soubor nelze vytvo©it
         mov       bx,ax                    ; identifik†tor souboru

; ------ z†pis konfigurace do souboru

         mov       cx,offset(HLPCnf0-HLPCnf) ; dÇlka konfigurace
         mov       dx,offset HLPCnf         ; souáasn† konfigurace
         mov       ah,40h
         int       21h                      ; uloëen° konfigurace

; ------ uzav©en° souboru

         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ n†vrat registrñ

StorCNF9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

StorCNF  ENDP

; *****************************************************************************
;
;                        Ovl†d†n° programu
;
; *****************************************************************************

TabKey   dw        5000h,Dolu               ; kurzor dolñ
         dw        4800h,Nahoru             ; kurzor nahoru
         dw        5100h,PgDn               ; str†nka dolñ
         dw        4900h,PgUp               ; str†nka nahoru
         dw        4f00h,EndK               ; konec textu
         dw        4700h,Home               ; zaá†tek textu
         dw        0020h,EnterK             ; MEZERA filtr
         dw        000dh,Hledej             ; ENTER hled†n°
         dw        000ch,HledC              ; ^L hled†n° d†le
         dw        3c00h,FKam               ; F2 filtr Kamenickòch
         dw        3d00h,FLat               ; F3 filtr Latin 2
         dw        3e00h,FKOI               ; F4 filtr KOI 8
         dw        3f00h,Blok               ; F5 z†pis bloku na disk
         dw        4000h,Tisk               ; F6 tisk bloku na tisk†rnu
         dw        3b00h,Napov              ; F1 n†povàda
         dw        4b00h,Vlevo              ; kurzor vlevo
         dw        4d00h,Vpravo             ; kurzor vpravo
         dw        7300h,CVlevo             ; ^kurzor vlevo
         dw        7400h,CVpravo            ; ^kurzor vpravo

TabKey0  label     word

; -----------------------------------------------------------------------------
;        z†pis bloku na disk, tisk na tisk†rnu
; -----------------------------------------------------------------------------
;˛
Tisk:    or        byte ptr ds:[Param],4    ; p©°znak tisku
         jmp       short Blok101


Blok     PROC      NEAR

; ------ £schova registrñ

;         push      si                       ; adresa str†nky - offset
;         push      dx                       ; adresa str†nky - segment
;         push      bp                       ; á°slo prvn°ho ©†dku str†nky
         and       byte ptr ds:[Param],not 4 ; zru®en° p©°znaku tisku

Blok101: push      di
         push      word ptr ds:[FindAdr]
         push      word ptr ds:[FindAdr+2]
         push      word ptr ds:[FindLine]

; ------ nastaven° kurzoru asi tak do st©edu obrazovky

         mov       cx,ds:[DispRow]
         shr       cx,1                     ;
Blok1:   call      NextLine                 ; nalezen° dal®°ho ©†dku
         loop      BLok1

; ------ oznaáen° zaá†tku bloku

         mov       di,offset ZacTxt         ; vòzva k oznaáen° zaá†tku bloku
         call      BlokF                    ; obsluha kurzoru bloku
         jc        Blok9                    ; p©eru®en° operace

; ------ £schova parametrñ zaá†tku bloku

         mov       word ptr ds:[Blok1Adr],si
         mov       word ptr ds:[Blok1Adr+2],dx
         mov       ds:[Blok1Lin],bp
         or        byte ptr ds:[Param],20h  ; p©°znak zobrazen° bloku

; ------ oznaáen° konce bloku

         mov       di,offset KonTxt         ; vòzva k oznaáen° konce bloku
         call      BlokF                    ; obsluha kurzoru bloku
         jc        Blok9                    ; p©eru®en° operace

; ------ uloëen° bloku na disk

         call      UlozBlk                  ; uloëen° bloku na disk

; ------ n†vrat registrñ

Blok9:   and       byte ptr ds:[Param],not 20h ; zru®en° p©°znaku zobraz. bloku
         pop       word ptr ds:[FindLine]
         pop       word ptr ds:[FindAdr+2]
         pop       word ptr ds:[FindAdr]
         pop       di
         mov       si,word ptr ds:[TopAdr]
         mov       dx,word ptr ds:[TopAdr+2]
         mov       bp,ds:[TopLine]
;         pop       bp
;         pop       dx
;         pop       si
         ret

Blok     ENDP

; -----------------------------------------------------------------------------
;        obsluha kurzoru bloku (DI=text k zobrazen°, CY=p©eru®en° ESC)
; -----------------------------------------------------------------------------

BlokF    PROC      NEAR

         call      DispHlas                 ; zobrazen° hl†®en°

; ------ áek†n° na stisk kl†vesy

BlokF1:  mov       word ptr ds:[Blok2Adr],si ; oznaáen° konce bloku
         mov       word ptr ds:[Blok2Adr+2],dx
         mov       ds:[Blok2Lin],bp
         call      HledNrm0                 ; uloëen° a normalizace parametrñ
         call      Disp                     ; zobrazen° aktivn° str†nky
         call      KurzOff                  ; vypnut° kurzoru
         mov       ah,0
         int       16h

; ------ p©eru®en° operace ESC, Ctrl-BREAK

         or        ax,ax
         jz        BlokF2                   ; p©eru®en° Ctrl-BREAK
         cmp       al,27
         jne       BlokF4                   ; nen° p©eru®en°
BlokF2:  stc                                ; p©°znak p©eru®en° operace
BLokF3:  ret

; ------ ukonáen° volby ENTER

BlokF4:  cmp       al,0dh
         je        BlokF3                   ; ukonáen° volby ENTER

; ------ posun kurzoru dolñ

         cmp       ax,5000h
         jne       BlokF5                   ; nen° kurzor dolñ
         call      NextLine                 ; nalezen° dal®°ho ©†dku

; ------ posun kurzoru nahoru

BlokF5:  cmp       ax,4800h
         jne       BlokF6                   ; nen° kurzor nahoru
         call      PredLine                 ; nalezen° p©edchoz°ho ©†dku

; ------ posun o str†nku dolñ

BlokF6:  cmp       ax,5100h
         jne       BlokF7                   ; nen° str†nka dolñ
         mov       cx,ds:[DispRow]          ; poáet zobrazenòch ©†dkñ
         dec       cx                       ; o 1 ©†dek mÇnà
BlokF62: call      NextLine                 ; posun o ©†dek dolñ
         loop      BlokF62                  ; posun o dal®° ©†dek

; ------ posun o str†nku nahoru

BlokF7:  cmp       ax,4900h
         jne       BlokF8                   ; nen° str†nka nahoru
         mov       cx,ds:[DispRow]          ; poáet zobrazenòch ©†dkñ
         dec       cx                       ; o 1 ©†dek mÇnà
BlokF72: call      PredLine                 ; posun o ©†dek nahoru
         loop      BlokF72

; ------ konec textu

BlokF8:  cmp       ax,4f00h
         jne       BlokF9
         call      HledZap
BlokF82: call      NextLine
         jnc       BlokF82
         call      HledVyp

; ------ zaá†tek textu

BlokF9:  cmp       ax,4700h
         jne       BlokF1
         call      HledZap
BlokF92: call      PredLine
         jnc       BlokF92
         call      HledVyp
         jmp       short BlokF1

BlokF    ENDP

; -----------------------------------------------------------------------------
;        uloëen° bloku na disk
; -----------------------------------------------------------------------------

UlozBlk  PROC      NEAR

; ------ test, zda je nàjakò ©†dek

         cmp       word ptr ds:[RadkuTxt],0 ; je alespo§ 1 ©†dek ?
         jne       UlozBlk1                 ; je alespo§ 1 ©†dek textu
         ret                                ; jinak se nic neukl†d†

; ------ zobrazen° textu vòzvy

UlozBlk1:mov       di,offset ZapisTxt
         test      byte ptr ds:[Param],4    ; je tisk ?
         jz        UlozBl11                 ; nen° tisk
         mov       di,offset TiskTxt
UlozBl11:call      DispHlas

; ------ otev©en° souboru pro z†pis

         mov       dx,offset BlokSoub
         test      byte ptr ds:[Param],4    ; je tisk ?
         jz        UlozBl13
         mov       dx,offset BlokTisk
UlozBl13:mov       ax,3d01h                 ; otev©en° pro z†pis
         int       21h                      ; otev©en° souboru pro z†pis
         jnc       UlozBlk2                 ; soubor £spà®nà otev©en
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en° novÇho souboru
         jnc       UlozBlk2
         jmp       UlozBlk7                 ; chyba - soubor nelze vytvo©it
UlozBlk2:mov       bx,ax                    ; identifik†tor souboru

; ------ vystaven° ukazatele na konec souboru

         test      byte ptr ds:[Param],4
         jnz       UlozBl22
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h                      ; vystaven° ukazatele na konec soub.

; ------ stanoven° poá†tku bloku a poáet ©†dkñ k z†pisu

UlozBl22:mov       si,word ptr ds:[Blok1Adr] ; offset poá†tku
         mov       dx,word ptr ds:[Blok1Adr+2] ; segment poá†tku
         mov       bp,ds:[Blok1Lin]         ; ©†dek poá†tku
         mov       cx,ds:[Blok2Lin]         ; ©†dek konce
         sub       cx,bp                    ; poáet ©†dkñ k z†pisu - 1
         jae       UlozBlk3                 ; konec je za zaá†tkem OK
         neg       cx                       ; oprava rozd°lu ©†dkñ
         mov       si,word ptr ds:[Blok2Adr] ; offset poá†tku
         mov       dx,word ptr ds:[Blok2Adr+2] ; segment poá†tku
         mov       bp,ds:[Blok2Lin]         ; ©†dek poá†tku
UlozBlk3:inc       cx                       ; + 1 ©†dek

; ------ £schova registrñ p©ed z†pisem

UlozBlk4:push      cx                       ; á°taá ©†dkñ
         push      si                       ; offset ©†dku
         push      dx                       ; segment ©†dku
         push      ds                       ; datovò segment

; ------ normalizace adresy poá†tku ©†dku

         mov       di,si                    ; £schova offset poá†tku ©†dku
         mov       ax,si                    ; offset poá†tku ©†dku
         and       si,0fh                   ; offset v odstavci
         mov       cl,4                     ; poáet rotac°
         shr       ax,cl                    ; p©evod offsetu na segment
         add       dx,ax                    ; segment adresy
         mov       ds,dx                    ; segment adresy ©†dku
         mov       dx,si                    ; offset poá†tku ©†dku

; ------ dÇlka posledn°ho ©†dku

         mov       cx,cs:[MaxOffs]          ; offset konce bufferu
         sub       cx,di                    ; dÇlka p©°padnÇho posledn°ho ©†dku
         inc       bp                       ; zvò®en° á°sla ©†dku
         cmp       bp,cs:[RadkuTxt]         ; je to posledn° ©†dek ?
         je        UlozBl55                 ; je to posledn° ©†dek

; ------ nalezen° konce ©†dku

         xor       cx,cx                    ; á°taá dÇlky ©†dku
         mov       ah,10                    ; hledanò znak LF
         cld
UlozBlk5:inc       cx                       ; zvò®en° á°taáe dÇlky ©†dku
         jnz       UlozBl52
         dec       cx                       ; n†vrat 0ffffh p©i p©eteáen°
UlozBl52:lodsb                              ; naáten° znaku z ©†dku
         cmp       al,ah                    ; je to konec ©†dku ?
         jne       UlozBlk5                 ; nen° konec - dal®° znak

; ------ z†pis ©†dku do souboru

UlozBl55:dec       bp                       ; n†vrat á°sla ©†dku
         mov       ah,40h
         int       21h                      ; z†pis ©†dku do souboru
         jc        UlozBl58                 ; chyba z†pisu ©†dku
         cmp       ax,cx                    ; bylo zaps†no v®e OK ?

; ------ n†vrat registrñ po z†pisu

UlozBl58:pop       ds
         pop       dx
         pop       si
         pop       cx
         jc        UlozBlk6                 ; byla chyba z†pisu

; ------ test p©eru®en° operace

         mov       ah,1
         int       16h
         or        ax,ax
         jz        UlozBlk6                 ; p©eru®en° Ctrl-Break
         cmp       al,1bh
         je        UlozBlk6                 ; p©eru®en° ESC

; ------ p©°prava pro dal®° ©†dek

         call      NextLine                 ; adresa dal®°ho ©†dku
         loop      UlozBlk4                 ; z†pis dal®°ho ©†dku
         clc                                ; operace probàhla OK

; ------ uzav©en° souboru

UlozBlk6:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ vypr†zdnàn° bufferu kl†vesnice

UlozBl62:mov       ah,1
         int       16h
         jz        UlozBl64
         mov       ah,0
         int       16h
         jmp       short UlozBl62
UlozBl64:popf
         jnc       UlozBlkA                 ; operace probàhla OK

; ------ chyba z†pisu

UlozBlk7:mov       di,offset ZapErTxt
         test      byte ptr ds:[Param],4
         jz        UlozBl72
         mov       di,offset TiskETxt
UlozBl72:call      DispHlas
UlozBlk8:mov       ah,1
         int       16h
         jz        UlozBlk9
         mov       ah,0
         int       16h
         jmp       short UlozBlk8
UlozBlk9:mov       ah,0
         int       16h
UlozBlkA:ret

UlozBlk  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hl†®en° DS:DI
; -----------------------------------------------------------------------------

DispHlas PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ zobrazen° hl†®en°

         mov       si,di                    ; adresa textu hl†®en°
         mov       ah,ds:[Barva2]           ; barva nadpisu
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       cx,80                    ; dÇlka textu
         call      DispAsc                  ; zobrazen° textu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DispHlas ENDP

; -----------------------------------------------------------------------------
;        n†povàda
; -----------------------------------------------------------------------------

Napov    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       si,offset MHelpTxt       ; text n†povàdy
         mov       dx,offset(MHelpTx1-MHelpTxt)/offset(MHelpTx1-MHelpTx0)
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       ah,ds:[MaxRow]
         sub       ah,offset(MHelpTx1-MHelpTxt)/offset(MHelpTx1-MHelpTx0)
         shr       ah,1                     ; poá†teán° ©†dek
         inc       ah
         mov       al,160                   ; bajtñ na ©†dek
         mul       ah                       ; offset ©†dku
         add       di,ax                    ; ©†dek
         add       di,(80-offset(MHelpTx1-MHelpTx0)) AND not 1 ; pozice
         mov       ah,ds:[Barva3]           ; barva n†povàdy

; ------ rozli®en° KOI 8

         mov       bh,0
         mov       al,ds:[ParamC]
         and       al,3
         cmp       al,2                     ; je KOI 8 ?
         je        Napov4                   ; je KOI 8

; ------ zobrazen° textu n†povàdy

         cld
Napov2:  push      di
         mov       cx,offset(MHelpTx1-MHelpTx0) ; dÇlka jednoho ©†dku
Napov3:  lodsb
         stosw
         loop      Napov3
         mov       byte ptr es:[di+160+3],7
         mov       byte ptr es:[di+160+1],7
         pop       di
         add       di,160
         dec       dx                       ; á°taá ©†dkñ
         jnz       Napov2                   ; dal®° ©†dek
         jmp       short Napov8

; ------ je k¢d KOI 8

Napov4:  push      di
         mov       cx,offset(MHelpTx1-MHelpTx0) ; dÇlka jednoho ©†dku
Napov5:  lodsb
         cmp       al,128
         jb        Napov6
         mov       bl,al
         mov       al,ds:[bx+TbKamKOI-128]
Napov6:  stosw
         loop      Napov5
         mov       byte ptr es:[di+160+3],7
         mov       byte ptr es:[di+160+1],7
         pop       di
         add       di,160
         dec       dx                       ; á°taá ©†dkñ
         jnz       Napov4                   ; dal®° ©†dek

; ------ st°n

Napov8:  mov       cx,offset(MHelpTx1-MHelpTx0)-2
Napov9:  mov       byte ptr es:[di+5],7
         inc       di
         inc       di
         loop      Napov9

; ------ áek†n° na stisk kl†vesy

         mov       ah,0
         int       16h

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Napov    ENDP

; -----------------------------------------------------------------------------
;        filtr Kamenickòch
; -----------------------------------------------------------------------------

FKam     PROC      NEAR

         and       byte ptr ds:[ParamC],not 7
         jmp       short EnterK2

FKam     ENDP

; -----------------------------------------------------------------------------
;        filtr Latin 2
; -----------------------------------------------------------------------------

FLat     PROC      NEAR

         and       byte ptr ds:[ParamC],not 7
         or        byte ptr ds:[ParamC],1
         jmp       short EnterK2

FLat     ENDP

; -----------------------------------------------------------------------------
;        filtr KOI 8
; -----------------------------------------------------------------------------

FKOI     PROC      NEAR

         and       byte ptr ds:[ParamC],not 7
         or        byte ptr ds:[ParamC],2
         jmp       short EnterK2

FKOI     ENDP

; -----------------------------------------------------------------------------
;        filtr fontñ
; -----------------------------------------------------------------------------

EnterK   PROC      NEAR

         xor       byte ptr ds:[ParamC],4   ; zmàna p©°znaku filtru
EnterK2: call      InitTab                  ; inicializace tabulek
         call      DispNadp                 ; zobrazen° nadpisu
         ret

EnterK   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o znak vpravo/vlevo
; -----------------------------------------------------------------------------

Vpravo   PROC      NEAR

         inc       word ptr ds:[TopPoz]
         jns       Vpravo3
Vlevo:   dec       word ptr ds:[TopPoz]
         jns       Vpravo3
         inc       word ptr ds:[TopPoz]
Vpravo3: ret

Vpravo   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o 10 znakñ vlevo
; -----------------------------------------------------------------------------

CVlevo   PROC      NEAR

         mov       cx,10
CVlevo1: call      Vlevo
         loop      CVlevo1
         ret

CVlevo   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o 10 znakñ vpravo
; -----------------------------------------------------------------------------

CVpravo  PROC      NEAR

         mov       cx,10
CVpravo1:call      Vpravo
         loop      CVpravo1
         ret

CVpravo  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o ©†dek dolñ
; -----------------------------------------------------------------------------

Dolu     PROC      NEAR

         cmp       bp,bx                    ; je jië maxim†ln° ©†dek ?
         cmc
         jc        Dolu1                    ; je jië maxim†ln° ©†dek
         call      NextLine                 ; nalezen° dal®°ho ©†dku
Dolu1:   ret

Dolu     ENDP


; -----------------------------------------------------------------------------
;        posun kurzoru o ©†dek nahoru
; -----------------------------------------------------------------------------

Nahoru   PROC      NEAR

         or        bp,bp                    ; je jië prvn° ©†dek ?
         stc
         jz        Nahoru1                  ; je jië prvn° ©†dek
         call      PredLine                 ; nalezen° p©edchoz°ho ©†dku
Nahoru1: ret

Nahoru   ENDP

; -----------------------------------------------------------------------------
;        posun o str†nku dolñ
; -----------------------------------------------------------------------------

PgDn     PROC      NEAR

         mov       cx,ds:[DispRow]          ; poáet zobrazenòch ©†dkñ
         dec       cx                       ; o 1 ©†dek mÇnà
PgDn1:   call      Dolu                     ; posun o ©†dek dolñ
         jc        PgDn2
         loop      PgDn1                    ; posun o dal®° ©†dek
PgDn2:   ret

PgDn     ENDP

; -----------------------------------------------------------------------------
;        konec textu
; -----------------------------------------------------------------------------

EndK     PROC      NEAR

         call      HledZap
EndK1:   call      Dolu
         jnc       EndK1
         call      HledVyp
;         ret

EndK     ENDP

; -----------------------------------------------------------------------------
;        posun o str†nku nahoru
; -----------------------------------------------------------------------------

PgUp     PROC      NEAR

         mov       cx,ds:[DispRow]          ; poáet zobrazenòch ©†dkñ
         dec       cx                       ; o 1 ©†dek mÇnà
PgUp1:   call      Nahoru                   ; posun o ©†dek nahoru
         jc        PgUp2
         loop      PgUp1
PgUp2:   ret

PgUp     ENDP

; -----------------------------------------------------------------------------
;        pokraáov†n° v hled†n°
; -----------------------------------------------------------------------------

HledC    PROC      NEAR

         call      KonvFND
         mov       si,word ptr ds:[FindAdr]
         mov       dx,word ptr ds:[FindAdr+2]
         mov       bp,ds:[FindLine]

         cmp       bp,-1                    ; byla inicializace ?
         je        HledC9                   ; nebyla inicializace

         cmp       byte ptr ds:[FndNum],0
         je        HledC9                   ; nen° nic v bufferu

         call      HledZap                  ; zapnut° indik†toru

         test      byte ptr ds:[Param],80h  ; hled†n° zpàt ?
         jz        HledC4                   ; hled†n° vp©ed

         call      HledPred                 ; nalezen° p©edchoz°ho ©†dku
         jmp       short HledC5

HledC4:  call      HledNxt                  ; nalezen° dal®°ho ©†dku

HledC5:  jnc       HledC6
         call      FlushKey                 ; vypr†zdnàn° bufferu kl†vesnice
         jmp       short HledC9

HledC6:  mov       word ptr ds:[FindAdr],si
         mov       word ptr ds:[FindAdr+2],dx
         mov       ds:[FindLine],bp

         call      HledNorm                 ; normalizace kurzoru

HledC9:  mov       si,word ptr ds:[TopAdr]
         mov       dx,word ptr ds:[TopAdr+2]
         mov       bp,ds:[TopLine]
         call      HledVyp                  ; vypnut° indik†toru
         ret

HledC    ENDP

; -----------------------------------------------------------------------------
;        zaá†tek textu
; -----------------------------------------------------------------------------

Home     PROC      NEAR

         call      HledZap
Home1:   call      Nahoru
         jnc       Home1
         call      HledVyp
         ret

Home     ENDP

; -----------------------------------------------------------------------------
;        nalezen° dal®°ho ©†dku DX:SI, á°slo BP (CY=nen°)
; -----------------------------------------------------------------------------

NextLine PROC      NEAR

; ------ kontrola á°sla ©†dku

         inc       bp                       ; zvò®en° á°sla ©†dku
         cmp       bp,ds:[RadkuTxt]         ; je jië posledn° ©†dek ?
         jae       NextLin8                 ; je jië posledn° ©†dek

; ------ nalezen° dal®°ho ©†dku

         push      ds
         push      ax
         mov       ds,dx                    ; segment adresy
         mov       ah,10                    ; hledanò znak LF
         cld
NextLin1:lodsb                              ; naáten° znaku z bufferu
         or        si,si                    ; je p©eteáen° bufferu ?
         jz        NextLin3                 ; je p©eteáen° bufferu
NextLin2:cmp       al,ah                    ; je LF ?
         jne       NextLin1                 ; nalezen° znaku LF
         pop       ax
         pop       ds
         ret

; ------ zvò®en° segmentu adresy

NextLin3:add       dx,1000h                 ; zvò®en° segmentu adresy
         mov       ds,dx                    ; novò segment adresy
         jmp       short NextLin2

; ------ nen° dal®° ©†dek

NextLin8:dec       bp                       ; n†vrat á°sla ©†dku
         stc                                ; p©°znak, ëe nen° dal®° ©†dek
         ret

NextLine ENDP

; -----------------------------------------------------------------------------
;        nalezen° p©edchoz°ho ©†dku DX:SI, á°slo BP (CY=nen°)
; -----------------------------------------------------------------------------

PredLine PROC      NEAR

; ------ kontrola á°sla ©†dku

         or        bp,bp                    ; je jië prvn° ©†dek ?
         jz        PredLin9                 ; je jië prvn° ©†dek

; ------ nalezen° p©edchoz°ho ©†dku

         dec       bp                       ; sn°ëen° á°sla ©†dku
         push      ds
         push      ax
         mov       ds,dx                    ; segment adresy ©†dku
         mov       ah,10                    ; hledanò znak LF

PredLin1:or        si,si                    ; je p©eteáen° segmentu ?
         jz        PredLin6                 ; je p©eteáen° segmentu
PredLin2:dec       si                       ; adresa minulÇho znaku LF

PredLin3:or        si,si
         jz        PredLin7                 ; p©eteáen° segmentu
PredLin4:dec       si                       ; sn°ëen° ukazatele v bufferu

         cmp       byte ptr ds:[si],ah      ; je to znak LF ?
         jne       PredLin3                 ; nen° LF - nalezen° dal®°ho LF

         inc       si                       ; n†vrat posledn°ho znaku
         jz        PredLin8                 ; p©eteáen° segmentu

PredLin5:clc                                ; p©°znak operace OK
         pop       ax
         pop       ds
         ret

; ------ podteáen° segmentu

PredLin6:cmp       dx,cs:[DatSegm]          ; je jië poá†teán° segment ?
         je        PredLin5                 ; je jië poá†teán° segment
         sub       dx,1000h                 ; posun adresy segmentu
         mov       ds,dx                    ; novò segment adresy
         jmp       short PredLin2

; ------ podteáen° segmentu

PredLin7:cmp       dx,cs:[DatSegm]          ; je jië poá†teán° segment ?
         je        PredLin5                 ; je jië poá†teán° segment
         sub       dx,1000h                 ; posun adresy segmentu
         mov       ds,dx                    ; novò segment adresy
         jmp       short PredLin4

; ------ p©eteáen° segmentu

PredLin8:add       dx,1000h                 ; posun adresy segmentu
         jmp       short PredLin5

; ------ nen° dal®° ©†dek

PredLin9:stc                                ; p©°znak, ëe nen° dal®° ©†dek
         ret

PredLine ENDP

; -----------------------------------------------------------------------------
;        hled†n° textu (DX:SI=zaá†tek str†nky, BP=á°slo ©†dku zaá†tku str†nky)
; -----------------------------------------------------------------------------

Hledej   PROC      NEAR

         or        byte ptr ds:[Param],40h  ; p©°znak hled†n° textu

; ------ test, zda je kurzor zobrazen

         mov       ax,ds:[TopLine]          ; á°slo poá†teán°ho ©†dku
         cmp       ax,ds:[FindLine]         ; je kurzor mimo ?
         ja        Hledej01                 ; kurzor je mimo
         add       ax,ds:[DispRow]          ; á°slo posledn°ho ©†dku
         cmp       ax,ds:[FindLine]         ; je kurzor mimo ?
         ja        Hledej09                 ; kurzor je OK

; ------ nastaven° kurzoru

Hledej01:push      dx
         push      si
         push      bp

         mov       si,word ptr ds:[TopAdr]
         mov       dx,word ptr ds:[TopAdr+2]
         mov       bp,ds:[TopLine]
         mov       cx,ds:[DispRow]          ; poáet zobrazenòch ©†dkñ
         shr       cx,1                     ; polovina
Hledej02:call      NextLine
         loop      Hledej02
         mov       word ptr ds:[FindAdr],si
         mov       word ptr ds:[FindAdr+2],dx
         mov       ds:[FindLine],bp

         pop       bp
         pop       si
         pop       dx


Hledej09:
         mov       byte ptr ds:[FndNum],0

         call      DispNad2                 ; zobrazen° nadpisu hled†n°

Hledej1: call      KonvFND                  ; konverze textu
         call      Disp                     ; zobrazen° obrazovky
         call      DispFnd                  ; zobrazen° hledanÇho textu
         call      DispUkaz                 ; zobrazen° ukazatele polohy v soub.

         push      dx
         mov       dh,0
         mov       dl,byte ptr ds:[FndNum]  ; poáet znakñ textu
         add       dl,offset(Nadpis20-Nadpis2)
         mov       ah,2
         call      Int10P                   ; nastaven° kurzoru
         pop       dx

         mov       ah,0
         int       16h

; ------ p©eru®en° funkce hled†n°

         cmp       al,27
         je        Hledej18
         or        ax,ax
         jnz       Hledej19
Hledej18:jmp       Hledej9

; ------ vymaz†n° znaku

Hledej19:cmp       ax,4b00h
         je        Hledej2                  ; kurzor vlevo
         cmp       ax,5300h
         je        Hledej2                  ; DELETE
         cmp       al,8
         jne       Hledej3
Hledej2: cmp       byte ptr ds:[FndNum],0
         je        Hledej1
         dec       byte ptr ds:[FndNum]
Hledej11:jmp       short Hledej1

; ------ obnoven° znaku - kurzor vpravo

Hledej3: cmp       ax,4d00h
         jne       Hledej4
         mov       bl,byte ptr ds:[FndNum]
         cmp       bl,MAXFND
         je        Hledej1                  ; buffer je jië plnò
         inc       byte ptr ds:[FndNum]     ; zvò®en° á°taáe znakñ
         jmp       short Hledej11

; ------ nalezen° ©etàzce vp©ed

Hledej4:
         mov       si,word ptr ds:[FindAdr]
         mov       dx,word ptr ds:[FindAdr+2]
         mov       bp,ds:[FindLine]

         cmp       ax,5000h                 ; kurzor dolñ
         jne       Hledej5

         call      HledZap                  ; zapnut° indik†toru hled†n°
Hledej42:call      HledNxt                  ; nalezen° dal®°ho ©†dku

; ------ nastaven° kurzoru

Hledej44:jnc       Hledej45
         call      FlushKey                 ; vypr†zdnàn° bufferu kl†vesnice
         jmp       short Hledej12

Hledej45:mov       word ptr ds:[FindAdr],si
         mov       word ptr ds:[FindAdr+2],dx
         mov       ds:[FindLine],bp

         call      HledNorm                 ; normalizace kurzoru

Hledej12:call      HledVyp                  ; vypnut° indik†toru
         jmp       short Hledej11

; ------ nalezen° ©etàzce zpàt

Hledej5: cmp       ax,4800h                 ; kurzor nahoru
         jne       Hledej6

         call      HledZap                  ; zapnut° indik†toru hled†n°
Hledej52:call      HledPred                 ; nalezen° p©edchoz°ho ©†dku
         jmp       short Hledej44           ; normalizace kurzoru

; ------ nalezen° prvn°ho vòskytu ©etàzce ENTER

Hledej6: cmp       al,13
         jne       Hledej68                 ; nen° ENTER
         cmp       byte ptr ds:[FndNum],0
         je        Hledej66                 ; nen° nic zad†no
         call      HledZap                  ; zapnut° indik†toru
Hledej62:call      PredLine                 ; nastaven° na p©ede®lò ©†dek
         jnc       Hledej62                 ; nalezen° prvn°ho ©†dku
         call      HledTst
         jnc       Hledej63                 ; prvn° ©†dek vyhovuje
         call      HledNxt                  ; nalezen° dal®°ho ©†dku
Hledej63:call      HledVyp                  ; vypnut° indik†toru
         jc        Hledej66                 ; ©etàzec nenalezen
         mov       word ptr ds:[FindAdr],si
         mov       word ptr ds:[FindAdr+2],dx
         mov       ds:[FindLine],bp

         call      HledNorm                 ; normalizace kurzoru
Hledej66:jmp       Hledej9                  ; n†vrat z obsluhy

; ------ nalezen° prvn°ho vòskytu ©etàzce HOME

Hledej68:cmp       ax,4700h                 ; HOME
         jne       Hledej7
         call      HledZap                  ; zapnut° indik†toru
Hledej69:call      PredLine                 ; nalezen° p©edchoz°ho ©†dku
         jnc       Hledej69
         call      HledTst
         jnc       Hledej44                 ; prvn° ©†dek OK
         jmp       short Hledej42

; ------ nalezen° posledn°ho vòskytu ©etàzce END

Hledej7: cmp       ax,4f00h
         jne       Hledej72
         call      HledZap                  ; zapnut° indik†toru
Hledej71:call      NextLine                 ; nastaven° na dal®° ©†dek
         jnc       Hledej71                 ; nalezen° posledn°ho ©†dku
         call      HledTst
         jnc       Hledej44                 ; posledn° ©†dek OK
         jmp       short Hledej52           ; nalezen° posledn°ho ©etàzce

; ------ posun o str†nku zpàt

Hledej72:cmp       ax,4900h                 ; PAGE UP
         jne       Hledej74
         mov       cx,ds:[DispRow]
         dec       cx
Hledej73:call      PredLine                 ; nalezen° p©edchoz°ho ©†dku
         loop      Hledej73
;         call      HledZap                  ; zapnut° indik†toru
;         mov       cx,bp
;         sub       cx,ds:[DispRow]          ; minim†ln° ©†dek k dosaëen°
;         jnc       Hledj722
;         xor       cx,cx
;Hledj722:call      HledPred                 ; nalezen° p©edchoz°ho ©etàzce
;         jc        Hledej73                 ; nenalezen
;         cmp       bp,cx
;         ja        Hledj722                 ; nen° je®tà poëadovanò ©†dek
         clc                                ; p©°znak operace OK
Hledj444:jmp       Hledej44

; ------ posun o str†nku vp©ed

Hledej74:cmp       ax,5100h                 ; PAGE DOWN
         jne       Hledej8
         mov       cx,ds:[DispRow]
         dec       cx
Hledej75:call      NextLine                 ; nalezen° dal®°ho ©†dku
         loop      Hledej75
;         call      HledZap                  ; zapnut° indik†toru
;         mov       cx,bp
;         add       cx,ds:[DispRow]
;         cmp       cx,ds:[RadkuTxt]
;         jb        Hledej75
;         mov       cx,ds:[RadkuTxt]
;         dec       cx
;Hledej75:call      HledNxt                  ; nalezen° dal®°ho ©etàzce
;         jc        Hledej76                 ; nenalezen
;         cmp       bp,cx
;         jb        Hledej75                 ; nen° je®tà poëadovanò ©†dek
         clc                                ; p©°znak operace OK
         jmp       short Hledj444

; ------ vloëen° znaku

Hledej8: cmp       al,0
         je        Hledej13                 ; neplatnò znak
         mov       bx,ds:[FndNum]
         cmp       bl,MAXFND
         je        Hledej13                 ; buffer je jië plnò
         mov       ds:[FndTxt+bx],al        ; uloëen° znaku do bufferu
         inc       byte ptr ds:[FndNum]     ; zvò®en° á°taáe znakñ
Hledej13:jmp       Hledej1

; ------ n†vrat z obsluhy hled†n°

Hledej9: and       byte ptr ds:[Param],not 40h ; zru®en° p©°znaku hled†n°
         call      DispNadp

         mov       si,word ptr ds:[TopAdr]
         mov       dx,word ptr ds:[TopAdr+2]
         mov       bp,ds:[TopLine]
         ret

Hledej   ENDP

; -----------------------------------------------------------------------------
;        nastaven° kurzoru pro hled†n° a normalizace obrazovky
; -----------------------------------------------------------------------------

HledNrm0:mov       word ptr ds:[FindAdr],si
         mov       word ptr ds:[FindAdr+2],dx
         mov       ds:[FindLine],bp

; -----------------------------------------------------------------------------
;        normalizace poá†tku obrazovky p©i hled†n°
; -----------------------------------------------------------------------------

HledNorm PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©°prava ukazatelñ

         mov       si,word ptr ds:[FindAdr]
         mov       dx,word ptr ds:[FindAdr+2]
         mov       bp,ds:[FindLine]

; ------ test, zda je podteáen° kurzoru

         mov       cx,ds:[DispRow]          ; poáet zobrazenòch ©†dkñ
         shr       cx,1
         shr       cx,1                     ; 1/4 obrazovky
         mov       ax,ds:[TopLine]          ; á°slo poá†teán°ho ©†dku
         add       ax,cx                    ; okraj naho©e
         cmp       ax,bp                    ; je podteáen° poá†tku ?
         jbe       HledNrm3                 ; poá†tek je OK

; ------ posun kurzoru, je-li podteáen°

HledNrm2:call      PredLine
         loop      HledNrm2
         jmp       short HledNrm8           ; nastaven° poá†tku obrazovky

; ------ test, zda je p©eteáen° kurzoru

HledNrm3:mov       ax,cx
         shl       cx,1
         add       cx,ax                    ; 3/4 obrazovky
         mov       ax,ds:[TopLine]
         add       ax,cx
         cmp       ax,bp                    ; je p©eteáen° konce ?
         jae       HledNrm9                 ; kurzor je OK

; ------ posun kurzoru, je-li p©eteáen°

         mov       bx,ds:[RadkuTxt]
         sub       bx,ds:[DispRow]          ; maxim†ln° prvn° ©†dek
         jnc       HledNrm4
         xor       bx,bx
HledNrm4:call      PredLine
         loop      HledNrm4
         inc       cx
         cmp       bp,bx
         ja        HledNrm4

; ------ nov† adresa poá†tku obrazovky

HledNrm8:mov       word ptr ds:[TopAdr],si
         mov       word ptr ds:[TopAdr+2],dx
         mov       ds:[TopLine],bp

; ------ n†vrat registrñ

HledNrm9:pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

HledNorm ENDP

; -----------------------------------------------------------------------------
;        nalezen° n†sleduj°c°ho ©†dku s textem
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=ukazatel zaá†tku ©†dku
;        BP=á°slo ©†dku
; VùSTUP:DX:SI=ukazatel nalezenÇho ©†dku
;        BP=á°slo nalezenÇho ©†dku
;        CY=text nenalezen
; -----------------------------------------------------------------------------

HledNxt  PROC      NEAR

; ------ £schova registrñ

         and       byte ptr ds:[Param],not 80h ; p©°znak hled†n° vp©ed
         push      dx
         push      si
         push      bp

; ------ nastaven° ukazatele na n†sleduj°c° ©†dek

HledNxt1:call      NextLine                 ; nalezen° dal®°ho ©†dku
         jc        HledNxt9                 ; nen° dal®° ©†dek

; ------ test, zda ©†dek obsahuje hledanò text

         call      HledTst                  ; test ©†dku
         jc        HledNxt1                 ; text nenalezen - dal®° ©†dek

; ------ text nalezen - registry jsou platnÇ

         add       sp,6                     ; zru®en° registrñ v z†sobn°ku
         clc                                ; p©°znak operace OK
         ret

; ------ text nenalezen - n†vrat registrñ

HledNxt9:pop       bp
         pop       si
         pop       dx
         stc                                ; p©°znak, ëe text nebyl nalezen
         ret

HledNxt  ENDP

; -----------------------------------------------------------------------------
;        nalezen° p©edchoz°ho ©†dku s textem
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=ukazatel zaá†tku ©†dku
;        BP=á°slo ©†dku
; VùSTUP:DX:SI=ukazatel nalezenÇho ©†dku
;        BP=á°slo nalezenÇho ©†dku
;        CY=text nenalezen
; -----------------------------------------------------------------------------

HledPred PROC      NEAR

; ------ £schova registrñ

         or        byte ptr ds:[Param],80h  ; p©°znak hled†n° zpàt
         push      dx
         push      si
         push      bp

; ------ nastaven° ukazatele na p©edchoz° ©†dek

HledPrd1:call      PredLine                 ; nalezen° dal®°ho ©†dku
         jc        HledPrd9                 ; nen° dal®° ©†dek

; ------ test, zda ©†dek obsahuje hledanò text

         call      HledTst                  ; test ©†dku
         jc        HledPrd1                 ; text nenalezen - dal®° ©†dek

; ------ text nalezen - registry jsou platnÇ

         add       sp,6                     ; zru®en° registrñ v z†sobn°ku
         clc                                ; p©°znak operace OK
         ret

; ------ text nenalezen - n†vrat registrñ

HledPrd9:pop       bp
         pop       si
         pop       dx
         stc                                ; p©°znak, ëe text nebyl nalezen
         ret

HledPred ENDP

; -----------------------------------------------------------------------------
;        test, zda ©†dek DX:SI/BP obsahuje hledanò text (CY=neobsahuje)
; -----------------------------------------------------------------------------

HledTst  PROC      NEAR

; ------ nen°-li text, ©†dek vyhovuje OK

         cmp       byte ptr ds:[FndNum],0   ; je zad†n nàjakò text ?
         jne       HledTst0                 ; je nàco zad†no
         ret                                ; nen° nic zad†no - ©†dek vyhovuje

; ------ £schova registrñ

HledTst0:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ p©°prava registrñ

         mov       ax,ds
         mov       es,ax                    ; ES <- datovò segment
         mov       bp,ds:[MaxOffs]          ; maxim†ln° offset
         mov       ah,ds:[FndTxt0]          ; prvn° znak textu
         cld
         mov       ds,dx                    ; segment s daty
         mov       bh,0

; ------ test, zda je jië konec textu

HledTst1:cmp       si,bp                    ; je maxim†ln° offset ?
         je        HledTst6                 ; je maxim†ln° offset

; ------ naáten° jednoho znaku

HledTs11:lodsb                              ; naáten° znaku
         or        si,si                    ; je p©eteáen° segmentu ?
         jz        HledTst5                 ; je p©eteáen° segmentu

; ------ test, zda je jië konec ©†dku

HledTst2:cmp       al,10                    ; je konec ©†dku ?
         je        HledTst7                 ; je konec ©†dku

; ------ p©evod na velkÇ p°smeno

         mov       bl,al                    ; znak ke konverzi
         mov       bl,cs:[bx+Filtr]         ; konverze na znak displeje
         mov       al,cs:[bx+FiltrU]        ; p©evod na velkÇ p°smeno

; ------ test, zda se prvn° znak shoduje

         cmp       al,ah                    ; shoduje se prvn° znak ?
         jne       HledTst1                 ; znak se neshoduje - dal®° znak

; ------ porovn†n°, zda se shoduj° ostatn° znaky textu

         mov       cx,cs:[FndNum]           ; dÇlka zadanÇho textu
         dec       cx                       ; dÇlka textu - 1
         jcxz      HledTst8                 ; je zad†n pouze 1 znak - OK

         push      si
         push      dx
         mov       di,offset FndTxt0+1      ; buffer zadanÇho textu

; ------ naáten° znaku

HledTs42:lodsb                              ; naáten° znaku
         or        si,si                    ; je p©eteáen° segmentu ?
         jz        HledTs48                 ; je p©eteáen° segmentu

; ------ p©evod na velkÇ p°smeno

HledTs43:mov       bl,al                    ; znak ke konverzi
         mov       bl,cs:[bx+Filtr]         ; konverze na znak displeje
         mov       al,cs:[bx+FiltrU]        ; p©evod na velkÇ p°smeno

; ------ test, zda se znak shoduje

         scasb                              ; shoduje se znak ?
         loope     HledTs42                 ; test dal®°ho znaku

; ------ n†vrat registrñ

         pop       dx
         pop       si
         mov       ds,dx                    ; n†vrat DS
         jne       HledTst1                 ; text se neshoduje - dal®° znak
         jmp       short HledTst8           ; text se shoduje OK

; ------ p©eteáen° segmentu

HledTs48:add       dx,1000h
         mov       ds,dx
         jmp       short HledTs43

; ------ p©eteáen° segmentu

HledTst5:add       dx,1000h                 ; posun adresy segmentu
         mov       ds,dx                    ; novò segment
         jmp       short HledTst2

; ------ test, zda je maxim†ln° segment

HledTst6:cmp       dx,cs:[MaxSegm]          ; je maxim†ln° segment ?
         jne       HledTs11                 ; nen° maxim†ln° segment

; ------ text nenalezen

HledTst7:stc                                ; p©°znak nenalezen° textu

; ------ n†vrat registrñ

HledTst8:pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

HledTst  ENDP

; -----------------------------------------------------------------------------
;        zapnut° indik†toru hled†n°
; -----------------------------------------------------------------------------

HledZap  PROC      NEAR

         push      ds
         push      si
         call      KurzOff                  ; vypnut° kurzoru
         lds       si,ds:[AdrVRAM]
         mov       byte ptr ds:[si],"*"     ; indik†tor hled†n°
         pop       si
         pop       ds
         ret

HledZap  ENDP

; -----------------------------------------------------------------------------
;        vypnut° indik†toru hled†n°
; -----------------------------------------------------------------------------

HledVyp  PROC      NEAR

         push      ds
         push      si
         lds       si,ds:[AdrVRAM]
         mov       byte ptr ds:[si]," "     ; indik†tor hled†n°
         pop       si
         pop       ds
         ret

HledVyp  ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° bufferu kl†vesnice
; -----------------------------------------------------------------------------

FlushKey PROC      NEAR

         push      ax
FlushK1: mov       ah,1
         int       16h
         jz        FlushK2
         mov       ah,0
         int       16h
         jmp       short FlushK1
FlushK2: pop       ax
         stc
         ret

FlushKey ENDP

; *****************************************************************************
;
;                           Dekomprese souboru
;
; *****************************************************************************

;˛

; -----------------------------------------------------------------------------
;        dekomprese souboru (DS:SI -> ES:DI)
; -----------------------------------------------------------------------------

DeKomp   PROC      NEAR

; ------ p©°prava k dek¢dov†n°

         cld                                ; smàr nahoru
         mov       ax,1                     ; p©°znak, ëe nen° dal®° bit

; ------ prvn° p©°znakovò bit

DeKomp1: call      DekBit                   ; prvn° p©°znakovò bit
         jz        DeKomp2                  ; konec bufferu
         jc        DeKomp3                  ; je komprese ©etàzce

; ------ p©esun jednoho bajtu dat bez komprese

         call      ReadByte                 ; naáten° bajtu
         jz        DeKomp2                  ; konec dat
         call      WritByte                 ; z†pis bajtu
         jnz       DeKomp1                  ; nen° p©eteáen° bufferu
DeKomp2: ret

; ------ p©°prava k opakov†n° ©etàzce

DeKomp3: xor       bx,bx                    ; BX <- 0 offset ©etàzce
         xor       cx,cx                    ; dÇlka ©etàzce k opakov†n°

; -----------------------------------
;        stanoven° dÇlky ©etàzce
; -----------------------------------

; ------ prvn° bit dÇlky

         mov       dl,1                     ; poáet bitñ ke áten°
         call      DekBitC                  ; áten° prvn°ho a druhÇho bitu dÇlky
         jz        DeKomp2                  ; p©eteáen° bufferu
                                            ; (zde je stav 0 aë 1)

; ------ zvò®en° á°taáe dÇlky

DeKomp32:inc       cx
         inc       cx

; ------ naáten° p©°znaku konce k¢du

         call      DekBit                   ; p©°znakovò bit
         jz        DeKomp2                  ; p©eteáen° bufferu
         jnc       DeKomp38                 ; konec k¢du

; ------ p©°padnÇ pokraáov†n° k¢du

         cmp       cl,MAXLENX-4+1           ; je jië maxim†ln° dÇlka ?
         jb        DeKomp32                 ; pokraáov†n° k¢du
         inc       cx
         inc       cx                       ; korekce posledn°ch 2 k¢dñ

; ------ korekce pro n†hradn° k¢d

DeKomp38:cmp       cl,SUBSTLEN              ; je n†hradn° dÇlka ?
         jb        DeKomp7                  ; dÇlka je OK
         ja        DeKomp39                 ; je dlouh† dÇlka

; ------ dlouhÇ opakov†n°

         call      ReadByte                 ; naáten° bajtu
DeKomp51:jz        DeKomp2                  ; konec
         mov       cl,dh                    ; dÇlka (stav 0 aë 255)
         cmp       cl,255                   ; konec dek¢dov†n° ?
         je        DeKomp51                 ; je konec
         add       cx,MAXLENX+1             ; zvò®en° dÇlky

; ------ korekce dÇlky pro dlouhò k¢d

DeKomp39:dec       cx

; ------------------------------------
;        stanoven° offsetu ©etàzce
; ------------------------------------

; ------ dÇlka 2 nem† offset HIGH

DeKomp7: cmp       cx,2                     ; je dÇlka 2 ?
         je        DeKomp9                  ; je dÇlka 2

; ------ prvn° p©°znakovò bit - p©°znak offsetu HIGH=0

         call      DekBit                   ; áten° p©°znakovÇho bitu
         jz        DeKomp51                 ; p©eteáen° bufferu
         jc        DeKomp9                  ; offset HIGH = 0

; ------ 3 bity offsetu HIGH

         mov       dl,3                     ; naátou se 3 bity
         call      DekBitB                  ; naáten° 3 bitñ offsetu
         jz        DeKomp51                 ; p©eteáen° bufferu

; ------ stav 0,1: offset HIGH = 1,2

         cmp       bh,1                     ; je stav 0,1 ?
         jbe       DeKomp8                  ; offset HIGH = 1,2

; ------ átvrtò bit offsetu

         call      DekBitB                  ; naáten° 1 bitu offsetu
         jz        DeKomp51                 ; p©eteáen° bufferu

; ------ stav 4,7: offset HIGH=3 aë 6

         dec       bh                       ; stav 3 aë 14
         cmp       bh,6                     ; je stav 3 aë 6 ?
         jbe       DeKomp9                  ; je offset 3 aë 6
                                            ; jinak stav 7 aë 14

; ------ p†tò bit offsetu

         call      DekBitB                  ; naáten° 1 bitu offsetu
         jz        DeKomp51                 ; p©eteáen° bufferu

; ------ stav 14 aë 23: offset HIGH=7 aë 13

         sub       bh,7                     ; stav 7 aë 22
         cmp       bh,13
         jbe       DeKomp9                  ; je offset 7 aë 13
                                            ; jinak stav 14 aë 22

; ------ ®estò bit offsetu: offset HIGH=14 aë 31

         call      DekBitB                  ; naáten° 1 bitu offsetu
         jz        DeKomp51                 ; p©eteáen° bufferu
         sub       bh,15                    ; stav 13 aë 30

; ------ offset ©etàzce LOW

DeKomp8: inc       bh                       ; korekce BH
DeKomp9: call      ReadByte                 ; naáten° offsetu dÇlky LOW
         mov       bl,dh                    ; offset dÇlky LOW
         jz        DeKomp51                 ; p©eteáen° bufferu

; ------ p©enos ©etàzce

         push      si                       ; £schova SI
         mov       bp,ds                    ; £schova DS
         push      es
         pop       ds                       ; DS <- ES
         mov       si,di                    ; souáasnò ukazatel
         sub       si,bx                    ; posun zaá†tku ©etàzce
         jc        DeKompC                  ; podteáen° bufferu
DeKompA: mov       dh,ds:[si]
         inc       si
         jz        DeKompD
DeKompAB:call      WritByte                 ; uloëen° bajtu do bufferu
         loopnz    DeKompA
DeKompAA:mov       ds,bp                    ; n†vrat DS
         pop       si
         jz        DeKomp51
DeKompB: jmp       DeKomp1                  ; dal®° dek¢dov†n°

; ------ podteáen° bufferu

DeKompC: push      ax
         mov       ax,ds
         sub       ax,1000h
         mov       ds,ax
         pop       ax
         jmp       short DeKompA

; ------ p©eteáen° bufferu

DeKompD: push      ax
         mov       ax,ds
         add       ax,1000h
         mov       ds,ax
         pop       ax
         jmp       short DeKompAB

DeKomp   ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bitu ze stavovÇho slova do registru BH
; -----------------------------------------------------------------------------
; VSTUP: AX=stavovÇ slovo (nastaven nejvy®®° bit jako p©°znak konce slova)
;        DS:SI=ukazatel zkomprimovanòch dat
;        BH=pñvodn° stav registru BH
;        DL=poáet bitñ k naáten° do registru BH (nesm° bòt = 0 !)
; VùSTUP:ZY=p©eteáen° bufferu
;        BH=novò stav registru BH
;        DL=1 (p©ipraveno pro áten° 1 bitu)
; -----------------------------------------------------------------------------

DekBitB  PROC      NEAR

         call      DekBit                   ; áten° bitu stavovÇho slova
         jz        DekBitB9                 ; p©eteáen° bufferu
         rcl       bh,1                     ; rotace bitu do registru BH
         dec       dl                       ; sn°ëen° á°taáe bitñ DL
         jnz       DekBitB                  ; áten° dal®°ho bitu
         inc       dx                       ; nastaven° p©°znaku NZ
DekBitB9:ret

DekBitB  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bitu ze stavovÇho slova do registru CX
; -----------------------------------------------------------------------------
; VSTUP: AX=stavovÇ slovo (nastaven nejvy®®° bit jako p©°znak konce slova)
;        DS:SI=ukazatel zkomprimovanòch dat
;        CX=pñvodn° stav registru CX
;        DL=poáet bitñ k naáten° do registru CX (nesm° bòt = 0 !)
; VùSTUP:ZY=p©eteáen° bufferu
;        CX=novò stav registru CX
;        DL=1 (p©ipraveno pro áten° 1 bitu)
; -----------------------------------------------------------------------------

DekBitC  PROC      NEAR

         call      DekBit                   ; áten° bitu stavovÇho slova
         jz        DekBitC9                 ; p©eteáen° bufferu
         rcl       cx,1                     ; rotace bitu do registru CX
         dec       dl                       ; sn°ëen° á°taáe bitñ DL
         jnz       DekBitC                  ; áten° dal®°ho bitu
         inc       dx                       ; nastaven° p©°znaku NZ
DekBitC9:ret

DekBitC  ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bitu ze stavovÇho slova
; -----------------------------------------------------------------------------
; VSTUP: AX=stavovÇ slovo (nastaven nejvy®®° bit jako p©°znak konce slova)
;        DS:SI=ukazatel zkomprimovanòch dat
; VùSTUP:CF=bit ze stavovÇho slova
;        ZY=p©eteáen° bufferu
; -----------------------------------------------------------------------------

DekBit   PROC      NEAR

; ------ poskytnut° jednoho bitu stavovÇho slova

         shr       ax,1                     ; poskytnut° bitu ze stav. slova
         jnz       DekBit3                  ; nen° je®tà konec slova

; ------ naáten° dal®°ho stavovÇho slova

         call      ReadByte                 ; naáten° bajtu
         jz        DekBit3                  ; konec bufferu
         mov       al,dh                    ; nië®° bajt stavovÇho slova
         call      ReadByte                 ; naáten° bajtu
         mov       ah,dh                    ; konec bufferu
         stc
         rcr       ax,1                     ; prvn° bit stavovÇho slova
DekBit3: ret

DekBit   ENDP

; -----------------------------------------------------------------------------
;     áten° bajtu ze souboru (ukazatel DS:SI, ZY=konec souboru, DH=bajt)
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ test, zda jsou dal®° data v bufferu

         cmp       si,cs:[InpNum]           ; je konec dat v bufferu ?
         jae       ReadByt2                 ; je konec bufferu

; ------ naáten° bajtu z bufferu

ReadByt8:mov       dh,ds:[si]               ; naáten° bajtu z bufferu
         inc       si                       ; nastaven° p©°znaku NZ
ReadByt9:ret

; ------ naáten° dal®°ho bloku dat ze souboru

ReadByt2:push      ax
         push      bx
         push      cx
         push      dx

         xor       si,si                    ; ukazatel na zaá†tek bufferu
         mov       ah,3fh
         mov       bx,cs:[SoubIdnt]         ; identifik†tor souboru
         mov       cx,BUFFSIZE              ; velikost bufferu
         xor       dx,dx                    ; zaá†tek k naáten° bloku dat
         int       21h                      ; naáten° bloku dat ze souboru

         jnc       ReadByt3                 ; operace áten° OK
         xor       ax,ax                    ; jinak jako konec souboru
ReadByt3:mov       cs:[InpNum],ax           ; poáet bajtñ v bufferu

         call      Dekod                    ; dek¢dov†n° dat

         or        ax,ax                    ; je konec souboru ?

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         jnz       ReadByt8                 ; jsou dal®° data
         ret                                ; jinak konec souboru

ReadByte ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° dat naátenòch do bufferu
; -----------------------------------------------------------------------------

Dekod    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds

; ------ test, zda m† bòt soubor dek¢dov†n

         test      byte ptr cs:[Prepin],4   ; je heslo ?
         jz        Dekod9                   ; nek¢duje se

; ------ p©°prava registrñ

         mov       ds,cs:[InpSegm]          ; segment vstupn°ho bufferu
         xor       si,si                    ; ukazatel v bufferu
         mov       dx,cs:[InpNum]           ; poáet bajtñ v bufferu
         or        dx,dx                    ; jsou nàjak† data ?
         jz        Dekod9                   ; nejsou ë†dn† data
         xor       bx,bx
         mov       bl,byte ptr cs:[InpSize] ; ukazatel f†ze
         add       word ptr cs:[InpSize],dx ; á°taá velikosti souboru
         adc       word ptr cs:[InpSize+2],0

; ------ dek¢dov†n° dat

Dekod3:  mov       cx,word ptr cs:[bx+Klic]
         mov       al,ds:[si]               ; bajt k zak¢dov†n°
         and       cl,7
         xor       al,ch                    ; zak¢dov†n° bajtu
         ror       al,cl
         mov       ds:[si],al
         inc       si
         inc       bl
         dec       dx
         jnz       Dekod3                   ; dal®° bajt dat

; ------ n†vrat registrñ

Dekod9:  pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Dekod    ENDP

; -----------------------------------------------------------------------------
;      uloëen° bajtu do bufferu (ukazatel ES:DI, ZY=konec bufferu, DH=bajt)
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

; ------ test, zda se offset shoduje s koncem

         cmp       di,cs:[MaxOffs]          ; shoduje se offset ?
         je        WritByt3                 ; offset se shoduje s koncem

; ------ test, zda je dal®° ©†dek (znak LF)

WritByt1:cmp       dh,10                    ; je znak LF ?
         je        WritByt4                 ; je novò ©†dek - znak LF

; ------ uloëen° bajtu do bufferu

         mov       es:[di],dh               ; uloëen° bajtu do bufferu
         inc       di                       ; zvò®en° ukazatele v bufferu
         jz        WritByt2                 ; je p©eteáen° segmentu
         ret                                ; jinak n†vrat NZ

; ------ posun adresy segmentu

WritByt2:push      ax
         mov       ax,es                    ; segment
         add       ax,1000h                 ; posun adresy segmentu
         mov       es,ax                    ; novò segment
         pop       ax
         ret                                ; n†vrat se stavem NZ

; ------ test, zda se shoduje segment s koncem

WritByt3:push      ax
         mov       ax,es                    ; segment
         cmp       ax,cs:[MaxSegm]          ; je koncovò segment ?
         pop       ax
         jne       WritByt1                 ; nen° koncovò segment
         ret                                ; jinak n†vrat ZY

; ------ novò ©†dek - zvò®en° á°taáe ©†dkñ

WritByt4:inc       word ptr cs:[RadkuTxt]   ; zvò®en° á°taáe ©†dkñ celkem

; ------ uloëen° znaku do bufferu

         mov       es:[di],dh               ; uloëen° bajtu do bufferu
         inc       di                       ; zvò®en° ukazatele v bufferu
         jz        WritByt2                 ; je p©eteáen° segmentu
         ret                                ; jinak n†vrat NZ

WritByte ENDP

; *****************************************************************************
;
;                               Zobrazen° textu
;
; *****************************************************************************
;˛

; -----------------------------------------------------------------------------
;        zobrazen° hledanÇho textu
; -----------------------------------------------------------------------------

DispFnd  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         cld
         mov       si,offset FndTxt0        ; buffer hledanÇho textu
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         add       di,2*offset(Nadpis20-Nadpis2)
         mov       ah,ds:[Barva2]           ; barva nadpisu
         mov       cx,MAXFND                ; maxim†ln° dÇlka textu
         mov       bx,ds:[FndNum]           ; poáet znakñ v bufferu

; ------ zobrazen° hledanÇho textu

DispFnd1:lodsb
         dec       bx                       ; á°taá platnòch znakñ
         jns       DispFnd2                 ; je platnò znak
         mov       al," "                   ; n†hrada znaku mezerou
DispFnd2:stosw                              ; zobrazen° znaku
         loop      DispFnd1

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispFnd  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla AX od adresy ES:DI dolñ
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

; ------ dek¢dov†n° jednÇ á°slice

         mov       bx,10                    ; dàlitel
DekNum1: xor       dx,dx
         div       bx                       ; vòpoáet jednÇ á°slice
         add       dl,"0"                   ; korekce na ASCII znak

; ------ uloëen° jednÇ á°slice

         dec       di                       ; sn°ëen° ukazatele
         mov       es:[di],dl               ; uloëen° znaku

; ------ test, zda je dal®° á°slo

         or        ax,ax                    ; je konec á°sla ?
         jnz       DekNum1                  ; nen° konec á°sla

; ------ n†vrat registrñ

         pop       dx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° ukazatele polohy v souboru
; -----------------------------------------------------------------------------

DispUkaz PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      di
         push      bp
         push      es

; ------ dek¢dov†n° á°selnÇho ukazatele

         push      ds
         pop       es
         mov       di,offset NadpCis-11     ; zaá†tek bufferu
         mov       al," "                   ; znak k uloëen°
         cld
         mov       cx,11                    ; dÇlka bufferu
         rep       stosb                    ; vymaz†n° bufferu
         mov       ax,ds:[RadkuTxt]         ; celkovò poáet ©†dkñ
         call      DekNum                   ; dek¢dov†n° á°sla
         dec       di                       ; sn°ëen° ukazatele
         mov       byte ptr es:[di],"/"     ; oddàlovaá
         mov       ax,ds:[TopLine]          ; poá†teán° ©†dek
         inc       ax
         call      DekNum                   ; dek¢dov†n° poá†teán°ho ©†dku

; ------ p©°prava registrñ

         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         add       di,2*(offset(Nadpis0-Nadpis)+13+1) ; poá†teán° pozice k zobr.
         mov       bp,80-offset(Nadpis0-Nadpis)-13-2 ; celkov† dÇlka ukazatele
         cld

; ------ stanoven° dÇlky kurzoru

         mov       ax,ds:[RadkuTxt]         ; celkovò poáet ©†dkñ
         sub       ax,ds:[TopLine]          ; poáet zbylòch ©†dkñ
         ja        DispUk04
         mov       ax,1                     ; omezen° p©i podteáen°
DispUk04:cmp       ax,ds:[DispRow]          ; je jië konec souboru ?
         jbe       DispUk05                 ; je jië konec souboru
         mov       ax,ds:[DispRow]          ; omezen° na poáet zobrazenòch ©†dkñ
DispUk05:mul       bp                       ; poáet ©†dkñ * koeficient dÇlky
         div       word ptr ds:[RadkuTxt]   ; ®°©ka kurzoru relativnà
         or        ax,ax                    ; je dÇlka 0 ?
         jnz       DispUk1
         inc       ax                       ; dÇlka = 1
DispUk1: cmp       ax,bp                    ; p©ekroáila se dÇlka ukazatele ?
         jbe       DispUk2                  ; dÇlka je OK
         mov       ax,bp                    ; omezen° dÇlky kurzoru
DispUk2: mov       bx,ax                    ; £schova dÇlky kurzoru

; ------ stanoven° poá†teán° pozice kurzoru

         mov       ax,ds:[TopLine]          ; poá†teán° ©†dek
         mul       bp                       ; poá†teán° ©†dek * koeficient dÇlky
         div       word ptr ds:[RadkuTxt]   ; poá†teán° pozice relativnà
         mov       cx,ax                    ; £schova poá†teán° pozice
         add       ax,bx                    ; koncov† pozice
         cmp       ax,bp                    ; p©ekroáena dÇlka ukazatele ?
         jbe       DispUk3                  ; dÇlka je OK
         mov       cx,bp                    ; konec ukazatele
         sub       cx,bx                    ; poá†teán° pozice

; ------ oprava konce kurzoru

DispUk3: mov       ax,ds:[TopLine]          ; poá†teán° ©†dek
         add       ax,ds:[DispRow]          ; á°slo koncovÇho ©†dku
         cmp       ax,ds:[RadkuTxt]         ; zobrazen konec ?
         jb        DispUk4                  ; nen° zobrazen konec
         mov       cx,bp                    ; konec ukazatele
         sub       cx,bx                    ; poá†teán° pozice ukazatele

; ------ zobrazen° ukazatele

DispUk4: sub       bp,cx                    ; odeáten° poá†tku ukazatele
         sub       bp,bx                    ; odeáten° dÇlky ukazatele
         mov       al,ds:[GRAFX3]           ; poá†teán° znak ukazatele
         mov       ah,ds:[Barva2]           ; barva nadpisu
         rep       stosw                    ; zobrazen° poá†tku ukazatele
         mov       al,ds:[GRAFX4]           ; ukazatel
         mov       cx,bx                    ; dÇlka ukazatele
         rep       stosw                    ; zobrazen° ukazatele
         mov       cx,bp                    ; konec ukazatele
         mov       al,ds:[GRAFX3]           ; znak konce ukazatele
         rep       stosw                    ; zobrazen° konce ukazatele

         mov       al," "
         stosw

; ------ n†vrat registrñ

         pop       es
         pop       bp
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DispUkaz ENDP

; -----------------------------------------------------------------------------
;        zobrazen° nadpisu hled†n°
; -----------------------------------------------------------------------------

DispNad2 PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       ah,ds:[Barva2]           ; barva nadpisu
         les       di,ds:[AdrVRAM]

; ------ zobrazen° n†povàdy

         mov       si,offset Nadpis2
         mov       cx,offset(Nadpis0-Nadpis)+13 ; dÇlka textu
         call      DispAsc                  ; zobrazen° textu

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispNad2 ENDP

; -----------------------------------------------------------------------------
;        zobrazen° bàënÇho nadpisu
; -----------------------------------------------------------------------------

DispNadp PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       ah,ds:[Barva2]           ; barva nadpisu
         les       di,ds:[AdrVRAM]

; ------ zobrazen° jmÇna souboru

         cld
         mov       al," "
         stosw                              ; £vodn° mezera
         mov       si,ds:[AdrSoub]
         mov       cx,13
         call      DispAsc

; ------ zobrazen° n†povàdy

         mov       si,offset Nadpis
         mov       cx,offset(Nadpis0-Nadpis) ; dÇlka textu
         call      DispAsc

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispNadp ENDP

; -----------------------------------------------------------------------------
;        zobrazen° ©etàzce ASCIIZ (dÇlka CX)
; -----------------------------------------------------------------------------

DispAsc  PROC      NEAR

         cld
DispAsc1:lodsb
         cmp       al,0
         jne       DispAsc2
         mov       al," "
         dec       si
DispAsc2:stosw
         loop      DispAsc1
         ret

DispAsc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktivn° str†nky
; -----------------------------------------------------------------------------

Disp     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

; ------ p©°prava registrñ k zobrazen°

         les       di,cs:[AdrVRAM]          ; adresa videopamàti
         add       di,160                   ; adresa druhÇho ©†dku na displeji
         lds       si,cs:[TopAdr]           ; adresa poá†tku str†nky
         mov       bp,word ptr cs:[MaxOffs] ; maxim†ln° offset
         mov       dh,cs:[MaxRow]           ; poáet ©†dkñ k zobrazen°
         mov       dl,cs:[ParamC]           ; parametry a p©ep°naáe
         xor       bx,bx
         mov       ax,cs:[FindLine]
         sub       ax,cs:[TopLine]          ; offset od poá†tku obrazovky
         inc       ax                       ; p©ednastaven°
         mov       cs:[FindLin0],ax         ; á°taá k zobrazen° nalezenÇho ©†dku
         cld

; ------ p©°prava k zobrazen° bloku

         mov       word ptr cs:[Blok1Cit],-1 ; blok vypnut
         mov       word ptr cs:[Blok2Cit],-1 ; blok vypnut
         and       byte ptr cs:[Param],not 10h ; vypnut° bloku
         test      byte ptr cs:[Param],20h  ; je blok vypnut ?
         jz        Disp1                    ; blok je vypnut

         mov       ax,cs:[Blok1Lin]         ; ©†dek poá†tku bloku
         mov       cx,cs:[Blok2Lin]         ; ©†dek konce bloku
         cmp       ax,cx                    ; je konec za zaá†tkem ?
         jbe       Disp02                   ; po©ad° je OK
         xchg      ax,cx                    ; oprava po©ad°
Disp02:  sub       ax,cs:[TopLine]          ; offset od poá†tku
         jae       Disp03                   ; nen° podteáen°
         xor       byte ptr cs:[Param],10h  ; zmàna p©°znaku
Disp03:  inc       ax
         mov       cs:[Blok1Cit],ax         ; á°taá poá†tku
         inc       cx
         sub       cx,cs:[TopLine]          ; offset od poá†tku
         jae       Disp04                   ; nen° podteáen°
         xor       byte ptr cs:[Param],10h  ; zmàna p©°znaku
Disp04:  inc       cx
         mov       cs:[Blok2Cit],cx         ; á°taá konce

; ------ obsluha zobrazen° bloku

Disp1:   dec       word ptr cs:[Blok1Cit]   ; á°taá poá†tku bloku
         jnz       Disp11                   ; nen° poá†tek bloku
         xor       byte ptr cs:[Param],10h  ; p©°znak ©†dku uvnit© bloku
Disp11:  dec       word ptr cs:[Blok2Cit]   ; á°taá konce bloku
         jnz       Disp14                   ; nen° konec bloku
         xor       byte ptr cs:[Param],10h  ; p©°znak ©†dku uvnit© bloku

; ------ stanoven° barvy ©†dku, p©°prava k zobrazen° ©†dku

Disp14:  mov       ah,cs:[Barva1]           ; barva ©†dku s nalezenòm textem
         dec       word ptr cs:[FindLin0]   ; á°taá nalezenÇho ©†dku
         jz        Disp2                    ; je to nalezenò ©†dek
         test      byte ptr cs:[Param],10h  ; je to ©†dek uvnit© bloku ?
         jnz       Disp2                    ; je to ©†dek uvnit© bloku
         mov       ah,cs:[Barva]            ; barva bàënÇho ©†dku
Disp2:   mov       cx,cs:[TopPoz]           ; poá†teán° pozice ©†dku
         mov       cs:[TopPoz0],cx          ; á°taá poá†teán° pozice ©†dku
         mov       cx,80                    ; poáet znakñ na ©†dek

; ------ zobrazen° textu ©†dku

Disp3:   cmp       si,bp                    ; je koncovò offset ?
         je        Disp36                   ; je koncovò offset
Disp300: lodsb                              ; naáten° znaku
         or        si,si                    ; je p©eteáen° segmentu ?
         jz        Disp31                   ; je p©eteáen° segmentu
Disp30:  cmp       al,10                    ; je konec ©†dku LF ?
         je        Disp4                    ; je konec ©†dku LF
         cmp       al,13                    ; je CR ?
         je        Disp3                    ; CR se ignoruje
         jcxz      Disp3                    ; je jië konec ©†dku
         cmp       al,9                     ; je tabel†tor ?
         je        Disp32                   ; zobrazen° tabel†toru

; ------ filtr znakñ

         dec       word ptr cs:[TopPoz0]    ; á°taá poá†teán° pozice
         jns       Disp3                    ; znak se nezobraz°
         mov       bl,al                    ; znak ke konverzi
         mov       al,cs:[bx+Filtr]         ; konverze znaku
         stosw                              ; uloëen° znaku
         dec       cx
         jmp       short Disp3

; ------ posun segmentu adresy

Disp31:  push      ax
         mov       ax,ds                    ; segment adresy
         add       ax,1000h                 ; posun segmentu adresy
         mov       ds,ax                    ; novò segment adresy
         pop       ax
         jmp       short Disp30

; ------ zobrazen° tabel†toru

Disp32:  mov       al," "                   ; zobraz° se mezera
Disp33:  dec       word ptr cs:[TopPoz0]    ; á°taá poá†teán° pozice
         jns       Disp34                   ; znak se nezobraz°
         stosw                              ; uloëen° znaku mezery
         dec       cx                       ; sn°ëen° á°taáe znakñ
         jz        Disp3
Disp34:  push      ax
         mov       al,byte ptr cs:[TopPoz]
         sub       al,byte ptr cs:[TopPoz0]
         test      al,7
         pop       ax
         jnz       Disp33                   ; nen° tabelaán° pozice - dal®° znak
         jmp       short Disp3


; ------ je koncovò offset - test, zda je tÇë koncovò segment

Disp36:  push      ax
         mov       ax,ds                    ; segment adresy
         cmp       ax,cs:[MaxSegm]          ; je koncovò segment ?
         pop       ax
         jne       Disp300                  ; nen° koncovò segment

; ------ vymaz†n° zbytku ©†dku

Disp4:   mov       al," "                   ; znak mezery k vymaz†n°
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ p©°prava k zobrazen° dal®°ho ©†dku

         dec       dh                       ; á°taá ©†dkñ k zobrazen°
         jz        Disp6
         jmp       Disp1                    ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

Disp6:   pop       es
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
;        vypnut° kurzoru
; -----------------------------------------------------------------------------

KurzOff  PROC      NEAR

         push      ax
         push      dx

         mov       dl,0
         mov       dh,cs:[Radku]
         mov       ah,2
         call      Int10P

         pop       dx
         pop       ax
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10P   PROC      NEAR

         push      bx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         mov       bh,cs:[AktPage]
         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       bx
         ret

Int10P   ENDP

; *****************************************************************************
;
;                   Dek¢dov†n° p©°kazovÇho ©†dku
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        rozbor p©°kazovÇho ©†dku (CY=chyba zad†n°)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©°prava p©°kazovÇho ©†dku

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       bl,ds:[si-1]             ; dÇlka textu p©°kazovÇho ©†dku
         and       bl,7fh                   ; pojistka
         mov       bh,0
         mov       byte ptr ds:[bx+si],0    ; oznaáen° konce textu
         push      ds
         pop       es

; ------ rozbor parametrñ na zaá†tku

         call      ParPar                   ; rozbor parametrñ
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor jmÇna vstupn°ho souboru

         mov       di,offset Soubor1        ; jmÇno vstupn°ho souboru
         call      ParFil                   ; rozbor jmÇna vstupn°ho souboru
         jc        Rozbor9                  ; nen° zad†n - chyba
         mov       ds:[ADrSoub],bx          ; £schova adresy jmÇna souboru

; ------ rozbor parametrñ

         call      ParPar                   ; rozbor parametrñ
         jc        Rozbor9                  ; chyba zad†n°

; ------ rozbor jmÇna vòstupn°ho souboru

         mov       di,offset Soubor2        ; buffer jmÇna vòstupn°ho souboru
         call      ParFil                   ; rozbor jmÇna vòstupn°ho souboru
         jc        Rozbor8                  ; vòstupn° soubor nen° zad†n
         or        byte ptr ds:[Param],8    ; p©°znak zad†n° vòstupn°ho souboru

; ------ rozbor parametrñ

         call      ParPar                   ; rozbor parametrñ
         jc        Rozbor9                  ; chyba zad†n°

Rozbor8: clc
Rozbor9: ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        parametry (CY=chyba zad†n°)
; -----------------------------------------------------------------------------

ParPar   PROC      NEAR

; ------ nalezen° zaá†tku parametrñ

         call      ParSpc
         jc        ParPar8
         cmp       al,"/"
         jne       ParPar8

; ------ naáten° znaku parametru

         call      ParChr
         call      ParChr
         cmp       al,"G"
         jne       ParPar5

; ------ nalezen° zaá†tku textu hesla

         call      ParSpc
         jc        ParPar8
         cmp       al,'"'
         jne       ParPar8
         call      ParChr

; ------ p©enesen° textu hesla

         push      di
         mov       di,offset Heslo
ParPar2: call      ParChr
         jc        ParPar4
         cmp       al,'"'
         je        ParPar4
         cmp       di,offset Heslo+40
         jae       ParPar3
         mov       ds:[di],al
         inc       di
ParPar3: jmp       short ParPar2
ParPar4: sub       di,offset Heslo
         mov       ds:[HesloN],di
         pop       di
         jmp       short ParPar             ; dal®° parametr

; ------ zad†n° n†rodn°ho k¢du

ParPar5: mov       dl,0
         cmp       al,"K"
         je        ParPar6                  ; je k¢d Kamenickòch
         inc       dx
         cmp       al,"L"
         je        ParPar6                  ; je k¢d Latin 2
         inc       dx
         cmp       al,"I"
         jne       ParPar7                  ; nen° ani k¢d KOI 8 - chyba zad†n°
ParPar6: mov       byte ptr ds:[Prepin],dl  ; p©ep°naá n†rodn°ho k¢du
         jmp       short ParPar             ; dal®° parametr

; ------ chyba zad†n°

ParPar7: stc
         ret

ParPar8: clc
ParPar9: ret

ParPar   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° jmÇna souboru ES:DI (BX=adresa jmÇna)
; -----------------------------------------------------------------------------

ParFil   PROC      NEAR

; ------ nalezen° zaá†tku jmÇna souboru

         call      ParSpc
         jc        ParFil9
         cmp       al,"/"
         stc
         je        ParFil9

; ------ p©enesen° jmÇna souboru do bufferu

ParFil1: mov       bx,di                    ; adresa jmÇna souboru
ParFil2: call      ParChr
         cld
         jc        ParFil4
         je        ParFil3
         cmp       al,"/"
         je        ParFil3
         stosb
         cmp       al,":"
         je        ParFil1
         cmp       al,"\"
         je        ParFil1
         jmp       short ParFil2

; ------ ukonáen° jmÇna

ParFil3: dec       si
parFil4: mov       al,0
         stosb
         clc

ParFil9: ret

ParFil   ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; vstup znaku z p©°kazovÇho ©†dku
         jc        ParSpc2                  ; konec textu
         je        ParSpc                   ; mezera - vypu®tàn°
         dec       si                       ; n†vrat posledn°ho znaku
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ naáten° znaku z p©°kazovÇho ©†dku

         cld
         lodsb                              ; naáten° znaku z p©°kazovÇho ©†dku

; ------ n†hrada znaku velkòm p°smenem

         call      UpCase

; ------ n†hrada tabel†toru mezerou

         cmp       al,9
         jne       ParChr2
         mov       al," "                   ; n†hrada tabel†toru mezerou

; ------ test, zda je konec textu

ParChr2: cmp       al," "                   ; je platnò znak ?
         jae       ParChr3                  ; nen° konec textu
         dec       si                       ; n†vrat posledn°ho znaku

ParChr3: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        inicializace tabulek fontñ
; -----------------------------------------------------------------------------

InitTab  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

; ------ konverze vlastn°ch textñ

         mov       al,"|"
         mov       bl,"-"
         mov       bh,"#"
         test      byte ptr ds:[ParamC],4   ; vypnuta áe®tina ?
         jnz       InitTb00                 ; vypnuta áe®tina

         mov       al,ds:[ParamC]
         and       al,3
         cmp       al,2                     ; je k¢d KOI 8 ?

         mov       al,179                   ; á†ra Kamenickòch
         mov       bl,176                   ; kurzor 1
         mov       bh,178                   ; kurzor 2

         jne       InitTb00                 ; nen° KOI 8

         mov       al,231                   ; á†ra KOI 8
         mov       bl,141                   ; kurzor 1
         mov       bh,159                   ; kurzor 2

InitTb00:mov       byte ptr ds:[Nadpis],al  ;
         mov       byte ptr ds:[GRAFX1],al
         mov       byte ptr ds:[GRAFX2],al
         mov       byte ptr ds:[GRAFX3],bl  ; kurzor 1
         mov       byte ptr ds:[GRAFX4],bh  ; kurzor 2
         mov       byte ptr ds:[GRAFX5],al

; ------ tabulka pro p©evod na velk† p°smena

         mov       bl,byte ptr ds:[ParamC]  ; k¢d displeje
         and       bx,3                     ; k¢d displeje

;                                          ;* oprava KOI 8 podle displeje
;         mov       ax,offset TbKOICS0       ; k¢d s KOI 8
;         cmp       bl,2                     ; je KOI 8 ?
;         je        InitTb08                 ; je KOI 8
;         mov       ax,offset TbKOICS1       ; je k¢d bez KOI 8
;InitTb08:mov       ds:[TXK1],ax
;         mov       ds:[TXK2],ax

         mov       al,byte ptr ds:[Prepin]  ; p©ep°naáe ze souboru
         and       al,3                     ; p©ep°naáe
         cmp       al,3                     ; je k¢d IBM ?
         jne       InitTb01                 ; nen° k¢d IBM
         or        bl,3                     ; pro k¢d IBM se nek¢duje
InitTb01:shl       bl,1                     ; offset v tabulce adres
         mov       si,ds:[bx+TabUpC]        ; adresa konverzn° tabulky

; ------ £schova tabulky pro velk† p°smena

         push      ds
         pop       es
         mov       di,offset FiltrU0
         mov       cx,128
         cld
         rep       movsb                    ; £schova tabulky

; ------ tabulka pro odstranàn° diakritiky p©i zad†n°

         test      byte ptr ds:[ParamC],4   ; je filtr áe®tiny ?
         jnz       InitTb02                 ; je filtr áe®tiny
         or        bl,6                     ; nen° filtr - nekonvertuje se
InitTb02:mov       si,ds:[bx+TabCS0]        ; filtr odstranàn° diakritiky

; ------ £schova tabulky pro odstranàn° diakritiky p©i zad†n°

         mov       di,offset FiltrZ0
         mov       cx,128
         rep       movsb                    ; £schova tabulky

; ------ tabulka pro zobrazen°

         mov       bl,byte ptr ds:[Prepin]  ; p©ep°naáe ze souboru
         and       bx,3                     ; k¢d souboru
         mov       al,ds:[ParamC]           ; souáasnÇ nastaven° displeje
         test      al,4                     ; je vypnuta áe®tina ?
         jz        InitTab1                 ; nen° vypnuta
         or        al,3                     ; k¢d vypnut°
InitTab1:and       al,3                     ; k¢d zobrazen°
         shl       bl,1                     ; offset v tabulce adres
         shl       bl,1
         or        bl,al
         shl       bl,1

; ------ £schova tabulky pro zobrazen°

         mov       si,ds:[bx+TabDisp]       ; adresa konverzn° tabulky
         mov       di,offset Filtr0
         mov       cx,128
         rep       movsb                    ; £schova tabulky

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         call      KonvFND                  ; konverze textu pro hled†n°
         ret

InitTab  ENDP

; -----------------------------------------------------------------------------
;        konverze zad†vanÇho textu
; -----------------------------------------------------------------------------

KonvFND  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ konverze textu

         xor       bx,bx
         mov       cx,MAXFND                ; dÇlka textu
         mov       si,offset FndTxt         ; buffer hledanÇho textu
         cld
KonvFND1:lodsb                              ; naáten° znaku
         mov       bl,al                    ; offset v tabulce
         mov       bl,ds:[bx+FiltrZ]        ; odstranàn° diakritiky
         mov       al,ds:[bx+FiltrU]        ; p©evod na velkÇ p°smeno
         mov       ds:[si+FndTxt0-FndTxt-1],al ; uloëen° znaku do tabulky
         loop      KonvFND1                 ; dal®° znak

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

KonvFND  ENDP

; -----------------------------------------------------------------------------
;        zad†n° hesla k dek¢dov†n° souboru (CY=p©eru®en° operace)
; -----------------------------------------------------------------------------
;˛
ZadHesl  PROC      NEAR

; ------ test, zda m† bòt heslo zad†no

         test      byte ptr cs:[Prepin],4   ; je soubor k¢dov†n heslem ?
         jnz       ZadHesl1                 ; soubor je k¢dov†n heslem
         ret

; ------ £schova registrñ

ZadHesl1:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

         push      cs
         pop       ds

; ------ test, zda bylo heslo jië zad†no

         cmp       byte ptr ds:[HesloN],0   ; bylo heslo jië zad†no ?
         jne       ZadHesl5                 ; heslo jië bylo zad†no

; ------ zobrazen° vòzvy k zad†n° hesla

         mov       dx,offset HesloTxt
         mov       ah,9
         int       21h                      ; zobrazen° vòzvy k zad†n° hesla

; ------ p©°prava k zad†v†n° hesla

         mov       si,offset Heslo          ; buffer k zad†v†n° hesla

; ------ vstup znaku z kl†vesnice

ZadHesl2:mov       ah,0
         int       16h

; ------ ukonáen° zad†v†n° hesla

         cmp       al,0dh
         je        ZadHesl4

; ------ p©eru®en° operace ESC, Ctrl-Break

         or        ax,ax
         jz        ZadHes22
         cmp       al,1bh
         jne       ZadHes23
ZadHes22:stc
         jmp       short ZadHesl9

; ------ zru®en° jednoho znaku

ZadHes23:cmp       al,8
         je        ZadHes24
         cmp       ax,0e7fh
         jne       ZadHes25
ZadHes24:cmp       si,offset Heslo
         jbe       ZadHesl2
         call      DelCh
         dec       si
         jmp       short ZadHesl2

; ------ zad†n° jednoho znaku

ZadHes25:cmp       al," "
         jb        ZadHesl2
         cmp       si,offset Heslo + 40
         jae       ZadHesl2
         call      UpCase
         mov       ds:[si],al
         inc       si
         mov       al,"*"
         call      DispCh
         jmp       short ZadHesl2

; ------ £schova dÇlky zadanÇho textu

ZadHesl4:sub       si,offset Heslo
         jbe       ZadHes22                 ; nen° nic zad†no - p©eru®en°
         mov       ds:[HesloN],si           ; dÇlka hesla

; ------ vymaz†n° textu

         mov       cx,si                    ; dÇlka textu hesla
         add       cx,offset(HesloTx0-HesloTxt)-1
ZadHes42:call      DelCh
         loop      ZadHes42

; ------ sestaven° k¢dovac°ho kl°áe

ZadHesl5:mov       cx,ds:[HesloN]           ; dÇlka textu hesla
         mov       di,offset Klic           ; k¢dovac° kl°á
         mov       bx,257                   ; dÇlka k¢dovac°ho kl°áe
         mov       dx,-1                    ; vòchoz° hodnota k¢du

; ------ vòpoáet k¢dovac°ho kl°áe

ZadHesl7:mov       si,offset Heslo          ; buffer s textem hesla
         call      CheckSum                 ; kontroln° souáet kl°áe
         mov       ds:[di],dl               ; nië®° bajt kontroln°ho souátu
         inc       di                       ; zvò®en° ukl†dac° adresy v kl°ái
         dec       bx                       ; á°taá dÇlky kl°áe
         jnz       ZadHesl7                 ; dal®° znak kl°áe

         call      Dekod                    ; prvn° dek¢dov†n° bufferu
         clc

; ------ n†vrat registrñ

ZadHesl9:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ZadHesl  ENDP

; -----------------------------------------------------------------------------
;        Kontroln° souáet CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=zaá†tek bloku dat
;        CX=poáet bajtñ
;        DX=vstupn° hodnota kontroln°ho souátu
; VùSTUP:DX=vòstupn° hodnota kontroln°ho souátu
; -----------------------------------------------------------------------------

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      CheckSm2                 ; nejsou ë†dn† data
         mov       di,cx                    ; poáet bajtñ pro kontroln° souáet
         cld                                ; smàr nahoru

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
         jnz       CheckSm1                 ; dal®° bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP

; -----------------------------------------------------------------------------
;        zru®en° znaku DOS
; -----------------------------------------------------------------------------

DelCh    PROC      NEAR

         push      ax
         mov       al,8
         call      DispCh
         mov       al," "
         call      DispCh
         mov       al,8
         call      DispCh
         pop       ax
         ret

DelCh    ENDP

; -----------------------------------------------------------------------------
;        zobrazen° znaku DOS
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

         push      ax
         push      dx
         mov       dl,al
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        konverze znaku na velkÇ p°smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; *****************************************************************************
;
;                                data
;
; *****************************************************************************

Blok1Adr dd        0                        ; adresa zaá†tku bloku
Blok1Lin dw        0                        ; ©†dek zaá†tku bloku
Blok1Cit dw        0                        ; á°taá ©†dku zaá†tku bloku

Blok2Adr dd        0                        ; adresa konce bloku
Blok2Lin dw        0                        ; ©†dek konce bloku
Blok2Cit dw        0                        ; á°taá ©†dku konce bloku

Param    db        0                        ; parametry
                                            ;  bit 2: 1=vyti®tàn° bloku
                                            ;  bit 3: 1=zad†n vòstupn° soubor
                                            ;  bit 4: 1=©†dek je uvnit© bloku
                                            ;  bit 5: 1=zobrazen° kurzoru bloku
                                            ;  bit 6: 1=reëim hled†n° textu
                                            ;  bit 7: 1=smàr hled†n° zpàt

Prepin   dw        3                        ; p©ep°naáe ze souboru
                                            ;   bit 0,1: 0=k¢d Kamenickòch
                                            ;            1=k¢d Latin 2
                                            ;            2=k¢d KOI 8
                                            ;            3=k¢d IBM
                                            ;   bit 2: 1=soubor zak¢dov†n heslem

                                          ;* tabulky konverz° pro displej
TabDisp  dw        Tb00                     ; KAM -> KAM
         dw        TbKamLat                 ; KAM -> LAT
         dw        TbKamKOI                 ; KAM -> KOI
         dw        TbKamCS0                 ; KAM -> 0

         dw        TbLatKam                 ; LAT -> KAM
         dw        Tb00                     ; LAT -> LAT
         dw        TbLatKOI                 ; LAT -> KOI
         dw        TbLatCS0                 ; LAT -> 0

         dw        TbKOIKam                 ; KOI -> KAM
         dw        TbKOILat                 ; KOI -> LAT
         dw        Tb00                     ; KOI -> KOI
TXK1     dw        TbKOICS0                 ; KOI -> 0

         dw        Tb00                     ; IBM -> KAM
         dw        Tb00                     ; IBM -> LAT
         dw        Tb00                     ; IBM -> KOI
         dw        Tb00                     ; IBM -> 0

                                          ;* tabulky velkòch p°smen displeje
TabUpC   dw        TbKamUpC                 ; Kamenickòch
         dw        TbLatUpC                 ; Latin 2
         dw        TbKOIUpC                 ; KOI 8
         dw        Tb00                     ; IBM

                                          ;* tabulky odstranàn° diakritiky
TabCS0   dw        TbKamCS0                 ; KAM -> 0
         dw        TbLatCS0                 ; LAT -> 0
TXK2     dw        TbKOICS0                 ; KOI -> 0
         dw        Tb00                     ; IBM -> 0

; ------ filtr znakñ pro zobrazen° (z vnit©n°ch fontñ na fonty displeje)

Filtr    db          0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
         db         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
         db         32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
         db         48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
         db         64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
         db         96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
         db        112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127

Filtr0   db        128 dup(0)               ; konverzn° tabulka 128 aë 255

; ------ filtr velkòch p°smen (podle k¢du displeje)

FiltrU   db          0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
         db         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
         db         32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
         db         48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
         db         64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
         db         96, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,123,124,125,126,127

FiltrU0  db        128 dup(0)               ; konverzn° tabulka 128 aë 255

; ------ odstranàn° diakritiky p©i zad†v†n° textu (podle k¢du displeje)

FiltrZ   db          0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
         db         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
         db         32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
         db         48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63
         db         64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79
         db         80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95
         db         96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111
         db        112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127

FiltrZ0  db        128 dup(0)               ; konverzn° tabulka 128 aë 255

; ------ tabulka bez konverze

Tb00     db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na velk† p°smena

TbKamUpC label     byte
         db        'ÄöêÖéÖÜÄââäãúäéè'
         db        'êííßôï¶óùôöõúùûÜ'
         db        'èãïó••¶ßõû´´',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

;; ------ konverzn° tabulka z k¢du Kamenickòch na mal† p°smena
;
;TbKamDnC label     byte
;         db        'áÅÇÉÑÉüáààç°åçÑ†'
;         db        'Çëëìî¢ñ£òîÅ®åò©ü'
;         db        '†°¢£§§ñì®©™™',172,173,174,175
;         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
;         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na velk† p°smena

TbLatUpC label     byte
         db        128,154,144,182,142,222,143,128,157,211,138,138,215,141,142,143
         db        144,145,145,226,153,149,149,151,151,153,154,155,155,157,158,172
         db        181,214,224,233,164,164,166,166,168,168,170,141,172,184,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,189,191
         db        192,193,194,195,196,197,198,198,200,201,202,203,204,205,206,207
         db        209,209,210,211,210,213,214,215,183,217,218,219,220,221,222,223
         db        224,225,226,227,227,213,230,230,232,233,232,235,237,237,221,239
         db        240,241,242,243,244,245,246,247,248,249,250,235,252,252,254,255

;; ------ konverzn° tabulka z k¢du Latin 2 na mal† p°smena
;
;TbLatDnC label     byte
;
;         db        135,129,130,131,132,133,134,135,136,137,139,139,140,171,132,134
;         db        130,146,146,147,148,150,150,152,152,148,129,156,156,136,158,159
;         db        160,161,162,163,165,165,167,167,169,169,170,171,159,173,174,175
;         db        176,177,178,179,180,160,131,216,173,185,186,187,188,190,190,191
;         db        192,193,194,195,196,197,199,199,200,201,202,203,204,205,206,207
;         db        208,208,212,137,212,229,161,140,216,217,218,219,220,238,133,223
;         db        162,225,147,228,228,229,231,231,234,163,234,251,236,236,238,239
;         db        240,241,242,243,244,245,246,247,248,249,250,251,253,253,254,255

; ------ konverzn° tabulka z k¢du KOI 8 na velk† p°smena

TbKOIUpC label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,225,194,227,228,229,230,199,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,214,247,248,249,250,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

;; ------ konverzn° tabulka z k¢du KOI 8 na mal† p°smena
;
;TbKOIDnC label     byte
;         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
;         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
;         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
;         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
;         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
;         db        224,193,226,195,196,197,198,231,200,201,202,203,204,205,206,207
;         db        208,209,210,211,212,213,246,215,216,217,218,251,252,253,254,255
;
; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d bez diakritiky

TbKamCS0 label     byte
         db        'CuedaDTceELIllAA'
         db        'EzZooOuUyOUSLYRt'
         db        'aiounNUOsrrR',172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
         db        208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d bez diakritiky

TbLatCS0 label     byte
         db        'CueaauccleOoiZAC'
         db        'ELlooLlSsOUTtLxc'
         db        'aiouAaZzEerzCs',174,175
         db        176,177,178,179,180,'AAES',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,207
         db        'dDDEdNIIe',217,218,219,220,'TU',223
         db        'O',225,'ONnnSsRUrUyYt',239
         db        240,241,242,243,244,245,246,247,248,249,250,'uRr',254,255

;; ------ konverzn° tabulka z k¢du KOI 8 na k¢d bez diakritiky - k¢d IBM
;
;TbKoiCS0 label     byte
;         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
;         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
;         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
;         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
;         db        '⁄','a','¿','cder','ƒ','uiullono'
;         db        'oarstu','√','eayz','¬',220,221,222,'≈'
;         db        'ø','A','Ÿ','CDER','≥','UIULLONO'
;         db        'OARSTU','¥','EAYZ','¡',252,253,254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d bez diakritiky

TbKoiCS0 label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        192,'a',194,'cder',199,'uiullono'
         db        'oarstu',214,'eayz',219,220,221,222,223
         db        224,'A',226,'CDER',231,'UIULLONO'
         db        'OARSTU',246,'EAYZ',251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d Kamenickòch

TbLatKam label     byte
         db        'CÅÇaÑñccleôîiZéC'
         db        'êäçìîúåSsôöÜüLxá'
         db        '†°¢£AaíëEeøzÄsÆØ'
         db        176,177,178,179,180,'èAâS',185,186,187,188,'Zz',191
         db        192,193,194,195,196,197,'Aa',200,201,202,203,204,205,206,'x'
         db        'dDÖEÉ•ãIà',217,218,219,220,'T¶',223
         db        'ï',225,'ßNn§õ®´ó™öòùt',39
         db        '-".""≠ˆ,¯"',250,'Åû©',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Kamenickòch

TbKoiKam label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        '⁄†¿áÉà™ƒÅ°ñçåî§¢'
         db        'ìÑ©®ü£√Ç†òë¬',220,39,248,'≈'
         db        'øèŸÄÖâ´≥öã¶äúô•ï'
         db        'ßéûõÜó¥êèùí¡',252,'^',254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d Latin 2

TbKamLat label     byte
         db        172,'ÅÇ',212,'Ñ',210,155,159,216,183,145,214,150,146,'é',181
         db        'ê',167,166,'ìî',224,133,233,236,'ôö',230,149,237,252,156
         db        '†°¢£',229,213,222,226,231,253,234,232,'/',245,174,175
         db        176,177,178,179,180,179,186,187,191,185,186,187,188,188,217,191
         db        192,193,194,195,196,197,179,186,200,201,202,203,204,205,206,205
         db        188,205,196,200,192,218,201,186,205,217,218,219,220,219,219,223
         db        'a',225,'G','p','S','s','m','t','f','T','O','d','0','/','E','N'
         db        '=','+','>','<',218,217,246,'=',248,250,250,'V','n','2',254,255

; ------ konverzn° tabulka z k¢du KOI 8 na k¢d Latin 2

TbKoiLat label     byte
         db        128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
         db        144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
         db        160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
         db        176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
         db        '⁄','†','¿',159,212,216,234,'ƒ',129,'°',133,146,150,148,229,'¢'
         db        147,132,253,231,156,'£','√','Ç','†',236,167,'¬',243, 39,248,'≈'
         db        'ø',181,'Ÿ',172,210,183,232,'≥','ö',214,222,145,149,'ô',213,224
         db        226,142,252,230,155,233,'¥','ê',181,237,166,'¡',249,'^',254,255

; ------ konverzn° tabulka z k¢du Kamenickòch na k¢d KOI 8

TbKamKoi label     byte
         db        227,200,215,196,209,228,244,195,197,229,235,233,204,203,241,225
         db        247,218,250,208,205,239,202,245,217,237,232,243,236,249,242,212
         db        193,201,207,213,206,238,234,240,211,210,198,230,131,173,174,175
         db        176,177,178,231,246,246,246,224,224,246,231,224,226,226,226,224
         db        194,251,219,214,199,223,214,214,194,192,251,219,214,199,223,251
         db        251,219,219,194,194,192,192,223,223,226,192,219,220,221,222,223
         db        224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
         db        240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255

; ------ konverzn° tabulka z k¢du Latin 2 na k¢d KOI 8

TbLatKoi label     byte
         db        128,200,215,'a',209,202,'c','c','l','e',237,208,'i','Z',241,'C'
         db        247,235,203,208,205,236,204,'S','s',237,232,244,212,'L','x',195
         db        193,201,207,213,'A','a',250,218,'E','e',224,'z',227,'s',174,175
         db        176,177,178,231,246,225,'A',229,'S',246,231,224,226,'Z','z',224
         db        194,251,219,214,199,223,'A','a',194,192,251,219,213,199,223,'x'
         db        'd','D',228,'E',196,238,233,'I',197,226,192,219,220,'T',234,223
         db        239,225,240,'N','n',206,243,211,230,245,198,232,217,249,'t', 39
         db        '-',252,'.',220,220,131,':',',',222,252,254,200,242,210,254,255

; ------ parametry textu

         EVEN
RadkuTxt dw        1                        ; celkovò poáet ©†dkñ textu
TopAdr   dd        0                        ; adresa poá†tku str†nky
TopLine  dw        0                        ; á°slo poá†teán°ho ©†dku displeje
TopPoz   dw        0                        ; poá†teán° pozice ©†dku
TopPoz0  dw        0                        ; á°taá poá†teán° pozice ©†dku

FindAdr  dd        0                        ; adresa nalezenÇho ©†dku
FindLine dw        -1                       ; á°slo nalezenÇho ©†dku
FindLin0 dw        0                        ; á°taá nalezenÇho ©†dku k zobrazen°

; ------ parametry displeje

Barva    db        7                        ; barva textu
Barva1   db        70h                      ; vysv°cenò ©†dek
Barva2   db        70h                      ; barva nadpisu
Barva3   db        70h                      ; barva n†povàdy

DispRow  label     word                     ; poáet zobrazenòch ©†dkñ
MaxRow   db        24                       ; posledn° ©†dek na displeji
         db        0                        ; doplnàn° na slovo

Radku    db        25                       ; poáet ©†dkñ displeje
AdrVRAM  dd        0b0000000h               ; adresa videopamàti
AktPage  db        0                        ; aktivn° videostr†nka
OldKurz  dw        0                        ; star† pozice kurzoru

GRAFX3   db        176                      ; kurzor 1
GRAFX4   db        178                      ; kurzor 2

; ------ texty

Nadpis   db        179,' ESC=konec; F1=napoveda '
GRAFX2   db        179,'             0/0'
NadpCis  label     byte
GRAFX5   db        179
Nadpis0  label     byte
         db        0

Nadpis2  db        ' ESC=navrat; ENTER,sipky=hledani '
GRAFX1   db        179,' text:'
Nadpis20 db        0

UvTxt    db        'HLP V1.40 - prohlizec souboru napovedy; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        '    …ÕÕ Zadejte jmeno souboru napovedy k zobrazeni ! ÕÕª',13,10
         db        '    ∫ Zadanim vstupniho i vystupniho jmena souboru se  ∫',13,10
         db        '    ∫   soubor napovedy dekoduje do textoveho tvaru.   ∫',13,10
         db        '    »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',13,10
         db        'Prepinace: /G "heslo" .. prednastaveni dekodovaciho hesla',13,10
         db        '           /K .......... nekomprimovany soubor v kodu Kamenickych',13,10
         db        '           /L .......... nekomprimovany soubor v kodu Latin 2',13,10
         db        '           /I .......... nekomprimovany soubor v kodu KOI 8',13,10
         db        '$'
SoubTxt  db        'Zadany soubor napovedy nenalezen !',13,10,'$'
MemTxt   db        'Chyba - nedostatek pameti !'
CRTxt    db        13,10,'$'
Exis1Txt db        'Vystupni soubor $'
Exis2Txt db        ' jiz existuje !',13,10
         db        'Chcete jej prepsat (A=ano) ? $'
VystTxt  db        'Chybne zadani vystupniho souboru !',13,10,'$'
WritTxt  db        'Chyba zapisu souboru na disk !',13,10,'$'
CelyTxt  db        'VAROVANI: Soubor se nenacetl do pameti cely ! ',7,13,10
         db        '          Stisknete libovolnou klavesu... ',13,10,'$'

ZacTxt   db        ' Nastavte kurzor na prvni radek bloku a stisknete ENTER (ESC=preruseni).',0
KonTxt   db        ' Nastavte kurzor na posledni radek bloku a stisknete ENTER (ESC=preruseni).',0
ZapisTxt db        ' Cekejte, pridavam blok k souboru BLOK.$$$ v aktivnim adresari...',0
ZapErTxt db        ' CHYBA - blok nelze ulozit na disk ! Stisknete libovolnou klavesu...',0

TiskTxt  db        ' Cekejte, tisknu oznaceny blok na tiskarnu...',0
TiskETxt db        ' CHYBA - oznaceny blok nelze vytisknout ! Stisknete libovolnou klavesu...',0

BlokSoub db        'BLOK.$$$',0             ; jmÇno souboru bloku
BlokTisk db        'PRN',0                  ; jmÇno tisk†rny

; ------ velk† n†povàda

MHelpTxt db        '⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ HLP V1.40 ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø'
         db        '≥ ESC ...... opusteni programu, navrat do systemu    ≥'
         db        '≥ ENTER .... vyhledavani textu                       ≥'
         db        '≥              ENTER = vyhledani textu od zacatku    ≥'
         db        '≥              sipka_nahoru/dolu = hledani zpet/vpred≥'
         db        '≥              sipka_vlevo, BS = zruseni 1 znaku     ≥'
         db        '≥              sipka_vpravo = obnoveni 1 znaku textu ≥'
         db        '≥              ESC = opusteni rezimu hledani         ≥'
         db        '≥              HOME = prvni vyskyt retezce           ≥'
         db        '≥              END = posledni vyskyt retezce         ≥'
         db        '≥              PAGE_UP/PAGE_DOWN = posun o stranku   ≥'
         db        '≥ MEZERA ... vypnuti diakritiky (bez hacku a carek)  ≥'
         db        '≥ F2 ....... zobrazeni textu v kodu Kamenickych      ≥'
         db        '≥ F3 ....... zobrazeni textu v kodu Latin 2          ≥'
         db        '≥ F4 ....... zobrazeni textu v kodu KOI 8            ≥'
         db        '≥ F5 ....... ulozeni bloku na disk (do "BLOK.$$$")   ≥'
         db        '≥ F6 ....... vytisteni bloku na tiskarnu             ≥'
         db        '≥ kurzorove klavesy ... posun o radek/pozici         ≥'
         db        '≥ Ctrl-vlevo/vpravo ... posun o 10 pozic vlevo/vpravo≥'
         db        '≥ PAGE_UP/PAGE_DOWN ... posun o stranku              ≥'
         db        '≥ HOME/END ... zacatek/konec textu                   ≥'
MHelpTx0 db        '¿ƒƒƒƒƒƒƒƒƒƒ stisknete libovolnou klavesu ƒƒƒƒƒƒƒƒƒƒƒƒŸ'
MHelpTx1 label     byte

; ------ heslo

HesloN   dw        0                        ; dÇlka hesla
Heslo    db        40 dup(0)                ; text hesla

HesloTxt db        'Zadejte text hesla (ESC=preruseni): $'
HesloTx0 label     byte

Klic     db        257 dup(?)               ; k¢dovac° kl°á hesla

; ------ konfigurace

HLPName  db        'HLP.CNF',0
HLPBuff  db        128 dup(0)               ; jmÇno domovskÇho programu

HLPCnf   db        'HLPCNF1'                ; identifik†tor konfigurace
ParamC   db        0                        ; parametry konfigurace
                                            ;  bit 0,1: k¢d displeje
                                            ;           0=k¢d Kamenickòch
                                            ;           1=k¢d Latin 2
                                            ;           2=k¢d KOI 8
                                            ;  bit 2: 1=zapnut filtr áe®tiny
                                            ;  bit 3: 1=vlastn° fonty CS
                                            ;  bit 4: 1=vypnut horn° ©†dek
         db        0                        ; rezerva

HLPCnf0  db        offset(HLPCnf0-HLPCnf) dup(0) ; uschovan† pñvodn° konfigurace

; ------ datovÇ buffery (buffer s textem je o 1/8 n°ëe neë vstupn° buffer !)

DatSegm  dw        0                        ; adresa bufferu s textem
DatSize  dw        0                        ; velikost bufferu s textem (odst.)
MaxOffs  dw        0                        ; maxim†ln° offset v bufferu
MaxSegm  dw        0                        ; maxim†ln° segment v bufferu

SoubIdnt dw        0                        ; identifik†tor souboru
InpSegm  dw        0                        ; segment vstupn°ho bufferu souboru
InpNum   dw        0                        ; poáet bajtñ ve vstupn°m bufferu
InpSize  dd        0                        ; á°taá velikosti vstupn°ho souboru

FileDate dw        0                        ; uschovanò datum souboru
FileTime dw        0                        ; uschovanò áas souboru
FileAtr  dw        0                        ; atributy souboru

AdrSoub  dw        0                        ; adresa jmÇna souboru
Soubor1  db        128 dup(0)               ; buffer jmÇna souboru 1
Soubor2  db        128 dup(0)               ; buffer jmÇna souboru 2

FndNum   dw        0                        ; dÇlka zadanÇho textu
FndTxt   db        MAXFND dup(" ")          ; buffer hledanÇho textu
FndTxt0  db        MAXFND dup(" ")          ; pracovn° buffer hledanÇho textu

; *****************************************************************************
;
;                            Z†sobn°k
;
; *****************************************************************************

; ------ z†sobn°k

         dw        200h dup(?)              ; z†sobn°k
Zasob    label     near

ViewEnd  label     near                     ; konec programu

Code     ENDS
         END       Start

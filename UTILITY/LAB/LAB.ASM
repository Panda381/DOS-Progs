

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                           jmenovka diskety
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞




; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         org       100h

; ------ p©edefinov†n° z†sobn°ku

Start:   cmp       sp,offset Zasob
         jb        Startx01
         mov       sp,offset Zasob

; ------ zmen®en° velikosti programu

         mov       ah,4ah
         mov       bx,(offset(Zasob-Start)+10fh)/16
         int       21h                      ; zmen®en° velikosti programu
         jnc       Startx03                 ; operace OK

; ------ chyba - nedostatek pamàti

Startx01:mov       dx,offset MemTxt
         mov       ah,9
         int       21h
         int       20h

; ------ implicitn° aktivn° disk

Startx03:mov       ah,19h
         int       21h
         mov       dh,al                    ; £schova pñvodn°ho disku
         mov       dl,al                    ; implicitn° disk

; ------ nalezen° oznaáen° disku v p©°kazovÇm ©†dku

         mov       si,81h
         mov       ch,0
         mov       cl,ds:[si-1]             ; dÇlka textu
Start001:jcxz      Start003                 ; nen° dal®° znak
         cld
         lodsb
         dec       cx
         cmp       al," "
         jbe       Start001

         cmp       al,"a"
         jb        Start002
         cmp       al,"z"
         ja        Start002
         sub       al,32
Start002:sub       al,"A"                   ; á°slo disku
         mov       dl,al                    ; poëadovanò disk

; ------ pokusnÇ nastaven° zadanÇho disku

Start003:mov       ah,0eh
         int       21h                      ; nastaven° poëadovanÇho disku
         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         mov       bl,al                    ; skuteánò disk
         xchg      dh,dl                    ; pñvodn° disk
         mov       ah,0eh
         int       21h                      ; n†vrat pñvodn°ho disku
         cmp       bl,dh                    ; je zadanò disk platnò ?
         je        Start004                 ; disk je platnò

; ------ chybnÇ zad†n° disku

         mov       dx,offset Disktxt
         mov       ah,9
         int       21h
         int       20h

; ------ nastaven° parametrñ pro zadanò disk

Start004:inc       dh
         mov       dl,dh                    ; poëadovanò disk
         mov       ds:[FCBNovD],dh          ; disk novÇho n†và®t° v FCB
         mov       ds:[FCBStrD],dh          ; disk starÇh n†và®t° v FCB
         add       dh,"A"-1                 ; korekce na znak ASCII
         mov       ds:[All],dh              ; oznaáen° disku
         mov       ds:[OldPath],dh          ; pñvodn° adres†© disku
         mov       ds:[Root],dh             ; z†kladn° adres†© disku

; ------ £schova aktivn°ho adres†©e disku

         mov       ah,47h
         mov       si,offset OldPath + 3    ; buffer pñvodn°ho adres†©e
         int       21h                      ; £schova pñvodn°ho adres†©e
         jnc       Start006                 ; operace OK
Start005:int       20h                      ; p©i chybà konec

; ------ instalace obsluh p©eru®en°

Start006:mov       ax,2523h
         mov       dx,offset INT23
         int       21h
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h

; ------ nastaven° z†kladn°ho adres†©e

         mov       dx,offset Root
         mov       ah,3bh
         int       21h                      ; nastaven° z†kladn°ho adres†©e
         jc        Start005                 ; diskov† chyba - konec

; ------ inicializace videom¢du

         call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du

; ------ vytvo©en° bufferu pro obrazovku

         mov       al,80                    ; poáet znakñ na ©†dek
         mul       byte ptr ds:[Radku]      ; vòpoáet dÇlky videostr†nky
         mov       cx,ax                    ; dÇlka videostr†nky (slov)
         mov       bx,ax                    ; dÇlka videostr†nky (slov)
         add       bx,7                     ; zaokrouhlen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na odstavce
         mov       ah,48h
         int       21h                      ; vytvo©en° bufferu obrazovky
         jnc       Start01                  ; operace OK

; ------ nedostatek pamàti

Start00: mov       dx,offset MemTxt
         mov       ah,9
         int       21h
         jmp       Main0                    ; n†vrat

; ------ £schova obsahu obrazovky

Start01: push      ds
         mov       ds:[ObrSegm],ax          ; adresa bufferu
         mov       ds:[ObrSize],cx          ; £schova velikosti vieostr†nky
         xor       di,di                    ; ukl†dac° adresa
         mov       es,ax                    ; adresa bufferu
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds
         push      ds
         pop       es

; ------ £schova kurzoru

         call      GetKurz                  ; poskytnut° pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ oprava barev pro monochromatickò displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Start1

         mov       byte ptr ds:[Barva2],7
         mov       byte ptr ds:[Barva4],70h

; ------ zobrazen° a editace

Start1:

; ------ poá†teán° pozice

         mov       dl,(80-21)/2
         mov       dh,ds:[Radku]
         sub       dh,5
         shr       dh,1
         mov       ds:[Pozice],dx

         jmp       Lab


; ------ n†vrat z programu

INT23:
Main0:   push      cs
         pop       ds

         cmp       word ptr ds:[ObrSize],0  ; je uschovan† obrazovka ?
         je        Main01                   ; nen° uschovan† obrazovka

         call      PopScr                   ; n†vrat obsahu obrazovky

Main01:  mov       dx,offset OldPath        ; pñvodn° adres†© disku
         mov       ah,3bh
         int       21h                      ; n†vrat pñvodn°ho adres†©e

         int       20h                      ; n†vrat z programu


INT24    PROC      FAR

         mov       al,0
         iret

INT24    ENDP


; -----------------------------------------------------------------------------
;        n†vrat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

         push      ds
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       cx,ds:[ObrSize]          ; velikost videopamàti
         xor       si,si
         mov       ds,ds:[ObrSegm]          ; adresa bufferu
         cld
         rep       movsw                    ; n†vrat obsahu obrazovky
         pop       ds

         mov       dx,ds:[OldKurz]          ; pñvodn° pozice kurzoru
         call      SetKurz                  ; n†vrat pozice kurzoru

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

PopScr   ENDP

; *****************************************************************************
;                             Lab
;                    obsluha jmenovky disku
; -----------------------------------------------------------------------------
; *****************************************************************************

;˛

Lab:
         push      ds
         pop       es

; ------ nastaven° adresy DTA

         mov       dx,offset BufDTA         ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven° DTA

; ------ nalezen° jmenovky disku

         mov       dx,offset All
         mov       ah,4eh
         mov       cx,8                     ; atribut n†và®t° disku
         int       21h
         jc        Lab09                    ; nenalezeno
         or        byte ptr ds:[Param],1    ; p©°znak, ëe bylo n†và®t°

; ------ dek¢dov†n° jmenovky disku

         mov       si,offset BufDTA + 1eh   ; jmÇno souboru
         mov       di,offset LabTxt
         cld
Lab02:   lodsb
         cmp       al,0
         je        Lab04
         cmp       al,"."
         jne       Lab03
         mov       di,offset LabTxt+8
         jmp       short Lab02
Lab03:   stosb
         jmp       short Lab02

; ------ kopie do starÇho jmÇna

Lab04:   mov       si,offset LabTxt
         mov       di,offset FCBStrT
         mov       cx,11
         cld
         rep       movsb
         jmp       short Lab09



; ------ vypnut° okna ^O

Lab08:   call      PopScr
         mov       ah,0
         int       16h

Lab09:
         mov       si,offset HlpTxt
         call      DispHlp                  ; zobrazen° n†povàdy

; ------ editace jmenovky disku

Lab1:    call      DispLab                  ; zobrazen° volby
Lab2:    call      InpChr

; ------ platnò znak

         cmp       bl," "
         jb        Lab3

         or        byte ptr ds:[Param],2    ; p©°znak modifikace
         mov       si,word ptr ds:[Kurz]
         mov       byte ptr ds:[si+LabTxt],bl ; uloëen° znaku
         mov       bx,4d00h                 ; n†hrada kurzorem vpravo

Lab3:    call      JumpBX

         dw        8,Lab8                   ; BS
         dw        4b00H,Lab4               ; kurzor vlevo
         dw        4d00h,Lab5               ; kurzor vpravo
         dw        4700h,Lab6               ; HOME
         dw        4f00h,Lab7               ; END
         dw        5300h,Lab9               ; DELETE
         dw        5200h,LabA               ; INSERT

         dw        1bh,Main0                ; p©eru®en° ESC
         dw        0fh,Lab08                ; vypnut° okna

         dw        0dh,LabX                 ; konec editace ENTER

         dw        0,Lab2

; ------ kurzor vlevo

Lab4:    cmp       byte ptr ds:[Kurz],0
         je        Lab1
         dec       byte ptr ds:[Kurz]
Lab11:   jmp       short Lab1

; ------ kurzor vpravo

Lab5:    cmp       byte ptr ds:[Kurz],10
         je        Lab11
         inc       byte ptr ds:[Kurz]
         jmp       short Lab11

; ------ HOME

Lab6:    mov       byte ptr ds:[Kurz],0
         jmp       short Lab11

; ------ END

Lab7:    mov       byte ptr ds:[Kurz],10
         mov       si,offset LabTxt+10
         cmp       byte ptr ds:[si]," "
         jne       Lab11
Lab72:   cmp       byte ptr ds:[si-1]," "
         jne       Lab11
         dec       si
         dec       byte ptr ds:[Kurz]
         jz        Lab11
         jmp       short Lab72

; ------ BS

Lab8:    cmp       byte ptr ds:[Kurz],0
         je        Lab11

         dec       byte ptr ds:[Kurz]

; ------ DELETE

Lab9:    mov       si,word ptr ds:[Kurz]
         or        byte ptr ds:[Param],2    ; p©°znak modifikace
         mov       cx,10
         sub       cx,si                    ; dÇlka zbytku textu
         add       si,offset LabTxt
         mov       di,si
         inc       si
         cld
         push      ds
         pop       es
         rep       movsb
         mov       al," "
         stosb
         jmp       short Lab11

; ------ INSERT

LabA:    mov       di,offset LabTxt+10
         mov       si,di
         dec       si
         std
         mov       cx,10
         sub       cl,ds:[Kurz]
         push      ds
         pop       es
         rep       movsb
         mov       al," "
         stosb
         jmp       short Lab11

; ------ ENTER

; ------ kontrola, zda bylo n†và®t° modifikov†no

LabX:    test      byte ptr ds:[Param],2    ; bylo n†và®t° modifikov†no ?
         jnz       LabX1                    ; byla modifikace
         jmp       Main0

; ------ zru®en° starÇho n†và®t°

LabX1:   test      byte ptr ds:[Param],1    ; bylo n†và®t° ?
         jz        LabX2                    ; nebylo n†và®t°

         mov       ah,13h
         mov       dx,offset FCBStar        ; FCB starÇho n†và®t°
         int       21h                      ; zru®en° starÇho n†và®t°
         inc       al                       ; soubor zru®en ?
         jnz       LabX2                    ; soubor zru®en OK

; ------ chyba - starÇ n†và®t° nelze zru®it

         mov       si,offset StarTxt
         call      Chyba
LabX11:  jmp       Main0                    ; konec

; ------ kontrola, zda je nàjakÇ n†và®t°

LabX2:   and       byte ptr ds:[Param],not 1 ; zru®en° p©°znaku starÇho n†và®t°
         push      ds
         pop       es
         mov       di,offset LabTxt
         mov       cx,11
         mov       al," "
         cld
         repe      scasb                    ; jsou jenom mezery ?
         je        LabX11                   ; jsou jenom mezery

; ------ p©irazen° n†và®t° k levÇmu okraji

LabX21:  cmp       byte ptr ds:[LabTxt]," " ; je vlevo mezera ?
         jne       LabX27                   ; nen° mezera - OK
         mov       si,offset LabTxt+1
         mov       di,offset LabTxt
         mov       cx,10
         cld
         rep       movsb                    ; p©°sun textu n†và®t°
         mov       al," "
         stosb                              ; na konci mezera

         cmp       byte ptr ds:[Kurz],0
         je        LabX22
         dec       byte ptr ds:[Kurz]
LabX22:  call      DispLab                  ; zobrazen° volby
         jmp       short LabX21             ; dal®° p©°sun

; ------ vytvo©en° novÇho n†và®t°

LabX27:  mov       ah,16h
         mov       dx,offset FCBNove        ; novÇ n†và®t°
         int       21h                      ; vytvo©en° novÇho n†và®t°
         inc       al                       ; n†và®t° vytvo©eno OK ?
         jnz       LabX4                    ; n†và®t° vytvo©eno OK

; ------ chyba - n†và®t° nelze vytvo©it

LabX3:   mov       si,offset VytvTxt
         call      Chyba
         jmp       Lab09                    ; pokraáov†n° v zad†v†n°

; ------ uzav©en° souboru n†và®t°

LabX4:   mov       ah,10h
         mov       dx,offset FCBNove
         int       21h                      ; uzav©en° souboru
         inc       al
         jz        LabX3                    ; nàjak† chyba

         jmp       Main0

; *****************************************************************************
;                             Chyba
;                         chybovÇ hl†®en°
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text chybovÇho hl†®en°
; *****************************************************************************

Chyba    PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         call      DispHlp
         mov       ax,0e07h
         mov       bx,7
         call      Int10P                   ; chybovÇ p°pnut°

Chyba1:  mov       ah,1
         int       16h
         jz        Chyba2
         mov       ah,0
         int       16h
         jmp       short Chyba1

Chyba2:  mov       ah,0
         int       16h

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Chyba    ENDP

; *****************************************************************************
;                            DispLab
;                     zobrazen° okna volby
; -----------------------------------------------------------------------------
; *****************************************************************************

DispLab  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

         push      ds
         pop       es

; ------ zobrazen° horn°ho okraje

         mov       dx,ds:[Pozice]
         push      dx
         mov       ah,ds:[Barva1]           ; barva r†mu
         mov       al," "
         call      Disp1Chr                 ; mezera
         mov       al,201
         call      Disp1Chr                 ; levò horn° roh
         mov       al,205
         mov       cl,17
         call      DispChr                  ; horn° linka
         mov       al,187
         call      Disp1Chr                 ; pravò horn° roh
         mov       al," "
         call      Disp1Chr                 ; mezera
         pop       dx
         inc       dh

; ------ zobrazen° ©†dku s textem

         push      dx
         mov       al," "
         call      Disp1Chr                 ; mezera
         mov       al,186
         call      Disp1Chr                 ; levò okraj
         mov       al," "
         call      Disp1Chr                 ; mezera
         mov       al,ds:[All]
         call      Disp1Chr
         mov       al,":"
         call      Disp1Chr
         mov       al," "
         call      Disp1Chr                 ; mezera
         mov       si,offset LabTxt
         mov       cl,11
         mov       ah,ds:[Barva2]
         call      DispTxt
         mov       ah,ds:[Barva1]
         mov       al," "
         call      Disp1Chr
         call      Disp1Chr
         mov       al,186
         call      Disp1Chr
         mov       al," "
         call      Disp1Chr
         pop       dx
         inc       dh

; ------ zobrazen° doln°ho okraje

         mov       al," "
         call      Disp1Chr                 ; mezera
         mov       al,200
         call      Disp1Chr                 ; levò doln° roh
         mov       al,205
         mov       cl,17
         call      DispChr                  ; doln° linka
         mov       al,188
         call      Disp1Chr                 ; pravò doln° roh
         mov       al," "
         call      Disp1Chr                 ; mezera

; ------ zobrazen° kurzoru

         mov       dx,ds:[Pozice]
         add       dh,1
         add       dl,6
         add       dl,ds:[Kurz]
         call      SetKurz

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispLab  ENDP

; *****************************************************************************
;                           InpChr
;                   vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------
; *****************************************************************************
;˛

BlokTab  label     byte
         db        '"*+,./:;<=>?[\]|'
BlokTab0 label     byte


InpChr   PROC      NEAR

         push      ax
InpChr1: mov       ah,0
         int       16h

         push      es
         push      di
         push      cx

         push      ds
         pop       es
         mov       di,offset BlokTab
         mov       cx,offset(BlokTab0-BlokTab)
         cld
         repne     scasb

         pop       cx
         pop       di
         pop       es
         je        InpChr1                  ; zak†zanò znak

         mov       bx,ax

         or        bx,bx
         jnz       InpChr2
         mov       bl,1bh

InpChr2: cmp       bl,0
         je        InpChr3
         mov       bh,0

InpChr3: cmp       bl,"a"
         jb        InpChr4
         cmp       bl,"z"
         ja        InpChr4
         sub       bl,32

InpChr4:
         pop       ax
         ret

InpChr   ENDP

; *****************************************************************************
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol† instrukc° CALL JumpBX, za kterou n†sleduje tabulka
; skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
; poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z†sobn°ku slovo (n†vratov† adresa NEAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 slovo testovan† hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; *****************************************************************************

JumpBX   PROC      NEAR

; ------ £schova registrñ

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen° hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan† hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal®° poloëky
         jmp       short JumpBX1            ; test dal®° poloëky

; ------ nastaven° n†vratovÇ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov† n†vratov† adresa

; ------ n†vrat registrñ

         pop       ds
         pop       bp
         pop       si
         ret

JumpBX   ENDP

; *****************************************************************************
;                             DispHlp
;                       zobrazen° n†povàdy DS:SI
; -----------------------------------------------------------------------------
; *****************************************************************************

DispHlp  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      es

         push      ds
         pop       es
         mov       dl,0
         mov       dh,ds:[MaxRow]
         mov       ah,ds:[Barva4]
         mov       cl,80
         call      DispTxt

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispHlp  ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; *****************************************************************************
;                            KurzOff
;                        vypnut° kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

KurzOff  PROC      NEAR

         push      dx
         mov       dl,0
         mov       dh,ds:[Radku]            ; prvn° ©†dek "za rohem"
         call      SetKurz                  ; nastaven° pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; *****************************************************************************
;                            SetKurz
;                     nastaven° pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice kurzoru
;        DH=©†dek kurzoru
;        DS=datovò segment
; *****************************************************************************

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,2                     ; funkce - nastaven° pozice kurzoru
         call      Int10P                   ; nastaven° pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; *****************************************************************************
;                            GetKurz
;                     poskytnut° pozice kurzoru
; -----------------------------------------------------------------------------
; VùSTUP:DL=pozice kurzoru
;        DH=©†dek kurzoru
;        DS=datovò segment
; *****************************************************************************

GetKurz  PROC      NEAR

         push      ax
         push      bx
         push      cx
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,3                     ; funkce - poskytnut° pozice kurzoru
         call      Int10P                   ; poskytnut° pozice kurzoru
         pop       cx
         pop       bx
         pop       ax
         ret

GetKurz  ENDP

; *****************************************************************************
;                              Disp1Chr
;                    Z†pis 1 znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z†pisu (AL=znak, AH=atribut)
;         DL=pozice
;         DH=©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1                     ; 1 znak k z†pisu
         call      DispChr                  ; z†pis 1 znaku na displej
         pop       cx
         ret

Disp1Chr ENDP

; *****************************************************************************
;                              DispChr
;                 Opakovanò z†pis znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z†pisu (AL=znak, AH=atribut)
;         CL=poáet znakñ k z†pisu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispChr  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispChr8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispChr8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         mov       bx,ax                    ; £schova znaku k z†pisu
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispChr1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispChr1:les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         sti                                ; p©eru®en° povoleno
         cld                                ; smàr posunu ukazatele nahoru
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         je        DispChr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispChr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
DispChr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispChr5                 ; prob°h† vertik†ln° impuls
DispChr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispChr3                 ; je horiz. zpàtnò bàh - áek†n°
DispChr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispChr4                 ; áek†n° na horiz. zpàtnò bàh
DispChr5:mov       ax,bx                    ; znak k zobrazen°
         stosw                              ; z†pis jednoho znaku
         loop      DispChr2                 ; z†pis dal®°ho znaku

; ------ z†pis znaku bez kontroly snàëen°

DispChr6:mov       ax,bx                    ; znak k zobrazen°
         rep       stosw                    ; z†pis znaku bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispChr7:pop       es                       ; n†vrat ES
         pop       di                       ; n†vrat DI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX

DispChr8:add       dl,cl                    ; zvò®en° pozice
         ret

DispChr  ENDP




; *****************************************************************************
;                              DispTxt
;                  Zobrazen° textovÇho ©etàzce na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AH=atribut barvy
;         CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (bez atributñ)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispTxt  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispTxt8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispTxt8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispTxt1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispTxt1:push      es                       ; £schova segmentu zdrojovÇho textu
         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         push      ax
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti
         pop       ax

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         sti                                ; p©eru®en° povoleno
         cld                                ; smàr posunu ukazatele nahoru
         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         pop       ds                       ; segment zdrojovÇ adresy
         jcxz      DispTxt7                 ; nen° ë†dnò znak k p©enosu
         je        DispTxt6                 ; neprov†d° se kontrola snàëen°

; ------ p©enos dat s obsluhou snàëen°

DispTxt2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispTxt5                 ; prob°h† vertik†ln° impuls
DispTxt3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispTxt3                 ; je horiz. zpàtnò bàh - áek†n°
DispTxt4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispTxt4                 ; áek†n° na horiz. zpàtnò bàh
DispTxt5:lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; p©enos jednoho znaku
         loop      DispTxt2                 ; p©enos dal®°ho znaku
         jmp       short DispTxt7

; ------ p©enos dat bez kontroly snàëen°

DispTxt6:lodsb                              ; znak k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispTxt6                 ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispTxt7:pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       ax                       ; n†vrat AX

DispTxt8:add       dl,cl                    ; zvò®en° pozice
         ret

DispTxt  ENDP

; *****************************************************************************
;                              DispStr
;                 Zobrazen° textovÇho ©etàzce na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (1 znak = 2 bajty = znak a atribut)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispStr  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispStr8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispStr8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ do konce ©†dku

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispStr1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispStr1:push      es                       ; £schova segmentu zdrojovÇho textu
         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         cld                                ; smàr posunu ukazatele nahoru
         sti                                ; povolen° p©eru®en°
         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         pop       ds                       ; segment zdrojovÇ adresy
         je        DispStr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispStr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

DispStr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispStr5                 ; prob°h† vertik†ln° impuls
DispStr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispStr3                 ; je horiz. zpàtnò bàh - áek†n°
DispStr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispStr4                 ; áek†n° na horiz. zpàtnò bàh
DispStr5:movsw                              ; p©enos jednoho znaku
         loop      DispStr2                 ; p©enos dal®°ho znaku

; ------ p©enos dat bez kontroly snàëen°

DispStr6:rep       movsw                    ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispStr7:pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       ax                       ; n†vrat AX

DispStr8:add       dl,cl                    ; zvò®en° pozice
         ret

DispStr  ENDP

; *****************************************************************************
;                             InitVmod
;                      Inicializace videom¢du
;             (poëaduje, aby byla rozpozn†na karta EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: CY=videom¢d byl zmànàn
;         neniá° ë†dnò registr
; *****************************************************************************

InitVMod PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ kontrola, zda je povolenò videom¢d

         call      AktPDisp                 ; aktualizace parametrñ displeje
         cmp       al,7                     ; MDA ?
         je        InitVM5                  ; povolenò videom¢d
         cmp       al,2
         je        InitVM5                  ; CGA
         cmp       al,3
         je        InitVM5                  ; CGA

; ------ stanoven° implicitn°ho videom¢du

         int       11h                      ; poskytnut° tabulky vybaven°
         and       al,30h                   ; inicializaán° videom¢d
         cmp       al,30h                   ; videom¢d 80x25 monochrom. ?
         mov       al,7                     ; videom¢d MDA
         je        InitVM1                  ; je videom¢d MDA
         mov       al,3                     ; jinak videom¢d CGA
InitVM1: call      SetVMode                 ; nastaven° poëadovanÇho videom¢du
         stc                                ; p©°znak zmàny videom¢du

; ------ n†vrat registrñ

InitVM5: pop       ax
         ret

InitVMod ENDP

; *****************************************************************************
;                               SetVMode
;                          Nastaven° videom¢du
;                (doporuáuje se rozpozn†n° videokarty EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  AL=poëadovanò videom¢d
;         DS=datovò segment
; VùSTUP: AL=novò aktu†ln° videom¢d
;         CY=videom¢d nenastaven
;         neniá° ë†dnò registr
; *****************************************************************************

SetVMode PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax                       ; £schova poëadovanÇho videom¢du

; ------ nastaven° videom¢du

         xor       ah,ah                    ; funkce nastaven° videom¢du
         call      Int10P                   ; nastaven° videom¢du
         call      AktPDisp                 ; poskytnut° aktivn°ho videom¢du
         mov       bl,al                    ; £schova aktu†ln°ho videom¢du

; ------ n†vrat registrñ, zhodnocen° vòsledku

         pop       ax                       ; n†vrat poëadovanÇho videom¢du
         xchg      al,bl                    ; AL <- novò videom¢d
         cmp       al,bl                    ; souhlas° videom¢d s poëadovanòm ?
         je        SetVMod1                 ; videom¢d nastaven OK
         stc                                ; p©°znak chyby nastaven° videom¢du
SetVMod1:pop       bx
         ret

SetVMode ENDP

; *****************************************************************************
;                               AktPDisp
;            Atualizace parametrñ displeje podle videom¢du
;
; Tato procedura pouë°v† k aktualizaci parametrñ pouze operace v pamàti,
; nepouë°v† ë†dnÇ p©eru®en°. Vyëaduje rozpozn†n° karty EGA/VGA.
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AL=aktu†ln° videom¢d
;         neniá° ë†dnò registr
; *****************************************************************************

AktPDisp PROC    NEAR

; ------ £schova registrñ

         push      es
         push      bx

; ------ zji®tàn° videom¢du

         mov       bx,40h
         mov       es,bx                    ; ES <- 40h segment dat BIOS
         mov       al,es:[49h]              ; aktu†ln° videom¢d
         and       al,7fh                   ; zru®en° p©°znaku nemaz†n° displeje

; ------ zji®tàn° videostr†nky

         mov       bl,es:[62h]              ; aktivn° videostr†nka
         mov       ds:[AktPage],bl          ; £schova aktivn° videostr†nky

; ------ zji®tàn° adresy videopamàti a p©ednastaven° p©°znaku obsluhy snàëen°

         mov       byte ptr ds:[ChckSnow],0 ; zru®en° p©°znaku obsluhy snàëen°
         mov       word ptr ds:[AdrVRAM+2],0B000h ; segment videopamàti pro MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        AktParD1                 ; je videom¢d MDA
         mov       word ptr ds:[AdrVRAM+2],0B800h ; segment videopamàti pro CGA
         inc       byte ptr ds:[ChckSnow]   ; nastav. p©°znaku obsluhy snàëen°
AktParD1:mov       bx,es:[4eh]              ; poá†teán° adresa videopamàti
         mov       word ptr ds:[AdrVRAM],bx ; poá†teán° adresa videopamàti

; ------ zji®tàn° poátu ©†dkñ a up©esnàn° p©°znaku snàëen°

         mov       bl,24                    ; p©ednastaven° na 25 ©†dkñ
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA, VGA ?
         je        AktParD6                 ; nen° karta EGA/VGA
         cmp       byte ptr es:[84h],5      ; je £daj poátu ©†dkñ platnò ?
         jb        AktParD5                 ; £daj poátu ©†dkñ nen° platnò
         mov       bl,es:[84h]              ; poáet ©†dkñ displeje - 1
AktParD5:mov       bh,es:[87h]              ; p©°znak kontroly snàëen°
         shr       bh,1
         shr       bh,1
         and       bh,1                     ; p©°znak obsluhy snàëen°
         mov       ds:[ChckSnow],bh         ; nastaven° p©°znaku kontroly snàë.
AktParD6:mov       ds:[MaxRow],bl           ; maxim†ln° ©†dek na displeji
         inc       bl                       ; poáet ©†dkñ celkem
         mov       ds:[Radku],bl            ; poáet ©†dkñ celkem

; ------ zji®tàn° b†zovÇ ©°dic° adresy displeje CRT

         mov       bx,es:[63h]              ; b†zov† adresa portu ©adiáe CRT
         add       bx,6
         mov       ds:[PortCRT],bx          ; stavovò registr ©adiáe displeje

; ------ n†vrat registrñ

         pop       bx
         pop       es
         ret

AktPDisp ENDP

; *****************************************************************************
;                              DetCard
;                      detekce videokarty EGA/VGA
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
;         neniá° ë†dnò registr
; *****************************************************************************

DetCard  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ test videokarty EGA/VGA

         mov       ah,12h                   ; sluëba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut° informac° o EGA
         call      Int10P                   ; poskytnut° informac° o EGA/VGA
         mov       byte ptr ds:[EgaVga],0   ; zru®en° p©°znaku karty EGA/VGA
         cmp       bh,1                     ; kontrola navr†cenÇho m¢du displeje
         ja        DetectC1                 ; nen° to karta EGA/VGA
         cmp       bl,5                     ; maxim†lnà povolen 1 MB pamàti
         ja        DetectC1                 ; nen° to karta EGA/VGA
         mov       byte ptr ds:[EgaVga],1   ; p©°znak karty EGA/VGA

; ------ n†vrat registrñ

DetectC1:pop       cx
         pop       bx
         pop       ax
         ret

DetCard  ENDP

; *****************************************************************************
;                              Int10P
;                Vol†n° INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------
;
; *****************************************************************************

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                    Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

HlpTxt   db        ' LAB V 1.10; (c) M.Nemecek ≥ Zadejte jmeno disku a stisknete ENTER ≥ ESC=navrat '

MemTxt   db        'CHYBA - nedostatek pameti !',13,10,'$'

StarTxt  db        'CHYBA - stare jmeno disku nelze zrusit !    Stisknete libovolnou klavesu...     '

VytvTxt  db        'CHYBA - nove jmeno disku nelze vytvorit !   Stisknete libovolnou klavesu...     '

DiskTxt  db        'Chybne zadani disku !',13,10,'$'

Barva1   db        70h                      ; bàën† barva
Barva2   db        30h                      ; barva editovanÇho ©†dku
Barva4   db        30h                      ; barva textu n†povàdy

Pozice   dw        0                        ; poá†teán° pozice

Kurz     db        0                        ; aktivn° pozice kurzoru
         db        0                        ; doplnàn° na slovo

Param    db        0                        ; parametry
                                            ;  bit0: 1=bylo n†và®t°
                                            ;  bit1: 1=n†và®t° bylo modifikov†no

All      db        'A:\*.*',0

; ------ FCB novÇho n†và®t°

FCBNove  db        0ffh
         db        0,0,0,0,0
         db        8                        ; atributy
FCBNovD  db        0                        ; disk
LabTxt   db        '           '            ; buffer editovanÇho textu
         dw        0                        ; aktu†ln° blok
         dw        80h                      ; dÇlka z†znamu
         dd        0                        ; velikost souboru
         dw        0                        ; datum posledn°ho z†pisu
         dw        0                        ; áas posledn°ho z†pisu
         db        0,0,0,0,0,0,0,0
         db        0                        ; aktu†ln° z†znam
         dd        0                        ; relativn° z†znam

; ------ FCB starÇho n†và®t°

FCBStar  db        0ffh
         db        0,0,0,0,0
         db        8                        ; atributy
FCBStrD  db        0                        ; disk
FCBStrT  db        '           '            ; buffer editovanÇho textu
         dw        0                        ; aktu†ln° blok
         dw        80h                      ; dÇlka z†znamu
         dd        0                        ; velikost souboru
         dw        0                        ; datum posledn°ho z†pisu
         dw        0                        ; áas posledn°ho z†pisu
         db        0,0,0,0,0,0,0,0
         db        0                        ; aktu†ln° z†znam
         dd        0                        ; relativn° z†znam

; -----------------------------------------------------------------------------
;        Parametry displeje a videom¢du
; -----------------------------------------------------------------------------

         EVEN
AdrVRAM  dd        0b8000000h               ; adresa videostr†nky displeje
PortCRT  dw        3dah                     ; b†zov† adresa portu ©adiáe CRT
Radku    db        25                       ; poáet ©†dkñ celkem
MaxRow   db        24                       ; maxim†ln° ©†dek na displeji
EgaVga   db        0                        ; p©°znak, ëe je karta EGA/VGA
ChckSnow db        0                        ; p©°znak, ëe se kontroluje snàëen°
AktPage  db        0                        ; aktivn° videostr†nka

ObrSize  dw        0                        ; velikost bufferu obrazovky (slov)

Root     db        'A:\',0                  ; z†kladn° adres†© disku

OldPath  db        'A:\', 80 dup(?)         ; uschovanò aktivn° adres†© disku

BufDTA   db        43 dup(?)                ; buffer DTA

ObrSegm  dw        ?                        ; adresa bufferu obrazovky
OldKurz  dw        ?                        ; uschovan† pozice kurzoru

         dw        200h dup(?)              ; z†sobn°k
Zasob    label     word

CODE     ENDS

         END       Start

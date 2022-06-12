; *****************************************************************************
;                             SystÇmovÇ informace
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

sysinfo:
                                          ;* test zad†n° parametrñ
         mov       di,offset prepinac
         mov       si,81h                   ; p©°kazovò ©†dek
         mov       cl,ds:[si-1]             ; poáet znakñ p©°kazovÇho ©†dku
         and       cx,7fh                   ; omezen° na 127 znakñ
         cmp       cx,1                     ; je 1 nebo ë†dnò znak ?
         jbe       sysinfo9                 ; v®eobecnÇ informace
                                          ;* dek¢dov†n° parametrñ
         mov       bx,cx                    ; poáet znakñ p©°kaz. ©†dku
         mov       byte ptr ds:[si+bx],0    ; oznaáen° konce p©°kaz. ©†dku
         mov       word ptr ds:[di],0       ; zru®en° p©ep°naáe
                                          ;* test p©ep°naáe "/S"
         mov       ah,"S"                   ; hledanò p©ep°naá "/S"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo1                 ; parametr nenalezen
         or        word ptr ds:[di],1       ; nastaven° p©ep°naáe "/S"
sysinfo1:
                                          ;* test p©ep°naáe "/M"
         mov       ah,"M"                   ; hledanò p©ep°naá "/M"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo2                 ; parametr nenalezen
         or        word ptr ds:[di],2       ; nastaven° p©ep°naáe "/M"
sysinfo2:
                                          ;* test p©ep°naáe "/I"
         mov       ah,"I"                   ; hledanò p©ep°naá "/I"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo3                 ; parametr nenalezen
         or        word ptr ds:[di],4       ; nastaven° p©ep°naáe "/I"
sysinfo3:
                                          ;* test p©ep°naáe "/C"
         mov       ah,"C"                   ; hledanò p©ep°naá "/C"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo4                 ; parametr nenalezen
         or        word ptr ds:[di],8       ; nastaven° p©ep°naáe "/C"
sysinfo4:                                 ;* test p©ep°naáe "/W"
         mov       ah,"W"                   ; hledanò p©ep°naá "/W"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo5                 ; parametr nenalezen
         or        word ptr ds:[di],10h     ; nastaven° p©ep°naáe "/W"
sysinfo5:                                 ;* test p©ep°naáe "/B"
         mov       ah,"B"                   ; hledanò p©ep°naá "/B"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo6                 ; parametr nenalezen
         lodsb                              ; oznaáen° disku
         or        word ptr ds:[di],20h     ; nastaven° p©ep°naáe "/B"
         and       al,not 20h               ; p©evod na velkÇ p°smeno
         sub       al,"A"                   ; korekce na bin†rn° á°slo
         mov       ds:[bootdisk],al         ; uloëen° á°sla disku
sysinfo6:                                 ;* cejchov†n° hodin "/$"
         mov       ah,"$"
         call      hledpar                  ; nalezen° parametru
         jc        sysinfo7                 ; parametr nenalezen
         or        word ptr ds:[di],8001h   ; p©°znak cejchov†n° hodin "/$"
sysinfo7:

sysinfo9:                                 ;* test spr†vnosti zad†n° parametrñ
         cmp       word ptr ds:[di],0       ; je nàjakò p©ep°naá ?
         jne       sysinfoa                 ; je nàjakò p©ep°naá - OK
         lea       si,[nadpis]              ; text nadpisu
         call      outtxt                   ; zobrazen° nadpisu
         mov       si,offset texthlp        ; text n†povàdy
         call      outtxtx                  ; zobrazen° chybovÇho textu
         int       20h                      ; konec programu

sysinfoa:                                 ;* zji®tàn° informac° o poá°taái
         call      testtyp                  ; zji®tàn° typu poá°taáe
         call      testdos                  ; test verze operaán°ho systÇmu
         call      testbios                 ; test verze BIOSu
         call      testproc                 ; test hlavn°ho procesoru
         call      testkopr                 ; test koprocesoru
         call      testcard                 ; test grafickÇ karty
         call      testdisk                 ; test disketovòch mechanik
         call      testwin                  ; test pevnòch diskñ
         call      testmem                  ; test celkovÇ pamàti
         call      testhod                  ; test hodin procesoru

         nop
                                          ;* zobrazen° v®eobecnòch informac°
         test      byte ptr cs:[prepinac],1 ; zobraz° se v®eobecnÇ informace ?
         jz        sysinfob                 ; nezobraz° se v®eobecnÇ informace

         lea       si,[nadpis]              ; text nadpisu
         call      outtxt                   ; zobrazen° nadpisu
         call      zobrtyp                  ; zobrazen° typu poá°taáe
         call      zobrdos                  ; zobrazen° verze oper. systÇmu
         call      zobrbios                 ; zobrazen° verze BIOSu
         call      zobrproc                 ; zobrazen° hlavn°ho procesoru
         call      zobrkopr                 ; zobrazen° koprocesoru
         call      zobrhod                  ; zobrazen° hodin procesoru
         call      zobrmem                  ; zobrazen° celkovÇ pamàti
         call      zobrrom                  ; zobrazen° modulñ ROM-BIOS
         call      zobrport                 ; zobrazen° portñ
         call      zobrcard                 ; zobrazen° grafickÇ karty
         call      zobrdisk                 ; zobrazen° disketovòch mechanik
         call      zobrwin                  ; zobrazen° pevnòch diskñ
         call      zobrlogd                 ; zobrazen° logickòch diskñ
         lea       si,[zaver]               ; z†vàreánò text
         call      outtxtx                  ; z†vàreánÇ od©†dkov†n° textu

sysinfob:                                 ;* zobrazen° obsahu pamàti DOS
         test      byte ptr cs:[prepinac],2 ; zobraz° se obsah pamàti ?
         jz        sysinfoc                 ; nezobrazuje se obsah pamàti
         call      memorydos                ; zobrazen° obsahu pamàti
sysinfoc:                                 ;* zobrazen° vektorñ p©eru®en°
         test      byte ptr cs:[prepinac],4 ; zobraz° se vektory p©eru®en° ?
         jz        sysinfod                 ; nezobraz° se vektory p©eru®en°
         call      intlist                  ; zobrazen° vektorñ p©eru®en°
sysinfod:                                 ;* zobrazen° obsahu pamàti CMOS
         test      byte ptr cs:[prepinac],8 ; zobrazen° se obsah pamàti CMOS ?
         jz        sysinfoe                 ; nezobraz° se CMOS
         call      cmoslist                 ; zobrazen° obsahu pamàti CMOS
sysinfoe:                                 ;* zavadàá pevnòch diskñ
         test      byte ptr cs:[prepinac],10h ; zobrazuj° se zavadàáe ?
         jz        sysinfof                 ; nezobrazuj° se zavadàáe
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         call      winlist                  ; zobrazen° zavadàáe pevnÇho disku 0
         mov       dl,81h                   ; á°slo pevnÇho disku 1
         call      winlist                  ; zobrazen° zavadàáe pevnÇho disku 1
sysinfof:                                 ;* zavadàá disku
         test      byte ptr cs:[prepinac],20h ; zobraz° se zavadàá ?
         jz        sysinfog                 ; nezobrazuje se zavadàá
         mov       dl,ds:[bootdisk]         ; á°slo disku k zobrazen°
         call      bootlist                 ; zobrazen° zavadàáe disku
sysinfog:
         int       20h

; -----------------------------------------------------------------------------
;                         Zji®tàn° informac° o poá°taái
; -----------------------------------------------------------------------------
public   testtyp
testtyp:                                  ;* zji®tàn° typu poá°taáe
         push      es
                                          ;* zji®tàn° modelu z BIOS
         mov       ax,0f000h                ; segment dat BIOS
         mov       es,ax                    ; segment dat BIOS
         mov       al,es:[0fffeh]           ; identifik†tor systÇmovÇho modelu
         mov       ds:[smodel],al           ; £schova systÇmoveho modelu
         cmp       al,0feh
         jae       testtyp3                 ; je PC nebo PC-XT
         cmp       al,0fbh
         je        testtyp3                 ; je XT
                                          ;* pokus o zji®tàn° pomoc° INT 15h
         mov       ah,0c0h
         int       15h                      ; zji®tàn° dal®°ch informac°
         jc        testtyp3                 ; chyba operace
         or        ah,ah                    ; je informace platn† ?
         jnz       testtyp3                 ; informace nen° platn†
         mov       ax,es:[bx+2]             ; á°slo modelu a submodelu
         mov       word ptr ds:[smodel],ax  ; £schova modelu a submodelu
testtyp3:pop       es
         ret
; -----------------------------------------------------------------------------
public   testdos
testdos:                                  ;* zji®tàn° verze operaán°ho systÇmu
         mov       ah,30h
         int       21h                      ; dotaz na verzi operaán°ho systÇmu
         xchg      ah,al                    ; z†màna verze a podverze
         or        ah,ah                    ; je verze systÇmu 1.xx ?
         jnz       testdos2                 ; nen° verze 1.xx
         inc       ah                       ; verze systÇmu 1.xx
testdos2:mov       ds:[verze],ax            ; £schova verze operaán°ho systÇmu
         ret
; -----------------------------------------------------------------------------
public   testbios
testbios:                                 ;* zji®tàn° data vzniku BIOS
         push      es
         mov       ax,0f000h                ; segment dat BIOS
         mov       es,ax                    ; segment dat BIOS
         mov       di,0fff5h                ; zaá†tek data v pamàti
         mov       cx,3                     ; poáet pokusñ
testbi1: call      testbix                  ; test spr†vnosti data
         jnc       testbi2                  ; nalezeno spr†vnÇ datum
         inc       di                       ; adresa 0fff6h
         loop      testbi1                  ; dal®° test
         jmp       short testbi4            ; nenalezeno platnÇ datum
testbi2:                                  ;* nalezeno platnÇ datum
         call      testbiy                  ; áten° á°sla màs°ce
         mov       ds:[biosmes],al          ; uloëen° màs°ce
         call      testbiy                  ; áten° á°sla dne
         mov       ds:[biosden],al          ; uloëen° dne
         call      testbiy                  ; áten° á°sla roku
         cbw                                ; AX <- AL
         cmp       al,80                    ; je rok p©ed 1980 ?
         jae       testbi3                  ; nen° rok p©ed 1980
         add       ax,100                   ; korekce na stolet° 2000
testbi3: add       ax,1900                  ; korekce na stolet°
         mov       ds:[biosrok],ax          ; uloëen° á°sla roku
testbi4: pop       es
         ret

testbix:                                  ;* test spr†vnosti data ES:DI
         push      di
                                          ;* test màs°ce
         call      testbinx                 ; test 2 á°slic
         jc        testbix3                 ; neplatnò màs°c
         call      testbio                  ; test oddàlovaáe
         jne       testbix3                 ; neplatnò oddàlovaá
                                          ;* test dne
         call      testbinx                 ; test 2 á°slic
         jc        testbix3                 ; neplatnò den
         call      testbio                  ; test oddàlovaáe
         jne       testbix3                 ; neplatnò oddàlovaá
                                          ;* test roku
         call      testbinx                 ; test 2 á°slic
testbix3:pop       di
         ret


testbio:                                  ;* test oddàlovaáe data (-> ZF)
         mov       al,es:[di]               ; testovan† á°slice
         inc       di                       ; zvò®en° ukazatele á°slic
         cmp       al,"\"
         je        testbio2                 ; spr†vnò oddàlovaá
         cmp       al,"/"
         je        testbio2                 ; spr†vnò oddàlovaá
         cmp       al,"-"
         je        testbio2                 ; spr†vnò oddàlovaá
         cmp       al,"."
testbio2:ret


testbinx:                                 ;* test 2 á°slic
         call      testbin                  ; test prvn° á°slice
         jc        testbin2                 ; chyba - neplatn† á°slice

testbin:                                  ;* test platnosti á°slice AL (-> CF)
         mov       al,es:[di]               ; testovan† á°slice
         inc       di                       ; zvò®en° ukazatele á°slic
         sub       al,"0"
         jb        testbin2                 ; nen° platn† á°slice
         cmp       al,10
         cmc                                ; CY - nen° platn† á°slice
testbin2:ret

testbiy:                                  ;* áten° á°sla (2 á°slice)
         call      testbin                  ; áten° prvn° á°slice
         mov       bl,10
         mul       bl                       ; vyn†soben° 10x
         mov       bl,al
         call      testbin
         add       al,bl                    ; vòslednÇ á°slo
         inc       di                       ; p©eskoáen° oddàlovaáe
         ret
; -----------------------------------------------------------------------------
public   testproc
testproc:                                 ;* test hlavn°ho procesoru

         call      getproc                  ; zji®tàn° hlavn°ho procesoru
         mov       ds:[procesor],al         ; typ hlavn°ho procesoru
         ret

;                                          ;* test ©ad 80286 / 8086
;         pushf                              ; £schova p©°znakñ
;         xor       ax,ax                    ; AX <- 0
;         push      ax
;         popf
;         pushf
;         pop       ax
;         popf                               ; n†vrat p©°znakñ
;         and       ax,0f000h
;         cmp       ax,0f000h                ; je nië®° procesor ?
;         je        testpro2                 ; je nië®° procesor
;                                          ;* rozpozn†n° 80286/80386
;         pushf                              ; £schova p©°znakñ
;         mov       ax,7000h
;         push      ax
;         popf
;         pushf
;         pop       ax
;         popf                               ; n†vrat p©°znakñ
;         and       ax,7000h
;         mov       dl,5                     ; procesor 80286
;         jz        testpro3                 ; vynulovaly se - je 80286
;         inc       dl                       ; procesor 80386
;         jmp       short testpro3           ; je 80386
;testpro2:                                 ;* rozpozn†n° 80188/8088
;         mov       ax,0ffffh
;         mov       cl,33
;         shl       ax,cl                    ; rotace AX
;         mov       dl,1                     ; procesor 8088
;         jz        testpro5                 ; je procesor 8088/8086
;         mov       dl,3                     ; je procesor 80188/80186
;testpro5:                                 ;* rozpozn†n° sbàrnice
;         std                                ; smàr p©enosu dolñ
;
;         EVEN                               ; zarovn†n° na sudou adresu
;
;         mov       di,offset testpro6
;         mov       al,byte ptr ds:[testpro7]
;         mov       cx,3
;         cli
;         rep       stosb                    ; zru®en° instrukce INC DL
;         cld
;         nop
;         nop
;         nop
;         inc       dx                       ; u 8086 tato instrukce zñstane
;testpro7:sti
;testpro6:sti
;testpro3:mov       ds:[procesor],dl         ; £schova á°sla procesoru
;testpro4:sti
;         ret


getproc:                                  ;* zji®tàn° hlavn°ho procesoru
                                            ; VùSTUP: AX=typ procesoru
                                            ;   0=nezn†mò
                                            ;   1=Intel 8088
                                            ;   2=Intel 8086
                                            ;   3=NEC V20
                                            ;   4=NEC V30
                                            ;   5=Intel 80188
                                            ;   6=Intel 80186
                                            ;   7=Intel 80286
                                            ;   8=Intel 80386
                                            ;   9=Intel 80386 SX
                                            ;  10=Intel 80486
                                            ;  11=Intel 80486+
                                            ;  12=Pentium

                                          ;* rozli®en° 808x,Vx0/vy®®°
         pushf                              ; £schova registru p©°znakñ
         xor       ax,ax                    ; AX <- 0
         push      ax                       ; 0 -> stack
         popf                               ; F <- 0
         pushf                              ; F -> stack
         pop       ax                       ; AX <- F
         popf                               ; n†vrat p©°znakñ
         and       ax,0f000h                ; test bitñ 12 aë 15
         cmp       ax,0f000h                ; jsou napevno nastaveny na 1 ?
         jne       testpro2                 ; nejsou nast. - je 80186 nebo vyssi

                                          ;* rozli®en° 8088,8086/V20,V30
                                            ; testuje, zda instrukce MUL AL
                                            ; ovliv§uje p©°znak ZF

         xor       al,al                    ; nastaven° p©°znaku ZY
         mov       al,40h                   ; n†sobenÇ á°slo
         mul       al                       ; vyn†soben° 40h*40h
         mov       ax,1                     ; procesor 8088,8086
         jnz       testpro1                 ; je procesor 8088,8086
         mov       ax,3                     ; nemàn° ZF - je procesor V20, V30

testpro1:                                 ;* test 8-bitovÇ sbàrnice
         push      ax                       ; £schova k¢du procesoru
         EVEN                               ; nastaven° na sudou adresu
         mov       di,offset testproa       ; konec testovac° posloupnosti
         std                                ; smàr dolñ
         mov       al,byte ptr cs:[testpro9]; posledn° instrukce STI
         mov       cx,3                     ; poáet bajtñ k testu
         cli                                ; z†kaz p©eru®en°
         rep       stosb                    ; p©epis isntrukc° STI
         cld                                ; n†vrat smàru dolñ
         nop
         nop
testpro8:nop                                ; sem se zap°®° 3 instrukce STI
         inc       cx                       ; u 8086 tato instrukce zñstane
testpro9:sti
testproa:sti
         pop       ax
         add       ax,cx                    ; korekce procesoru podle sbàrnice
         ret

testpro2:                                 ;* rozli®en° 8018x/vy®®°
                                            ; testuje, zda instrukce PUSH SP
                                            ; uloë° do z†sobn°ku stav SP p©ed
                                            ; operac° nebo po operaci (=8018x)

         push      sp                       ; uloëen° ukazatele z†sobn°ku
         pop       bx                       ; n†vrat á°sla, kterÇ se uloëilo
         cmp       bx,sp                    ; uloëil se stav SP p©ed operac° ?
         mov       ax,5                     ; procesor 80188, 80186
         jne       testpro1                 ; je procesor 80188, 80186

                                          ;* test procesoru 80286
         pushf                              ; £schova registru p©°znakñ
         mov       ax,0f000h                ; AX <- F000h
         push      ax                       ; F000h -> stack
         popf                               ; F <- F000h
         pushf                              ; F -> stack
         pop       ax                       ; AX <- F
         popf                               ; n†vrat registru p©°znakñ
         and       ax,0f000h                ; test bitñ 12 aë 15
         jnz       testpro3                 ; nejsou v®echny 0 - nen° 80286
         mov       ax,7                     ; jsou napevno 0 - je procesor 80286
         ret

testpro3:                                 ;* test procesoru 80486
                                            ; testuje se, zda lze mànit bit 18
                                            ; registru p©°znakñ FD
                                            ; VùSTUP: AX=1 (lze mànit-je 80486)

db 0C8h,0,0,0       ;ENTER  0000,00         ; m¢d 32 bitñ
db 66h,8Bh,0D4h     ;MOV    EDX,ESP         ; £schova ukazatele z†sobn°ku ESP
db 66h,83h,0E4h,0FCh;AND    ESP,FFFC        ; zaokrouhlen° ukazat. na dvojslovo
db 66h,9Ch          ;PUSHFD                 ; FD -> stack
db 66h,58h          ;POP    EAX             ; EAX <- FD
db 66h,8Bh,0C8h     ;MOV    ECX,EAX         ; ECX <- EAX (£schova FD)
db 66h,35h,0,0,4,0  ;XOR    EAX,00040000    ; zmàna bitu 18 registru FD
db 66h,50h          ;PUSH   EAX             ; EAX -> stack
db 66h,9Dh          ;POPFD                  ; FD <- pñvodn° FD se zmànou bitu 18
db 66h,9Ch          ;PUSHFD                 ; FD -> stack (jak to FD ovlivnil ?)
db 66h,58h          ;POP    EAX             ; AX <- FD (nov† hodnota)
db 66h,33h,0C1h     ;XOR    EAX,ECX         ; XOR novÇho stavu FD se staròm
db 66h,0C1h,0E8h,12h;SHR    EAX,12          ; rotace mànànÇho p©°znaku do bitu 0
db 66h,83h,0E0h,1   ;AND    EAX,+01         ; ponech† testovanò p©°znak FD
db 66h,51h          ;PUSH   ECX             ; pñvodn° nastaven° FD
db 66h,9Dh          ;POPFD                  ; n†vrat registru p©°znakñ FD
db 66h,8Bh,0E2h     ;MOV    ESP,EDX         ; n†vrat ukazatele z†sobn°ku ESP
db 0C9h             ;LEAVE                  ; opustàn° m¢du 32 bitñ

         dec       ax                       ; je procesor 80486 ?
         jnz       testpro4                 ; nen° procesor 80486
;˛
.486
         cli
         pushfd                             ; £schova EFLAGS

         pushfd                             ; EFLAGS do z†sobn°ku
         pop       eax                      ; EAX <- EFLAGS
         mov       ebx,eax                  ; EBX <- £schova starÇho stavu EFLAGS
         xor       eax,00200000h            ; zmàna p©°znaku CPUID
         push      eax                      ; novò stav EFLAGS do z†sobn°ku
         popfd                              ; EFLAGS <- nov† hodnota
         pushfd                             ; EFLAGS do z†sobn°ku
         pop       eax                      ; EAX <- nov† hodnota EFLAGS

         popfd                              ; n†vrat EFLAGS
         sti

         cmp       eax,ebx                  ; lze zmànit bit CPUID ?
         je        testpr34                 ; nelze zmànit - je 486

         xor       eax,eax                  ; EAX <- 0
db 0fh,0a2h                                 ; instrukce CPUID
         dec       eax                      ; instrukce podporov†na ?
         jnz       testpr34                 ; nen° podporov†na
         mov       dword ptr ds:[vendrcpu],ebx ; vendor ©etàzec
         mov       dword ptr ds:[vendrcpu+4],edx ; vendor ©etàzec
         mov       dword ptr ds:[vendrcpu+8],ecx ; vendor ©etàzec

         inc       eax                      ; EAX <- 1
db 0fh,0a2h                                 ; instrukce CPUID
         mov       ds:[modelcpu],ax         ; model procesoru
.8086
         cmp       ax,500h                  ; je Pentium ?
         mov       ax,12                    ; procesor Pentium
         jae       testpr32                 ; je Pentium
testpr31:mov       ax,11                    ; procesor 80486+
testpr32:ret

testpr34:mov       ax,10                    ; je procesor 80486
         ret

testpro4:                                 ;* rozli®en° 80386/80386 SX
                                            ; testuje bit 4 ©°dic°ho registru 0
                                            ; - pokud lze vynulovat, je 80386

db 0C8h,0,0,0       ;ENTER  0000,00         ; m¢d 32 bitñ
db 0Fh,20h,0C3h     ;MOV    EBX,CR0         ; £schova ©°dic°ho registru CR0
db 0Fh,20h,0C0h     ;MOV    EAX,CR0         ; EAX <- CR0
db 66h,83h,0E0h,0EFh;AND    EAX,FFEF        ; vynulov†n° bitu 4 reg. EAX
db 0Fh,22h,0C0h     ;MOV    CR0,EAX         ; CR0 <- nov† hodnota s nul. bit. 4
db 0Fh,20h,0C0h     ;MOV    EAX,CR0         ; EAX <- CR0 - vynuloval se bit 4 ?
db 66h,0C1h,0E8h,4  ;SHR    EAX,4           ; rotace bitu 4 do bitu 0
db 66h,83h,0E0h,1   ;AND    EAX,+01         ; bit 0 - p©°znak nastav. bitu 4 CR0
db 0Fh,22h,0C3h     ;MOV    CR0,EBX         ; n†vrat ©°dic°ho registru CR0
db 0C9h             ;LEAVE                  ; opustàn° m¢du 32 bitñ

         dec       ax                       ; je procesor 80386 SX ?
         mov       ax,8                     ; procesor 80386
         jnz       testpro5                 ; nen° procesor 80386 SX
         inc       ax                       ; je procesor 80386 SX (=9)
testpro5:ret
; -----------------------------------------------------------------------------
public   testkopr
testkopr:                                 ;* zji®tàn° koprocesoru

         int       11h                      ; poskytnut° tabulky vybaven°
         mov       dl,1                     ; koprocesor nenainstalov†n
         test      ax,2                     ; je koprocesor nainstalov†n ?
         jz        testkop4                 ; koprocesor nen° nainstalov†n
         mov       al,ds:[procesor]         ; hlavn° procesor
         xor       dx,dx                    ; p©ednastaven° - nezn†mò koproc.
         or        al,al                    ; je procesor nezn†mò ?
         jz        testkop4                 ; procesor je nezn†mò
         mov       dl,2                     ; koprocesor 8087
         cmp       al,7                     ; je procesor nië®° neë 80286 ?
         jb        testkop4                 ; je nië®° - je koproc. 8087
         mov       dl,3                     ; koprocesor 80287
         je        testkop4                 ; je koprocesor 80287
         mov       dl,4                     ; koprocesor 80387
         cmp       al,10                    ; je koprocesor 80486 ?
         jb        testkop4                 ; je 80387
         inc       dx                       ; koprocesor 80486
         cmp       al,11                    ; je koprocesor Pentium ?
         jbe       testkop4                 ; je 80486
         inc       dx                       ; koprocesor Pentium
testkop4:mov       ds:[koproc],dl           ; uloëen° koprocesoru
         ret
; -----------------------------------------------------------------------------
public   testcard
testcard:                                 ;* test grafickÇ karty

         call      DetectCard               ; detekce karty
         ret
;         push      es
;
;         mov       ah,12h
;         mov       bl,10h
;         int       10h
;         mov       dl,3                     ; karta EGA
;         cmp       bl,10h
;         jne       testcard3                ; je karta EGA
;
;         xor       ax,ax
;         mov       es,ax
;         mov       ax,es:[463h]
;         mov       dl,1
;         cmp       ax,3b4h
;         je        testcard3                ; je MDA
;         mov       dl,2                     ; je CGA
;testcard3:mov      ds:[card],dl             ; grafick† karta
;         pop       es
;         ret
; -----------------------------------------------------------------------------
public   testdisk
testdisk:                                 ;* zji®tàn° disket. mechanik

         int       11h                      ; áten° tabulky vybaven°
         test      al,1                     ; jsou disket. mechaniky ?
         jz        testdsk6                 ; nen° ë†dn† disketov† mechanika
         mov       cl,6
         shr       al,cl                    ; poáet mechanik
         inc       al
         mov       ds:[disket],al           ; poáet disketovòch mechanik

;         cmp       byte ptr ds:[smodel],0f9h ; je konvertabiln° PC ?
;         je        testdsk1                 ; je konvertabiln° PC
;         cmp       byte ptr ds:[smodel],0fch ; je AT ?
;         jne       testdsk6                 ; nen° AT
testdsk1:xor       ch,ch
         mov       cl,al                    ; poáet disket. mechanik
         xor       dl,dl                    ; ukazatel diskñ
         lea       di,[disket1]             ; tabulka typñ disket
testdsk2:push      cx
         push      dx
         push      di                       ; ukl†dac° adresa do tabulky
         push      es
         xor       bl,bl                    ; p©ednastaven° typu diskety
         mov       ax,83eh
         int       13h                      ; poskytnut° informac° o disketà
         pop       es
         pop       di                       ; ukl†dac° adresa do tabulky
         jc        testdsk4                 ; chyba operace
         or        ah,ah
         jnz       testdsk4                 ; funkce nen° podporovan†
         mov       al,bl
         cmp       al,5
         jbe       testdsk3
         mov       al,5
testdsk3:cld
         stosb                              ; typ disket. mechaniky
testdsk4:pop       dx                       ; ukazatel disket. mechanik
         pop       cx                       ; á°taá disket. mechanik
         inc       dl                       ; zvò®en° á°sla diskety
         loop      testdsk2                 ; dal®° disket. mechanika

testdsk6:ret
; -----------------------------------------------------------------------------
public   testwin
testwin:                                  ;* informace o pevnÇm disku
         mov       dl,80h                   ; pevnò disk 0
         mov       di,offset winchs0        ; tabulka pevnÇho disku 0
         call      testwin2                 ; áten° parametrñ pevnÇho disku 0
         mov       dl,81h                   ; pevnò disk 1
         mov       di,offset winchs1        ; tabulka pevnÇho disku 1

testwin2:
         push      dx

         mov       ah,8
         push      es
         push      di
         int       13h                      ; poskytnut° parametrñ disku
         pop       di
         pop       es

         jc        testwin3                 ; chyba operace
         pop       ax                       ; á°slo disku
         push      ax                       ; á°slo disku
         and       al,7fh                   ; zru®en° bitu 7
         cmp       al,dl                    ; je platnÇ á°slo disku ?
         jae       testwin3                 ; neplatnÇ á°slo disku
                                          ;* vòpoáet velikosti disku
         mov       ah,dh                    ; bity 10 a 11 á°sla stopy
         and       ah,0c0h                  ; ponech† bity 10 a 11 á°sla stopy
         shr       ah,1
         shr       ah,1
         shr       ah,1
         shr       ah,1                     ; p©esun na pozici bitñ 10 a 11
         mov       al,cl                    ; bity 8 a 9 á°sla stopy
         and       al,0c0h                  ; ponech† bity 8 a 9 á°sla v†lce
         rol       al,1
         rol       al,1                     ; p©esun na pozici bitñ 8 a 9
         or        ah,al                    ; nejvy®®° 4 bity á°sla v†lce
         mov       al,ch                    ; nië®°ch 8 bitñ á°sla v†lce
         inc       ax                       ; poáet v†lcñ disku
         mov       bl,dh                    ; poáet hlav disku - 1
         and       bx,3fh                   ; zru®en° bitñ á°sla stopy
         inc       bx                       ; poáet hlav disku
         mul       bx                       ; vòpoáet celkovÇho poátu stop
         and       cx,3fh                   ; poáet sektorñ
         mul       cx                       ; vòpoáet poátu sektorñ na disku
         mov       cx,1953                  ; dàlitel pro p©epoáet na MB
         div       cx                       ; p©epoáet na MB
         mov       ds:[di],ax               ; uloëen° velikosti disku
testwin3:
         pop       dx

         call      testwinc                 ; áten° typu pevnÇho disku z CMOS
         mov       ds:[di+2],al             ; nastaven° typu pevnÇho disku
testwin6:ret


testwinc:                                 ;* áten° typu disku DL z CMOS
                                            ; VSTUP: DL=á°slo pevnÇho disku
                                            ; VùSTUP: AL=typ pevnÇho disku
                                            ;         ZY=typ nezn†mò

         push      bx
         push      ax
         xor       bl,bl                    ; p©ednastaven° - neplatnò disk
         mov       ah,12h                   ; adresa typu pevnÇho disku
         call      readcmos                 ; áten° bajtu typñ pevnòch diskñ
         jc        testwnc7                 ; data neplat°
         test      dl,1                     ; je pevnò disk 1 ?
         jnz       testwnc4                 ; je pevnò disk 1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; rotace pro pevnò disk 1
testwnc4:and       al,0fh                   ; ponech† á°slo disku
         cmp       al,0fh                   ; je roz®°©enÇ á°slo typu ?
         jne       testwnc6                 ; nen° roz®°©enÇ á°slo typu
         mov       ah,19h                   ; adresa pevnÇho disku 0
         test      dl,1                     ; je pevnò disk 0 ?
         jz        testwnc5                 ; je pevnò disk 0
         inc       ah                       ; zvò®en° adresy na disk 1
testwnc5:call      readcmos                 ; áten° typu disku z CMOS
         jc        testwnc7                 ; chyba áten° dat z CMOS
testwnc6:mov       bl,al                    ; typ pevnÇho disku
testwnc7:pop       ax
         mov       al,bl                    ; á°slo disku
         or        al,al                    ; je platnò typ ?
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   testmem
testmem:                                  ;* test celkovÇ pamàti

         int       12h                      ; hl†®en° o velikosti pamàti
         mov       ds:[memory],ax

         cmp       byte ptr ds:[procesor],2 ; je procesor 80186 a vy®®° ?
         jbe       testmem4                 ; je n°zkò procesor
                                          ;* zji®tàn° pamàti z CMOS
         mov       ah,18h                   ; adresa vy®®°ho bajtu
         call      readcmos                 ; p©eáten° vy®®°ho bajtu pamàti
         jc        testmem2                 ; chyba áten° z CMOS
         mov       ch,al                    ; £schova vy®®°ho bajtu pamàti
         mov       ah,17h                   ; adresa nië®°ho bajtu
         call      readcmos                 ; p©eáten° nië®°ho bajtu pamàti
         mov       ah,ch                    ; n†vrat nië®°ho bajtu pamàti
         jc        testmem2                 ; chyba áten° z CMOS
         or        ax,ax
         jnz       testmem3
testmem2:
         mov       ax,8833h
         int       15h                      ; dotaz na roz®i©uj°c° pamàü
         jc        testmem4                 ; chyba
         cmp       ax,8833h
         je        testmem4                 ; sluëba nen° obsluhovan†
testmem3:add       ds:[memory],ax           ; nov† velikost pamàti

         cmp       word ptr ds:[memory],1100
         jb        testmem4
         add       word ptr ds:[memory],384 + 400 ; oprava pamàti + zaokrouhlen°
         and       word ptr ds:[memory],not 3ffh ; zaokrouhlen° na MB

testmem4:ret
; -----------------------------------------------------------------------------
public   testhod
testhod:                                  ;* test hodin procesoru


                                          ;* nastaven° vlastn° obsluhy INT 08h
;         cli                                ; z†kaz p©eru®en°
;         xor       ax,ax                    ; AX <- 0
;         mov       ds,ax                    ; DS <- 0
;         push      word ptr ds:[8*4]        ; £schova offsetu adresy INT 08h
;         push      word ptr ds:[8*4+2]      ; £schova segmentu adresy INT 08h
;         mov       word ptr ds:[8*4],offset inthran ; nastaven° offsetu obsluhy
;         mov       word ptr ds:[8*4+2],cs   ; nastaven° segmentu obsluhy
;                                          ;* zamaskov†n° ostatn°ch p©eru®en°
         in        al,[21h]                 ; maska p©eru®en°
         push      ax                       ; £schova masky p©eru®en°
         mov       al,not 1                 ; z†kaz v®ech ostatn°ch p©eru®en°
         out       [21h],al                 ; ponech† jen p©eru®en° od hodin
;
;         push      cs
;         pop       ds

testhod1:
         xor       bx,bx                    ; vy®®° slovo
         xor       si,si                    ; nië®° slovo
         mov       cx,6                     ; poáet pokusñ

testhod3:
         call      hrana                    ; mà©en° doby
         jc        testhod2                 ; p©eteáen°
         cmp       dx,bx                    ; je del®° doba ?
         jne       testhod4
         cmp       ax,si                    ; je del®° doba ?
testhod4:jbe       testhod5
         mov       si,ax                    ; novÇ nië®° slovo
         mov       bx,dx                    ; novÇ vy®®° slovo
testhod5:loop      testhod3                 ; dal®° pokus
         mov       ax,si                    ; nië®° slovo
         mov       dx,bx                    ; vy®®° slovo

         xor       bx,bx
         mov       bl,ds:[procesor]         ; procesor
         add       bx,bx
         mov       cx,ds:[hodproc+bx]       ; dàlic° konstanta pro hodiny
         mov       bx,cx
         shr       bx,1

         test      word ptr ds:[prepinac],8000h ; je cejchov†n° hodin ?
         jnz       testhod9                 ; je cejchov†n° hodin

         add       ax,bx                    ; zaokrouhlen°
         adc       dx,0
         cmp       dx,cx
         jae       testhod9
         div       cx                       ; p©epoáet na kmitoáet

testhod9:mov       ds:[hodiny],ax           ; hodiny procesoru

         mov       ds:[hodinyh],dx          ; vy®®° slovo hodin
testhod2:
                                          ;* navr†cen° masky p©eru®en°
;         cli                                ; z†kaz p©eru®en°
         pop       ax
         out       [21h],al                 ; n†vrat masky p©eru®en°
;                                          ;* navr†cen° obsluhy INT 08h
;         xor       ax,ax
;         mov       ds,ax                    ; DS <- 0
;         pop       word ptr ds:[8*4+2]      ; n†vrat segmentu adresy INT 08h
;         pop       word ptr ds:[8*4]        ; n†vrat offsetu adresy INT 08h
;         push      cs
;         pop       ds                       ; DS <- CS
;
;         sti                                ; povolen° p©eru®en°

         call      TstCpu                   ; test hodin procesoru

         ret

hrana:                                    ;* áek†n° na hranu hodin
                                            ; VùSTUP: DX:AX=konstanta
                                            ;         CY=p©eteáen°

         sti                                ; povolen° p©eru®en°
         push      bx                       ; £schova BX
         push      ds
         xor       ax,ax                    ; AX <- 0 (inicializace)
         xor       dx,dx                    ; DX <- 0 (inicializace)
         mov       ds,ax
         mov       bx,ds:[46ch]             ; stav á°taáe INT 08h
hrana1:  add       ax,1                     ; zvò®en° á°taáe prñchodñ
         adc       dl,0
         jc        hrana2                   ; je p©eteáen°
         cmp       bx,ds:[46ch]             ; byla zmàna ?
         je        hrana1                   ; nebyla je®tà zmàna
         clc                                ; p©°znak operace OK
hrana2:  pop       ds
         pop       bx
         ret

;inthran: inc       word ptr cs:[cit08]      ; zvò®en° ukazatele INT 08h
;         push      ax
;         mov       al,20h
;         out       [20h],al
;         pop       ax
;         iret

; -----------------------------------------------------------------------------
;                         Zobrazen° informac° o poá°taái
; -----------------------------------------------------------------------------
public   zobrtyp
zobrtyp:                                  ;* zobrazen° typu poá°taáe
         lea       si,[txttyp]              ; text "Typ poá°taáe:"
         call      outtxtx                  ; zobrazen° textu "Typ..."
         mov       ax,word ptr ds:[smodel]  ; systÇmovò model a submodel
                                          ;* "PC" (ff00h)
         xor       cl,cl                    ; typ - origin†ln° PC
         inc       al                       ; je model 0ffh ("PC")?
         jz        zobrtyp3                 ; je PC
                                          ;* "PC-XT" (fe00h)
         inc       cl                       ; typ - "PC-XT"
         inc       al                       ; je model 0feh ("PC XT") ?
         jz        zobrtyp3                 ; je "PC XT"
                                          ;* "PCjr" (fd00h)
         inc       cl                       ; typ - "PCjr"
         inc       al                       ; je model 0fdh ("PCjr") ?
         jz        zobrtyp3                 ; je "PCjr"
                                          ;* "AT/XT-286" (fch)
         inc       cl                       ; typ - "AT"
         inc       al                       ; je model 0fch ("AT/XT-286") ?
         jnz       zobrtyp2                 ; nen° model "AT/XT-286")
         cmp       ah,2                     ; je podmodel 2 ?
         jne       zobrtyp3                 ; nen° podmodel 2 - je "AT"
         inc       cl                       ; typ - "XT-286"
         jmp       short zobrtyp3           ; je "XT-286"
                                          ;* "XT"
zobrtyp2:inc       cl                       ; p©eskoáen° "XT-286"
         inc       cl                       ; typ - "XT"
         inc       al                       ; je model 0fbh ("XT") ?
         jz        zobrtyp3                 ; je "XT"
                                          ;* "Konvertabiln° PC"
         inc       al                       ; p©eskoáen° modelu 0fah
         inc       cl                       ; typ - "Konvertabiln° PC"
         inc       al                       ; je model 0f9h ("konvert. PC") ?
         jz        zobrtyp3                 ; je "Konvertabiln° PC"
                                          ;* nezn†mò typ
         inc       cl                       ; nezn†mò typ poá°taáe
zobrtyp3:lea       si,[tabtyp]              ; texty typñ poá°taáñ
         call      outind                   ; zobrazen° textu
         ret
; -----------------------------------------------------------------------------
public   zobrdos
zobrdos:                                  ;* zobrazen° verze oper. systÇmu
         lea       si,[txtdos]              ; text "Operaán° systÇm: "
         call      outtxtx                  ; zobrazen° £vodn°ho textu
                                          ;* n†zev operaán°ho systÇmu
         lea       si,[tabdos]              ; tabulka n†zvñ DOS
         xor       cl,cl
         call      outind                   ; zobrazen° n†zvu systÇmu

         call      outspc                   ; zobrazen° oddàlovac° mezery
                                          ;* zobrazen° hlavn°ho á°sla verze
         mov       ax,ds:[verze]
         push      ax
         xchg      al,ah
         call      outcis                   ; zobrazen° á°slice
         mov       al,"."
         call      outch                    ; zobrazen° oddàlovac° teáky
         pop       ax
         cbw                                ; AX <- AL
         mov       bl,10                    ; dàlitel
         div       bl                       ; vòpoáet des°tek á°sla
         call      outcis                   ; zobrazen° des°tek podverze
         xchg      al,ah
         call      outcis                   ; zobrazen° jednotek podverze
         ret
; -----------------------------------------------------------------------------
public   zobrbios
zobrbios:                                 ;* zobrazen° verze BIOS
         lea       si,[txtbios]             ; text "Datum vzniku BIOS: "
         call      outtxtx                  ; zobrazen° textu "BIOS"
                                          ;* zobrazen° dne
         mov       al,ds:[biosden]          ; den vzniku BIOS
         call      outnum0                  ; zobrazen° dne
         mov       al,"."
         call      outch                    ; zobrazen° teáky
;         call      outspc                   ; oddàlovac° mezera
         mov       cl,ds:[biosmes]          ; màs°c BIOS
         cmp       cl,12
         jbe       zobrbio2
         xor       cl,cl
zobrbio2:lea       si,[tabmes]              ; tabulka màs°cñ
         call      outind                   ; zobrazen° màs°ce
         call      outspc                   ; zobrazen° mezery
         mov       ax,ds:[biosrok]          ; rok BIOS
         call      outnum                   ; zobrazen° roku
         ret
; -----------------------------------------------------------------------------
public   zobrproc
zobrproc:                                 ;* zobrazen° hlavn°ho procesoru
         lea       si,[txtproc]             ; text "Hlavn° procesor:"
         call      outtxtx                  ; zobrazen° textu "procesor"
         mov       cl,ds:[procesor]         ; hlavn° procesor
         lea       si,[tabproc]             ; tabulka procesorñ
         call      outind                   ; zobrazen° procesoru

         mov       ax,ds:[modelcpu]
         or        ax,ax                    ; je zn†m model procesoru ?
         jz        zobrprc2                 ; model nen° zn†m
         mov       si,offset tabprocm
         call      outtxt                   ; zobrazen° textu "model"

         xchg      al,ah
         call      hexchr                   ; zobrazen° hlavn°ho á°sla CPU
         mov       al,"."
         call      outch
         mov       al,ah
         call      hexbyte                  ; zobrazen° modelu

zobrprc2:mov       si,offset vendrcpu
         cmp       byte ptr ds:[si],0       ; je ©etàzec ?
         je        zobrprc4                 ; nen° ©etàzec
         call      outspc
         call      outtxt

zobrprc4:ret
; -----------------------------------------------------------------------------
public   zobrkopr
zobrkopr:                                 ;* zobrazen° koprocesoru
         lea       si,[txtkopr]             ; text "Koprocesor:"
         call      outtxtx                  ; zobrazen° textu "koprocesor"
         mov       cl,ds:[koproc]           ; koprocesor
         lea       si,[tabkopr]             ; tabulka koprocesorñ
         call      outind                   ; zobrazen° koprocesoru
         ret
; -----------------------------------------------------------------------------
public   zobrport
zobrport:                                 ;* zobrazen° portñ
         lea       si,[txtserp]             ; test "Seriove porty"
         mov       di,400h
         call      zobradp0                 ; zobrazen° adres portñ
zobradp0:                                 ;* zobrazen° adres portñ
         push      es
         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         call      outtxtx                  ; zobrazen° textu "seriove porty"
         mov       cx,4                     ; poáet moënòch adres
         xor       dx,dx                    ; á°taá platnòch portñ
zobradp1:mov       ax,es:[di]               ; adresa portu
         add       di,2                     ; adresa dal®°ho portu
         or        ax,ax                    ; je port definov†n ?
         jz        zobradp3                 ; port nen° definov†n
         or        dx,dx                    ; je to prvn° port ?
         jz        zobradp2                 ; je to prvn° port
         call      outoddel                 ; zobrazen° oddàlovac° á†rky
;         push      ax
 ;        mov       al,","                   ; oddàlovac° á†rka
;         call      outch                    ; zobrazen° oddàlovac° á†rky
;         pop       ax
zobradp2:call      outwordh                 ; zobrazen° adresy portu
         inc       dx                       ; zvò®en° á°taáe portñ
zobradp3:loop      zobradp1                 ; dal®° port
         pop       es
         ret
; -----------------------------------------------------------------------------
public   zobrcard
zobrcard:                                 ;* zobrazen° grafickÇ karty
         lea       si,[txtcard]             ; text "Graf. karta:"
         call      outtxtx                  ; zobrazen° textu "Graf. karta"
         mov       cl,ds:[VideoCard]        ; graf. karta
         lea       si,[tabcard]             ; tabulka graf. karet
         call      outind                   ; zobrazen° graf. karty

         cmp       cl,11
         je        zobrcar4                 ; je VESA
         cmp       cl,9
         je        zobrcar1                 ; je VGA
         cmp       cl,3
         jb        zobrcar2
         cmp       cl,5
         ja        zobrcar2

zobrcar1:mov       ah,12h
         mov       bl,10h
         int       10h
         mov       cl,bl
         cmp       cl,3
         ja        zobrcar2
         call      outspc
         lea       si,[tabega]
         call      outind
zobrcar2:
         ret

zobrcar4:mov       ax,ds:[VesaMEM]          ; pamàü VESA
         call      outnum                   ; zobrazen° velikosti pamàti

         lea       si,[txtkb]
         call      outtxt                   ; zobrazen° textu "KB"
         ret

; -----------------------------------------------------------------------------
public   zobrdisk
zobrdisk:                                 ;* zobrazen° disketovòch mechanik
         lea       si,[txtdisk]
         call      outtxtx                  ; zobrazen° textu "Disket. mech.:"

         mov       al,ds:[disket]           ; poáet disketovòch mechanik
         mov       cl,al                    ; poáet disket. mechanik
                                          ;* je nàjakò zn†mò typ ?
         or        al,al
         jz        zobrdsk4                 ; nen° ë†dn† mechanika
         mov       bx,word ptr ds:[disket1]
         or        bx,word ptr ds:[disket2]
         jz        zobrdsk4                 ; nen° zn†m† disket. mechanika

         mov       si,offset disket1        ; tabulka disket. mechanik
         xor       ch,ch
zobrdsk2:lodsb                              ; typ disket. mechaniky
         and       al,0fh
         cmp       al,5                     ; max. typ mechaniky
         jbe       zobrdsk3                 ; povolenò typ mechaniky
         xor       al,al                    ; n†hradn° á°slo - nezn†m†
zobrdsk3:push      cx
         push      si
         mov       cl,al                    ; á°slo typu mechaniky
         lea       si,[tabdisk]             ; tabulka typñ diskñ
         call      outind                   ; zobrazen° typu mechaniky
         pop       si
         pop       cx
         cmp       cl,1                     ; n†sleduje je®tà nàjak† mechanika ?
         jbe       zobrdsk5                 ; nen° dal®° mechanika
         call      outoddel                 ; zobrazen° oddàlovac° á†rky
;         mov       al,","
;         call      outch
 ;        call      outspc
zobrdsk5:loop      zobrdsk2                 ; dal®° mechanika
         ret

zobrdsk4:                                 ;* zobrazen° poátu mechanik
         call      outnum0                  ; zobrazen° poátu disket. mechanik
         ret
; -----------------------------------------------------------------------------
public   zobrwin
zobrwin:                                  ;* zobrazen° pevnòch diskñ
         lea       si,[txtwin]
         call      outtxtx                  ; zobrazen° textu "PevnÇ disky:"

         mov       di,offset winchs0        ; definice pevnÇho disku 0
         cmp       word ptr ds:[di],0       ; je disk definovanò ?
         jz        zobrwin1                 ; disk nen° definovanò
         call      zobrwin2                 ; zobrazen° pevnÇho disku 0
         cmp       word ptr ds:[winchs1],0  ; je definov†n pevnò disk 1 ?
         jz        zobrwin7                 ; pevnò disk 1 nen° definov†n
         call      outoddel                 ; zobrazen° oddàlovac° á†rky
zobrwin1:mov       di,offset winchs1        ; definice pevnÇho disku 1
zobrwin2:                                 ;* zobrazen° pevnÇho disku
         mov       ax,ds:[di]               ; velikost pevnÇho disku
         or        ax,ax                    ; je disk definov†n ?
         jz        zobrwin7                 ; disk nen° definov†n
         call      outnum                   ; zobrazen° á°sla v AX
         mov       si,offset txtwin1        ; text " MB"
         call      outtxt                   ; zobrazen° textu " MB"
         mov       al,ds:[di+2]             ; typ pevnÇho disku
         or        al,al                    ; je typ definov†n ?
         jz        zobrwin7                 ; typ nen° definov†n
         mov       si,offset txtwin2        ; text "(typ"
         call      outtxt                   ; zobrazen° textu "(typ "
         call      outnum0                  ; zobrazen° á°sla typu
         mov       al,")"
         call      outch                    ; zobrazen° z†vàreánÇ mezery
zobrwin7:ret
; -----------------------------------------------------------------------------
public   zobrmem
zobrmem:                                  ;* zobrazen° celkovÇ pamàti
         lea       si,[txtmem]
         call      outtxtx                  ; zobrazen° textu "Celkov† pamàü:"

         mov       ax,ds:[memory]           ; celkov† pamàü
         lea       si,[txtkb]               ; text "KB"

         cmp       ax,1100
         jb        zobrmem1                 ; je mal† pamàü

         mov       cl,10                    ; p©evod na MB
         shr       ax,cl                    ; p©evod na MB
         mov       si,offset txtmb          ; text "MB"

zobrmem1:call      outnum                   ; zobrazen° velikosti pamàti
         call      outtxt                   ; zobrazen° textu "KB" nebo "MB"
         ret

; -----------------------------------------------------------------------------
public   zobrrom
zobrrom:                                  ;* zobrazen° modulñ ROM-BIOS
         sti
         lea       si,[txtrom]
         call      outtxtx                  ; zobrazen° textu "Moduly ROM:"

         xor       dx,dx                    ; á°taá zobrazenòch adres
         mov       ax,0c000h                ; poá†teán° segment pro testy
zobrrom1:call      findrom                  ; nalezen° ROM
         jc        zobrrom4                 ; nen° dal®° modul ROM
         or        dx,dx                    ; je to prvn° adresa ?
         jz        zobrrom2                 ; je to prvn° adresa
         call      outoddel                 ; zobrazen° oddàlovaáe
zobrrom2:call      outwordh                 ; zobrazen° segmentu modulu ROM
         inc       dx                       ; zvò®en° á°taáe zobrazenòch adres
         mov       ax,bx                    ; dal®° adresa pro hled†n°
         cmp       ax,0c000h                ; je spr†vn† adresa ?
         ja        zobrrom1                 ; nalezen° dal®°ho modulu
zobrrom4:ret

public   findrom
findrom:                                  ;* nalezen° modulu ROM-BIOS
                                            ; VSTUP: AX=poá†teán° segment
                                            ; VùSTUP: AX=segment dal®°ho modulu
                                            ;         BX=segment za modulem
                                            ;         CY=nen° dal®° modul ROM


         push      es
         push      dx
findrom2:mov       es,ax                    ; testovanò segment
         cmp       word ptr es:[0],55aah    ; je z†kladn° modul ROM-BIOS ?
         je        findrom1                 ; je z†kladn° modul ROM-BIOS
         cmp       word ptr es:[0],0aa55h   ; je identifikace modulu ROM ?
         je        findrom1                 ; nen° modul ROM
         add       ax,80h                   ; adresa dal®°ho modulu
         jnc       findrom2                 ; test dal®°ho modulu
         jmp       short findrom5           ; konec - modul nenalezen
findrom1:xor       bx,bx                    ; BX <- 0
         mov       bl,es:[2]                ; dÇlka modulu ROM
         mov       cl,5                     ; poáet rotac° pro p©evod
         shl       bx,cl                    ; p©evod na odstavce
         add       bx,ax                    ; novò konec modulu
         clc
findrom5:pop       dx
         pop       es
         ret
; -----------------------------------------------------------------------------
public   zobrhod
zobrhod:                                  ;* zobrazen° hodin procesoru
         lea       si,[txthod]
         call      outtxtx                  ; zobrazen° textu "Hodiny:"

         test      word ptr ds:[prepinac],8000h ; je cejchov†n° hodin ?
         jz        zobrhod2                 ; nen° cejchov†n° hodin
         mov       ax,ds:[hodinyh]          ; vy®®° slovo hodin
         call      outnum
         mov       al,"-"
         call      outch
zobrhod2:mov       ax,ds:[hodiny]
         call      outnum                   ; zobrazen° hodin procesoru
         cmp       byte ptr ds:[procesor],7
         jb        zobrhod4                 ; nië®° procesor neë 286
         mov       al,"."
         call      outch
         cmp       byte ptr ds:[hodinyd],10
         jae       zobrhod3
         mov       al,"0"
         call      outch
zobrhod3:xor       ah,ah
         mov       al,ds:[hodinyd]          ; desetiny udaje
         call      outnum
zobrhod4:lea       si,[txtmhz]
         call      outtxt                   ; zobrazen° textu "MHz"
         ret
; -----------------------------------------------------------------------------
public   zobrlogd
zobrlogd:                                 ;* zobrazen° logickòch diskñ
         lea       si,[txtlogd]
         call      outtxtx                  ; zobrazen° textu "logickÇ disky:"
                                          ;* £schova aktivn°ho disku
         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         push      ax                       ; £schova aktivn°ho disku

         xor       bx,bx                    ; BH-p©°znak zobrazen°
         xor       dx,dx
         mov       cx,32                    ; poáet diskñ k provà©en°
zobrlog1:                                 ;* test jednoho disku
         mov       ah,0eh
         int       21h                      ; vòbàr aktivn°ho disku
         mov       ah,19h
         int       21h                      ; dotaz na novò aktivn° disk
         cmp       al,dl                    ; byl disk zmànàn ?
         jne       zobrlog4                 ; disk nebyl zmànàn
         or        bx,bx                    ; byl jië zobrazen nàjakò disk ?
         jz        zobrlog2                 ; nebyl je®tà ë†dnò disk
         call      outoddel                 ; zobrazen° oddàlovaáe parametrñ
zobrlog2:inc       bx                       ; zvò®en° á°taáe diskñ
         add       al,"A"                   ; korekce na oznaáen° ASCII
         call      outch                    ; zobrazen° oznaáen° disku
zobrlog4:inc       dx                       ; zvò®en° á°sla disku
         loop      zobrlog1                 ; test dal®°ho disku
                                          ;* n†vrat aktivn°ho disku
         pop       dx                       ; n†vrat aktivn°ho disku
         mov       ah,0eh
         int       21h                      ; n†vrat pñvodn°ho aktivn°ho disku
         ret

; -----------------------------------------------------------------------------
;                          Univerz†ln° podprogramy
; -----------------------------------------------------------------------------
public   readcmos
readcmos:                                 ;* áten° bajtu z CMOS s kontrolou
                                            ; VSTUP: AH=adresa
                                            ; VùSTUP: AL=bajt
                                            ;         CY=chyba (data neplat°)

         push      dx
         xor       al,al                    ; p©ednastaven° dat
         call      chscmos                  ; kontroln° souáet CMOS
         jc        readcm4                  ; neplatnò typ poá°taáe
         stc
         jne       readcm4                  ; chybnò kontroln° souáet
         call      rcmos                    ; áten° bajtu z CMOS
         clc                                ; p©°znak - operace OK
readcm4: pop       dx
         ret

public   chscmos
chscmos:                                  ;* kontroln° souáet CMOS
                                            ; VùSTUP: DX=kontroln° souáet
                                            ;         CY=chybnò typ poá°taáe
                                            ;         ZY=kontroln° souáet OK

         push      ax
         push      cx
         xor       dx,dx
         mov       cl,ds:[smodel]           ; systÇmovò model
         cmp       cl,0feh                  ; je PC nebo PC-XT ?
         cmc
         jc        chscmos2                 ; je PC nebo PC-XT
         cmp       cl,0fbh                  ; je XT ?
         stc
         je        chscmos2                 ; je XT
         mov       cx,1eh                   ; poáet bajtñ ke kontrole
         mov       ah,10h                   ; poá†teán° adresa
chscmos1:                                 ;* proveden° kontroln°ho souátu
         call      rcmos                    ; áten° bajtu z CMOS
         add       dl,al                    ; p©iáten° ke kontroln°mu souátu
         adc       dh,0                     ; p©enos do vy®®°ho bajtu
         inc       ah                       ; zvò®en° ukazatele pamàti
         loop      chscmos1                 ; dal®° bajt
                                          ;* kontrola kontroln°ho souátu
         mov       ah,2eh                   ; adresa vy®®°ho bajtu
         call      rcmos                    ; áten° vy®®°ho bajtu z CMOS
         mov       ch,al                    ; £schova vy®®°ho bajtu
         inc       ah                       ; adresa nië®°ho bajtu
         call      rcmos                    ; áten° nië®°ho bajtu z CMOS
         mov       cl,al                    ; £schova nië®°ho bajtu
         cmp       dx,cx                    ; porovn†n° kontroln°ho souátu
         clc                                ; p©°znak - operace OK
chscmos2:pop       cx
         pop       ax
         ret

public   rcmos
rcmos:                                    ;* áten° bajtu z CMOS
                                            ; VSTUP: AH=adresa
                                            ; VùSTUP: AL=bajt

         push      ax
         mov       al,ah                    ; adresa bajtu z CMOS
         out       [70h],al                 ; nastaven° adresy pro áten°
         pop       ax
         in        al,[71h]                 ; data na adrese v CMOS
         ret
; -----------------------------------------------------------------------------
public   outtxt
outtxt:                                   ;* vòstup textu DS:SI
         push      ax
outtxt1: lodsb
         or        al,al                    ; je konec textu ?
         jz        outtxt2
         call      outch                    ; vòstup znaku
         jmp       short outtxt1
outtxt2: pop       ax
         ret
; -----------------------------------------------------------------------------
public   outtxtx
outtxtx:                                  ;* vòstup textu s od©†dkov†n°m
         push      ax
         mov       al,13
         call      outch
         mov       al,10
         call      outch
         pop       ax
         call      outtxt
         jmp       short outspc

public   outoddel
outoddel:                                 ;* zobrazen° oddàlovac° á†rky
         push      ax
         mov       al,","
         call      outch
         pop       ax

public   outspc
outspc:                                   ;* zobrazen° mezery
         push      ax
         mov       al," "
         call      outch                    ; zobrazen° mezery
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outch
outch:                                    ;* vòstup znaku z AL
         push      ax
         push      dx
         mov       dl,al
         mov       ah,2
         int       21h                      ; vòstup znaku
         pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outind
outind:                                   ;* zobrazen° indexovanÇho textu
                                            ; VSTUP: DS:SI=tabulka textñ
                                            ;        CL=á°slo poloëky

         push      ax
         push      cx
         push      si
         xor       ch,ch                    ; CH <- 0
         jcxz      outind2                  ; je poloëka 0
outind1: lodsb
         or        al,al                    ; je jië konec poloëky ?
         jnz       outind1                  ; nalezen° konce poloëky
         loop      outind1                  ; dal®° poloëka
outind2: call      outtxt                   ; zobrazen° textu
         pop       si
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outnum0
outnum0:                                  ;* zobrazen° á°sla AL
         push      ax
         cbw
         call      outnum
         pop       ax
         ret

public   outnum
outnum:                                   ;* zobrazen° á°sla AX
         push      ax
         push      bx
         push      cx
         push      dx
         xor       cx,cx                    ; á°taá á°slic
outnum1: xor       dx,dx                    ; DX <- 0
         mov       bx,10
         div       bx
         add       dl,"0"                   ; korekce na á°slici ASCII
         push      dx                       ; ul¢zen° á°slice do z†sobn°ku
         inc       cx                       ; zvò®en° á°taáe á°slic
         or        ax,ax                    ; je jië 0 ?
         jnz       outnum1                  ; je jië 0
                                          ;* zobrazen° á°sla
outnum2: pop       ax
         call      outch                    ; zobrazen° á°slice
         loop      outnum2                  ; dal®° á°slice
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outwordh
outwordh:                                 ;* zobrazen° slova HEX
         push      ax
         call      outword
         mov       al,"h"
         call      outch
         pop       ax
         ret

public   outword
outword:                                  ;* zobrazen° slova HEX
         xchg      ah,al
         call      outbyte
         xchg      ah,al

public   outbyte
outbyte:                                  ;* zobrazen° bajtu HEX
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      outhex
         pop       ax
outhex:  push      ax
         and       al,0fh
         call      outcis
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outcis
outcis:                                   ;* zobrazen° á°slice AL
         push      ax
         add       al,"0"
         cmp       al,"9"
         jbe       outcis2                  ; nen° á°slice HEX
         add       al,7                     ; korekce na p°smeno HEX
outcis2: call      outch                    ; zobrazen° á°slice
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   hledpar
hledpar:                                  ;* hled†n° parametru
                                            ; VSTUP: AH=znak parametru
                                            ; VùSTUP: CY=parametr nenalezen
                                            ;         DS:SI=text za parametrem

         push      cs
         pop       ds
         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
                                          ;* nalezen° p©ep°naáe "/"
hledpar1:lodsb                              ; naáten° znaku
hledpar2:or        al,al                    ; je konec ?
         stc                                ; p©°znak - p©ep°naá nenalezen
         jz        hledpar3                 ; je konec textu
         cmp       al,"/"                   ; je "/" ?
         jne       hledpar1                 ; nen° "/" - dal®° znak
                                          ;* test hledanÇho p©ep°naáe
         lodsb                              ; naáten° p©ep°naáe
         cmp       al,"a"
         jb        hledpar4
         cmp       al,"z"
         ja        hledpar4
         sub       al,32                    ; p©evod na velkÇ p°smeno
hledpar4:
         cmp       al,ah                    ; je hledanò p©ep°naá ?
         jne       hledpar2                 ; nen° hledanò p©ep°naá

hledpar3:ret
; -----------------------------------------------------------------------------
;                       Detekce videokarty
;
; VùSTUP: AX=1: CGA
;            2: Mono CGA
;            3: EGA
;            4: EGA 64kB
;            5: EGA Mono
;           (6: IBM8514)
;            7: Hercules
;           (8: ATT400)
;            9: VGA
;           10: PC3270
; -----------------------------------------------------------------------------
PUBLIC   DetectCard
DetectCard:                               ;* detekce videokarty
                                            ; VùSTUP: AX=detekovan† karta
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         call      DetCard0                 ; detekce videokarty
         xor       ax,ax
         mov       al,ds:[VideoCard]        ; detekovan† videokarta
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

; ------ test VESA

DetCard0:call      GetVESA                  ; test VESA
         jc        DetCar02                 ; nen° VESA
         mov       byte ptr ds:[VideoCard],11 ; je karta VESA
         ret

DetCar02:call      GetVideoMod              ; dotaz na videom¢d
         cmp       al,7                     ; je monochromatickò videom¢d ?
         je        DetCard5                 ; je monochromatickò videom¢d
                                          ;* barevnò reëim - rozpozn†n° EGA/VGA
         call      DetCard8                 ; test karet EGA/VGA
         jc        DetCard2                 ; nen° karta EGA/VGA
DetCard1:call      DetCardA                 ; rozli®en° karet EGA/VGA
         ret
DetCard2:                                 ;* rozpozn†n° karty PC3270
         call      DetCardP                 ; detekce karty PC3270
         jc        DetCard3                 ; nen° karta PC3270
         mov       byte ptr ds:[VideoCard],10; je videokarta PC3270
         ret

DetCard3:                                 ;* rozpozn†n° karet CGA/MCGA
         mov       byte ptr ds:[VideoCard],1; p©ednastaven° karty CGA
         call      DetCardG                 ; test karty MCGA
         jc        DetCard4                 ; nen° karta MCGA
         mov       byte ptr ds:[VideoCard],2; je karta MCGA
DetCard4:ret

DetCard5:                                 ;* monochrom. reëim - test EGA/VGA
         call      DetCard8                 ; test karty EGA/VGA
         jnc       DetCard1                 ; je EGA/VGA - rozli®en° EGA a VGA
                                          ;* test karty Hercules/MDA
         call      DetCardJ                 ; test karty Hercules
         jc        DetCard6                 ; nen° karta Hercules
         mov       byte ptr ds:[VideoCard],7; je karta Hercules
         ret
DetCard6:                                 ;* test karty CGA (test pamàti)
         mov       si,0b800h                ; segment videopamàti CGA
         mov       es,si                    ; segment videopamàti CGA
         xor       si,si                    ; poá†teán° adresa videopamàti CGA
         mov       ax,es:[si]               ; pñvodn° slovo z videopamàti
         not       ax                       ; inverze
         not       word ptr es:[si]         ; inverze i pñvodn°ho slova
         nop
         nop
         cmp       ax,es:[si]               ; je tam pamàü RAM ?
         jne       DetCard7                 ; nen° pamàü VRAM
         mov       byte ptr ds:[VideoCard],1; je karta CGA
DetCard7:ret

DetCard8:                                 ;* test karty EGA/VGA
         mov       ax,1200h
         mov       bl,10h                   ; podsluëba poskytnut° parametrñ
         mov       bh,0ffh                  ; p©ednastaven°
         mov       cl,0fh                   ; p©ednastaven°
         call      int10p                   ; dotaz na EGA kartu
         cmp       cl,0ch
         jge       DetCard9                 ; nen° karta EGA
         cmp       bh,1
         jg        DetCard9                 ; nen° karta EGA
         cmp       bl,3
         jg        DetCard9                 ; nen° karta EGA
         clc                                ; p©°znak - je karta EGA
         ret
DetCard9:stc                                ; p©°znak - nen° karta EGA
         ret

DetCardA:                                 ;* rozli®en° karet EGA/VGA
         mov       byte ptr ds:[VideoCard],4; p©ednastaven° karty EGA64
;         cmp       bh,1                     ; je monochromatickò m¢d ?
;         je        DetCardD                 ; je monochromatickò m¢d
         call      DetCardE                 ; test karty EGA 64
         jnc       DetCardC                 ; je karta EGA 64
         or        bl,bl                    ; je EGA 64 ?
         jz        DetCardC                 ; je EGA 64
         mov       byte ptr ds:[VideoCard],3; p©ednastaven° karty EGA
         call      DetCardG                 ; test karty VGA
         jnc       DetCardB                 ; je karta VGA
         mov       bx,0c000h                ; segment s ROM VGA
         mov       es,bx                    ; segment s ROM VGA
         mov       bx,39h                   ; adresa textu "Z449"
         cmp       word ptr es:[bx],"Z4"    ; je text "Z4" ?
         jne       DetCardC                 ; nen° karta VGA
         cmp       word ptr es:[bx+2],"49"  ; je text "49" ?
         jne       DetCardC                 ; nen° karta VGA
DetCardB:mov       byte ptr ds:[VideoCard],9; je karta VGA
DetCardC:ret
;DetCardD:mov       byte ptr ds:[VideoCard],5; je karta EGA Mono
;         ret

DetCardE:                                 ;* test karty EGA 64
         cmp       cl,2
         jb        DetCardT                 ; je karta EGA 64
         cmp       cl,6
         jb        DetCardF                 ; nen° karta EGA 64
         cmp       cl,8
DetCardT:cmc
DetCardF:ret

DetCardG:                                 ;* test karty VGA
         mov       ax,1a00h
         call      int10p                   ; dotaz na poáet linek na znak
         cmp       al,1ah                   ; je funkce obsluhovan† ?
         jne       DetCardI                 ; funkce nen° obsluhovan†
         cmp       bl,7                     ; je 7 linek na znak ?
         je        DetCardH                 ; je karta OK
         cmp       bl,8
         je        DetCardH                 ; je karta OK
         cmp       bl,11
         jb        DetCardI                 ; nen° karta
         cmp       bl,12
         ja        DetCardI                 ; nen° karta
DetCardH:clc                                ; p©°znak - je karta
         ret
DetCardI:stc                                ; p©°znak - nen° karta
         ret

DetCardJ:                                 ;* test karty Hercules
         mov       dx,03bah                 ; stavovò port karty
         xor       bl,bl                    ; á°taá doby impulsu
         in        al,dx                    ; poá†teán° stav
         and       al,80h                   ; sign†l zpàtnÇho bàhu
         mov       ah,al                    ; £schova stavu registru
         mov       cx,8000h                 ; maxim†ln° doba testu
DetCardK:                                 ;* áek†n° na zmànu stavu bitu 7
         in        al,dx                    ; áten° stavovÇho registru
         and       al,80h                   ; sign†l zpàtnÇho bàhu
         cmp       al,ah                    ; byla zmàna stavu sign†lu ?
         je        DetCardL                 ; nebyla zmàna stavu sign†lu
         inc       bl                       ; á°taá dÇlky impulsu
         cmp       bl,10                    ; je minim†ln° doba impulsu ?
         jae       DetCardM                 ; impuls je dostateánà dlouhò
DetCardL:loop      DetCardK                 ; dal®° test impulsu
         stc                                ; p©°znak - nen° karta Hercules
         ret

DetCardM:                                 ;* áek†n° na bity 5,4 -> 01
         mov       cx,8000h                 ; maxim†ln° doba testu
DetCardN:in        al,dx                    ; áten° stavovÇho registru
         and       al,30h
         cmp       al,10h
         jne       DetCardO                 ; je pouze karta MDA
         loop      DetCardN                 ; dal®° test
         mov       al,2                     ; p©°znak - je karta Hercules
         clc
         ret
DetCardO:mov       al,1                     ; p©°znak - je karta MDA
         clc
         ret

DetCardP:                                 ;* test videokarty PC3270
         mov       al,6
         xor       cx,cx                    ; CX <- 0
         xor       dx,dx
         mov       ah,30h
         call      int10p
         mov       ax,cx
         or        ax,dx
         jz        DetCardR                 ; nen° karta PC3270
         push      ds
         mov       ds,cx                    ; segment
         mov       bx,dx                    ; offset
         mov       al,ds:[bx+2]
         pop       ds
         or        al,al
         jz        DetCardQ                 ; je karta PC3270
         cmp       al,2
         jne       DetCardR                 ; nen° karta PC3270
DetCardQ:mov       dx,188h
         in        al,dx
         test      al,4
         jz        DetCardR                 ; nen° karta PC3270
         clc                                ; p©°znak - je karta PC3270
         ret
DetCardR:stc                                ; p©°znak - nen° karta PC3270
         ret

; ------ test karty VESA

GetVESA  PROC      NEAR

         mov       di,offset DiskBuf
         mov       word ptr ds:[di],0       ; p©ednastaven° - neplatn† data
         push      ds
         pop       es
         mov       ax,4f00h
         call      Int10P

         cmp       ax,4fh
         jne       GetVESA8                 ; chyba
         cmp       word ptr ds:[di],"EV"
         jne       GetVESA8
         cmp       word ptr ds:[di+2],"AS"
         jne       GetVESA8

         mov       ax,ds:[di+12h]           ; pamàü celkem v 64K bloc°ch
         mov       cl,6
         shl       ax,cl                    ; pamàü v 1KB bloc°ch
         mov       ds:[VesaMEM],ax          ; pamàü VESA
         clc                                ; operace OK
         ret

GetVESA8:stc                                ; p©°znak chyby
         ret

GetVESA  ENDP

; -----------------------------------------------------------------------------
;                       Poskytnut° videom¢du
;
; VùSTUP: AL=aktu†ln° videom¢d
;         AH=poáet pozic na ©†dek
;         BH=á°slo aktivn° str†nky
; -----------------------------------------------------------------------------
PUBLIC   GetVideoMod
GetVideoMod:                              ;* poskytnut° videom¢du
                                            ; VùSTUP: AL=videm¢d
                                            ;         AH=poáet pozic na ©†dek
                                            ;         BH=á°slo aktivn° str†nky

         mov       ah,0fh                   ; funkce poskytnut° videom¢du
         call      int10p
         and       al,7fh                   ; zru®en° bitu 7
         ret
; -----------------------------------------------------------------------------
int10p:                                   ;* vol†n° INT 10h s £schovou registrñ
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
         ret

;------------------------------------------------------------------------------
;                         Zobrazen° obsahu pamàti
;------------------------------------------------------------------------------
;˛
memorydos:                                ;* zobrazen° obsahu pamàti
         push      cs
         pop       ds
;         mov       ax,ds:[2]                ; konec pamàti
;         mov       cs:[memmax],ax           ; konec pamàti
;
;                                          ;* zmen®en° bloku pamàti
;         mov       bx,offset konec + 1024   ; konec programu
;         add       bx,15                    ; zaokrouhlen° na odstavec
;         mov       cl,4
;         shr       bx,cl                    ; p©epoáet na odstavce
;         mov       ah,4ah                   ; funkce modifikace bloku pamàti
;         int       21h                      ; zmen®en° bloku pamàti
                                          ;* zobrazen° nadpisu
         lea       bx,[txtnadp]
         call      outtxtz                  ; zobrazen° nadpisu
         call      srcfrst                  ; nalezen° prvn°ho alokaán°ho bloku
         jnc       mem1
         jmp       mem9                     ; chyba pamàti
                                          ;* zobrazen° obahu pamàti
mem1:    mov       cs:[memmax],ax           ; poá†tek pamàti

mem2:    mov       ds,ax                    ; segment alok. bloku

         push      ax

         cmp       ax,0b800h                ; je pod hranic° UMB ?
         ja        mem21                    ; nen° pod hranic° UMB
         add       ax,ds:[3]                ; n†sleduj°c° blok
         cmp       ax,0b800h                ; p©eskakuje hranici UMB ?
         jae       mem22                    ; p©eskakuje hranici 1 MB

mem21:   mov       ax,ds:[3]                ; velikost bloku
         add       cs:[memmax],ax           ; zvò®en° á°taáe pamàti

mem22:   mov       ax,ds
         call      testfre                  ; test, zda je volnò
         jc        mem4                     ; nen° to volnò blok
         mov       ax,ds:[3]                ; velikost bloku
         add       cs:[memfree],ax          ; á°taá volnÇ pamàti

         cmp       ax,cs:[memspoj]          ; je vàt®° blok ?
         jbe       mem4
         mov       cs:[memspoj],ax          ; je to vàt®° volnò blok

mem4:    pop       ax

         mov       cl,2
         call      outtab                   ; nastaven° tabel†toru
         push      ax
         inc       ax
         call      hexwrd                   ; zobrazen° slova HEX
         mov       cl,8
         call      outtab                   ; nastaven° na dal®° znaáku tabel.
         call      vlastnik                 ; zobrazen° vlastn°ka
         mov       cl,8
         call      outtab                   ; nastaven° na dal®° znaáku tabel.
         mov       ax,ds:[3]                ; velikost bloku
         call      deknms                   ; zobrazen° velikosti segmentu
         mov       cl,8
         call      outtab                   ; nastaven° na dal®° znaáku tabel.
         call      typ                      ; zobrazen° typu bloku
         mov       cl,11
         call      outtab                   ; nastaven° na dal®° znaáku tabel.
         call      pathenv                  ; zobrazen° p©°stupovÇ cesty
         call      outcr
         pop       ax
         mov       ds,ax

         cmp       byte ptr ds:[0],"Z"      ; je jië posledn° blok ?
         jne       mem8

         cmp       ax,0b800h
         ja        mem9                     ; je to jië posledn° blok UMB

         push      ax
         call      srcnxt                   ; dal®° blok
         jc        mem6
         call      testblk
mem6:    pop       ax
         jc        mem9                     ; byl to jië posledn° alok. blok

         lea       bx,[txtumb]              ; text "UMB"
         call      outtxtz                  ; zobrazen° nadpisu

mem8:    call      srcnxt                   ; nastaven° na dal®° alok. blok
         jc        mem9
         jmp       mem2                     ; dal®° alok. blok

mem9:                                     ;* konec zobrazen° pamàti
         push      cs
         pop       ds
         call      outcr
                                          ;* celkov† pamàü
         lea       bx,[txtcelk]             ; text "Celkov† pamàü"
         call      outtxtz

         mov       ax,cs:[memmax]           ; konec pamàti
         call      deknms                   ; zobrazen° informace o pamàti
         call      outcr                    ; novò ©†dek
                                          ;* voln† pamàü
         lea       bx,[txtvoln]             ; text "Voln† pamàü"
         call      outtxtz

         mov       ax,cs:[memfree]          ; voln† pamàü
         call      deknms                   ; zobrazen° informace o volnÇ pamàti
         call      outcr

         lea       bx,[txtspoj]             ; text "Voln† spojit†"
         call      outtxtz

         mov       ax,cs:[memspoj]          ; spojit† pamàü
         call      deknms
         call      outcr
         ret                                ; n†vrat z programu

memmax   dw        0                        ; konec pamàti
memfree  dw        0                        ; voln† pamàü
memspoj  dw        0                        ; voln† pamàü spojit†

; -----------------------------------------------------------------------------
public   pathenv
pathenv:                                  ;* zobrazen° p©°stupovÇ cesty
                                            ; VSTUP: DS=segment alok. bloku
         push      ax
         push      bx
         push      si
         push      ds
         mov       ah,30h
         int       21h                      ; poskytnut° á°sla verze systÇmu
         cmp       al,3                     ; je verze alespo§ 3.00 ?
         jb        pathenv3                 ; je n°zk† verze systÇmu

         mov       ax,ds
         call      testfre                  ; test, zda je volnò
         jnc       pathenv3                 ; nem† vlastn°ka

         call      testprog                 ; test, zda je program
         jc        pathenv3                 ; nen° to program
         mov       ds,bx                    ; popisovaá prost©ed°
         inc       ax
         cmp       ax,ds:[1]                ; pat©° to tomu programu ?
         jne       pathenv3                 ; nepat©°
         inc       bx                       ; segment prost©ed°
         jz        pathenv3                 ; neplat°

         mov       ds,bx                    ; segment prost©ed°
         mov       si,3                     ; poá†teán° offset prost©ed° + 3
         xor       ax,ax                    ; AX <- 0 (hledanÇ slovo)
                                          ;* nalezen° zaá†tku cesty
pathenv1:inc       si                       ; zvò®en° adresy textu
         cmp       ds:[si-4],ax             ; je konec ©etàzcñ prost©ed° (0) ?
         jne       pathenv1                 ; nen° konec ©etàzcñ prost©ed°
         inc       ax
         cmp       ds:[si-2],ax             ; je nàjakò ©etàzec ?
         jne       pathenv3                 ; chybnò ©etàzec
pathenv2:                                 ;* zobrazen° ©etàzce cesty
         lodsb
         or        al,al
         jz        pathenv3
         call      outchh
         jmp       short pathenv2
pathenv3:pop       ds
         pop       si
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   typ
typ:                                      ;* zobrazen° typu bloku
                                            ; VSTUP: DS=segment alok. bloku
         push      ax
         push      ds
         mov       ax,ds                    ; segment bloku
         call      testfre                  ; test, zda je volnò
         lea       bx,[typvol]              ; text "voln†"
         jnc       typ6                     ; je volnò blok

         call      testprog                 ; je to program ?
         lea       bx,[typprog]             ; text "PROGRAM"
         jnc       typ6                     ; je program
                                          ;* test, jestli je prost©ed°
         mov       ax,dx                    ; novò segment
         dec       ax
         call      testprog                 ; je to program ?
         jc        typ5                     ; pat©° systÇmu
         mov       ax,ds
         cmp       bx,ax                    ; je to prost©ed° ?
         lea       bx,[typenv]              ; oznaáen° - je to prost©ed°
         je        typ6                     ; je to prost©ed°
         lea       bx,[typdat]              ; jsou to data
         jmp       short typ6
typ5:    lea       bx,[typsys]              ; pat©° systÇmu
typ6:    call      outtxtz                  ; zobrazen° textu typu
typ9:    pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   vlastnik
vlastnik:                                 ;* zobrazen° vlastn°ka bloku
                                            ; VSTUP: DS=segment alok. bloku
         push      ax
         push      ds
                                          ;* volnò alokaán° blok
         mov       dx,ds:[1]                ; vlastn°k bloku
         mov       ax,dx                    ; vlastn°k bloku

         push      ax
         mov       ax,ds
         call      testfre                  ; test, zda je volnò
         pop       ax
         jc        vlast0                   ; nen° volnò
         xor       ax,ax                    ; je volnò

vlast0:  call      hexwrd                   ; zobrazen° slova HEX
         mov       cl,7
         call      outtab                   ; nastaven° na dal®° znaáku tabel.

         mov       ax,ds

         call      testfre                  ; test, zda je volnò
         jc        vlast2                   ; nen° volnò blok

vlast1:  lea       bx,[vlsys]               ; vlastn°k - system
         call      outtxtz                  ; zobrazen° textu
         jmp       short vlast9
                                          ;* je to program
vlast2:  call      namprog                  ; zobrazen° jmÇna programu
         jnc       vlast9                   ; byl to program

vlast4:                                   ;* vlastn°k jej nàkdo jinò
         mov       ax,dx                    ; segment jinÇho vlastn°ka
         dec       ax
         call      namprog                  ; zobrazen° jmÇna jinÇho vlastn°ka
vlast9:  pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
namprog:                                  ;* zobrazen° jmÇna programu
                                            ; VSTUP: AX=adresa alok. bloku
                                            ; VùSTUP: CY=nen° program
         push      ax
         push      bx
         push      cx
         push      si
         push      ds
         mov       ds,ax                    ; segment bloku

         call      testfre                  ; test, zda je volnò
         jnc       namprg2                  ; je to volnò blok
         call      testprog                 ; je to program ?
         jc        namprg2                  ; nen° program
                                          ;* pro verzi 4.00 p©°mÇ zobrazen°
         push      ax
         mov       ah,30h
         int       21h                      ; poskytnut° á°sla verze systÇmu
         cmp       al,4                     ; je verze alespo§ 4.00 ?
         pop       ax
         jae       namprg3                  ; je verze systÇmu alespo§ 4.00
                                          ;* nalezen° jmÇna programu pro DOS3.xx
         mov       ds,ds:[3ch]              ; segment prost©ed°
         mov       si,3                     ; poá†teán° offset prost©ed° + 3
         xor       ax,ax                    ; AX <- 0 (hledanÇ slovo)
                                          ;* nalezen° zaá†tku cesty
namprg4: inc       si                       ; zvò®en° adresy textu
         cmp       ds:[si-4],ax             ; je konec ©etàzcñ prost©ed° (0) ?
         jne       namprg4                  ; nen° konec ©etàzcñ prost©ed°
         inc       ax
         cmp       ds:[si-2],ax             ; je nàjakò ©etàzec ?
         jne       namprg8                  ; chybnò ©etàzec
                                          ;* nalezen° zaá†tku jmÇna
namprg5: mov       bx,si                    ; novò zaá†tek jmÇna
namprg6: lodsb
         or        al,al
         jz        namprg7                  ; je konec jmÇna
         cmp       al,"\"                   ; je oddàlovaá cesty ?
         je        namprg5                  ; je novò oddàlovaá cesty
         jmp       short namprg6            ; test dal®°ho znaku

namprg8:                                  ;* pokus o interpretaci jako COMMAND
         mov       bx,ds
         dec       bx
         mov       ds,bx                    ; popisovaá bloku
         cmp       bx,ds:[1]                ; je blok nad vlastn°kem ?
         jbe       namprg2                  ; blok je nad vlastn°kem
         push      cs
         pop       ds                       ; DS <- CS
         lea       bx,[txtcomm]             ; text COMMAND

namprg7: mov       si,bx                    ; adresa jmÇna programu
         jmp       short namprg1            ; zobrazen° jmÇna
                                          ;* zobrazen° jmÇna pro DOS 4.xx
namprg3: mov       si,8                     ; adresa jmÇna programu
         mov       cx,8                     ; dÇlka jmÇna programu
namprg1: lodsb                              ; naáten° znaku jmÇna
         or        al,al                    ; konec jmÇna ?
         jz        namprg2                  ; konec jmÇna
         cmp       al,"."                   ; je konec jmÇna ?
         je        namprg2                  ; je konec jmÇna
         call      outchh                   ; zobrazen° znaku jmÇna
         loop      namprg1                  ; dal®° znak jmÇna
         clc
namprg2: pop       ds
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                      Operace s alokaán°mi bloky pamàti
; -----------------------------------------------------------------------------
public   testprog
testprog:                                 ;* test, zda je blok programem
                                            ; VSTUP: AX=adresa alok. bloku
                                            ; VùSTUP: CY=nen° to program
                                            ;         BX=segment prost©ed°-1
         push      ax
         push      ds
         mov       ds,ax
         cmp       byte ptr ds:[0],"M"      ; je vnit©n° blok ?
         je        testpr1                  ; je vnit©n° blok
         cmp       byte ptr ds:[0],"Z"      ; je posledn° blok ?
         stc
         jne       testpr2                  ; nen° to vñbec alokaán° blok
testpr1: inc       ax
         cmp       ax,ds:[1]                ; vlastn° s†m sebe ?
         stc
         jne       testpr2                  ; nen° to program
         mov       bx,ds:[3ch]              ; adresa segmentu prost©ed°
         dec       bx
         clc
testpr2: pop       ds
         pop       ax
         ret

; -----------------------------------------------------------------------------
; Test, zda je blok AX volnò (nebo je to tento program) -> CY=nen° volnò

TestFre  PROC      NEAR

         push      ax
         push      bx
         push      ds

         mov       ds,ax
         mov       ax,ds:[1]                ; vlastn°k
         mov       bx,cs
         cmp       ax,bx                    ; je to tento program ?
         je        TestFre2                 ; je to tento program

         or        ax,ax                    ; je to volnò blok
         jz        TestFre2                 ; je to volnò blok
         stc                                ; p©°znak, ëe nen° volnò

TestFre2:pop       ds
         pop       bx
         pop       ax
         ret

TestFre  ENDP

; -----------------------------------------------------------------------------
public   srcfrst
srcfrst:                                  ;* nalezen° prvn°ho alokaán°ho bloku
                                            ; VùSTUP: AX=adresa prvn°ho bloku
         push      cx

         push      es
         push      bx
         mov       ah,52h
         int       21h
         mov       ax,es:[bx-2]             ; adresa prvn°ho alokaán°ho bloku
         pop       bx
         pop       es

         call      Testblk
         jnc       srcfrst2

         mov       cx,cs                    ; poáet segmentñ pamàti
         mov       ax,50h                   ; poá†teán° segment k hled†n°
srcfrst1:inc       ax                       ; zvò®en° adresy segmentu
         call      testblk                  ; test, zda je alokaán° blok
         jnc       srcfrst2                 ; nalezen prvn° alokaán° blok
         loop      srcfrst1                 ; test dal®°ho bloku
srcfrst2:pop       cx
         ret
; -----------------------------------------------------------------------------
public   testblk
testblk:                                  ;* test, zda je alokaán° blok
                                            ; VSTUP: AX=adresa alok. bloku
                                            ; VùSTUP: CY=nen° alok. blok
         push      bx
         push      ds
         push      ax
testblk1:mov       ds,ax                    ; alokaán° blok
         cmp       byte ptr ds:[0],"M"      ; je vnit©n° alok. blok ?
         je        testblk3                 ; je vnit©n° blok pamàti - OK
         cmp       byte ptr ds:[0],"Z"      ; je posledn° blok pamàti ?
         je        testblk2
         stc
         jmp       short testblk2           ; CY=nen° alokaán° blok

testblk3:call      srcnxt                   ; nastaven° na dal®° alok. blok
         jnc       testblk1                 ; operace OK - dal®° blok

testblk2:pop       ax
         pop       ds
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   srcnxt
srcnxt:                                   ;* nastaven° na dal®° alokaán° blok
                                            ; VSTUP: AX=segment bloku
                                            ; VùSTUP: AX=segment dal®°ho bloku
                                            ;         CY=nen° dal®° alok. blok
         push      bx
         push      ds
         mov       ds,ax                    ; segment alokaán°ho bloku
         add       ax,ds:[3]                ; zvò®en° o velikost alok. bloku
         jc        srcnxt2                  ; p©eteáen°
         add       ax,1                     ; p©iáten° z†hlav° bloku
srcnxt2: pop       ds
         pop       bx
         ret
; -----------------------------------------------------------------------------
;                               ZnakovÇ vòstupy
; -----------------------------------------------------------------------------
public   outcr
outcr:                                    ;* od©†dkov†n°
         push      ax
         mov       al,13
         call      outchx
         mov       al,10
         call      outchx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   deknms
deknms:                                   ;* zobrazen° á°sla segmentu
                                            ; VSTUP: AX=segment
         push      ax
         push      bx
         push      cx
         push      dx
         xor       dh,dh
         mov       dl,ah
         mov       cl,4
         shr       dx,cl
         shl       ax,cl
         call      deknum
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   deknum,deknum1,deknum0
deknum:                                   ;* zobrazen° dekadickÇho á°sla
                                            ; VSTUP: DX:AX=á°slo k p©ek¢dov†n°

         mov       bl,0fh                   ; vy®®° slovo á°sla 1000 000
         mov       cx,4240h                 ; nië®° slovo á°sla 1000 000
         call      deknum0                  ; dek¢dov†n° 1 á°slice
         mov       bl,1                     ; vy®®° slovo á°sla 100 000
         mov       cx,86a0h                 ; nië®° slovo á°sla 100 000
         call      deknum0                  ; dek¢dov†n° 1 á°slice
         mov       cx,10000                 ; nië®° slovo á°sla 10 000
         call      deknum1                  ; dek¢dov†n° 1 á°slice
         mov       cx,1000                  ; nië®° slovo á°sla 1 000
         call      deknum1                  ; dek¢dov†n° 1 á°slice
         mov       cx,100                   ; nië®° slovo á°sla 100
         call      deknum1                  ; dek¢dov†n° 1 á°slice
         mov       cx,10                    ; nië®° slovo á°sla 10
         call      deknum1                  ; dek¢dov†n° 1 á°slice
         add       al,"0"                   ; korekce na á°slici
         call      outchx                   ; zobrazen° á°slice
         mov       byte ptr cs:[citdek],0   ; vynulov†n° á°taáe á°slice
         ret

deknum1: xor       bl,bl                    ; BL <- 0
deknum0: xor       bh,bh                    ; BH <- 0
         mov       byte ptr cs:[citnum],2fh ; inicializace á°taáe á°slice
deknm1:  inc       byte ptr cs:[citnum]     ; zvò®en° á°taáe á°slice
         sub       ax,cx                    ; odeáten° nië®°ho slova á°sla
         sbb       dx,bx                    ; odeáten° vy®®°ho slova á°sla
         jnc       deknm1                   ; nen° je®tà p©eteáen°
         add       ax,cx                    ; n†vrat nië®°ho slova á°sla
         adc       dx,bx                    ; n†vrat vy®®°ho slova á°sla
         cmp       byte ptr cs:[citnum],"0" ; je á°slice 0 ?
         jne       deknm2                   ; nen° á°slice 0 - dek¢dov†n°
         cmp       byte ptr cs:[citdek],0   ; byla jië nàjak† á°slice ?
         jne       deknm2                   ; byla jië nàjak† á°slice
         mov       byte ptr cs:[citnum]," " ; n†hradn° znak mezery
         jmp       short deknm21
deknm2:  inc       byte ptr cs:[citdek]     ; zvò®en° á°taáe á°slic
deknm21: push      ax                       ; £schova AX
         mov       al,cs:[citnum]           ; dek¢dovan† á°slice
         call      outchx                   ; zobrazen° á°slice
         pop       ax                       ; n†vrat AX
deknm3:  ret
; -----------------------------------------------------------------------------
public   outtab
outtab:                                   ;* nastaven° na znaáku tabel†toru
                                            ; VSTUP: CL=poáet pozic pro tabel†tor
         push      ax
         push      cx
         mov       al,cs:[poztab]           ; star† pozice tabel†toru
         add       al,cl                    ; nov† pozice tabel†toru
         mov       cs:[poztab],al           ; nastaven° novÇ pozice tabel†toru
         sub       al,cs:[pozice]           ; poáet pozic pro tabelaci
         jbe       outtab2                  ; p©ekro®en° pozice tabel†toru
         mov       cl,al                    ; poáet pozic
         xor       ch,ch
outtab1: mov       al," "
         call      outchx                   ; zobrazen° mezery
         loop      outtab1                  ; dal®° mezera
outtab2: pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   hexwrd,hexbyte,hexchr

hexdwrd:                                  ;* zobrazen° dvojslova DX:AX
         push      ax
         mov       ax,dx
         call      hexwrd                   ; zobrazen° vy®®°ho slova
         mov       al,":"                   ; oddàlovaá slov
         call      outch                    ; zobrazen° oddàlovaáe slov
         pop       ax

hexwrd:                                   ;* zobrazen° slova HEX
         push      ax
         mov       al,ah                    ; vy®®° bajt slova
         call      hexbyte                  ; zobrazen° vy®®°ho bajtu slova
         pop       ax
;         call      hexbyte                  ; zobrazen° nië®°ho bajtu slova
;         mov       al,"h"
;         call      outchx
;         ret
;
hexbyte:                                  ;* zobrazen° bajtu HEX
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      hexchr                   ; zobrazen° vy®®° tetr†dy bajtu HEX
         pop       ax
hexchr:                                   ;* zobrazen° tetr†dy bajtu
         push      ax
         and       al,0fh                   ; nië®° tetr†da bajtu
         cmp       al,10                    ; je znak HEX ?
         jb        hexchr2                  ; je á°slice
         add       al,7                     ; korekce na znak HEX
hexchr2: add       al,"0"                   ; korekce na znak ASCII
         call      outchx                   ; zobrazen° znaku
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outtxtz
outtxtz:                                  ;* zobrazen° textu
                                            ; VSTUP: BX=adresa textu
         push      bx
         push      ax
outtx0:  mov       al,cs:[bx]
         inc       bx
         or        al,al
         jz        outtx1
         call      outchx                   ; zobrazen° znaku
         jmp       short outtx0
outtx1:  pop       ax
         pop       bx
         ret
; -----------------------------------------------------------------------------
public   outchh

outchh:                                   ;* zobrazen° velkÇho znaku
                                            ; VSTUP: AL=znak
         push      ax
         cmp       al,"a"
         jb        outchh1
         cmp       al,"z"
         ja        outchh1
         sub       al,32
outchh1: cmp       al," "
         jae       outchh2
         mov       al," "
outchh2: call      outchx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   outchx
outchx:                                   ;* zobrazen° znaku
                                            ; VSTUP: AL=znak
         push      ax
         push      dx
         cmp       al,10
         je        outch3                   ; je znak <LF>
         cmp       al,13
         jne       outch1
         mov       byte ptr cs:[pozice],0   ; vynulov†n° pozice znaku
         mov       byte ptr cs:[poztab],0   ; vynulov†n° pozice tabel†toru
         jmp       short outch3
outch1:  cmp       al,32
         jae       outch2
         mov       al," "
outch2:  inc       byte ptr cs:[pozice]     ; zvò®en° pozice na ©†dku
outch3:  mov       dl,al
         mov       ah,2
         int       21h                      ; zobrazen° znaku
         pop       dx
         pop       ax
         ret

;------------------------------------------------------------------------------
;                        Zobrazen° vektorñ p©eru®en°
;------------------------------------------------------------------------------
intlist:
                                         ;* zobrazen° nadpisu
         mov       si,offset nadpint        ; nadpis vòpisu vektorñ
         call      outtxt                   ; zobrazen° nadpisu

         xor       ax,ax
         mov       es,ax                    ; str†nka 0 pamàti
         xor       di,di                    ; ukazatel átec° adresy
         mov       cx,256                   ; poáet p©eru®en° k zobrazen°
list1:   mov       al,0
         sub       al,cl                    ; á°slo p©eru®en°
         call      hexbyte                  ; zobrazen° á°sla p©eru®en°
         mov       al,"="
         call      outch                    ; oddàlovac° znak
         mov       ax,es:[di]               ; nië®° slovo adresy
         mov       dx,es:[di+2]             ; vy®®° slovo adresy
         call      hexdwrd                  ; zobrazen° obsahu na adres†ch

         dec       cx
         test      cx,3
         jnz       list3
         call      outcr                    ; od©†dkov†n°
         jmp       short list4
list3:   call      outspc                   ; oddàlovac° mezera
         call      outspc                   ; oddàlovac° mezera
list4:   add       di,4                     ; zvò®en° ukazatele v pamàti
         or        cx,cx
         jnz       list1                    ; zobrazen° dal®°ho p©eru®en°
         ret

; -----------------------------------------------------------------------------
public   cmoslist
cmoslist:                                 ;* zobrazen° obsahu pamàti CMOS

         xor       ax,ax
         call      readcmos                 ; kontrola instalace CMOS
         jnc       cmoslst0                 ; CMOS naistalov†na OK

         mov       si,offset txterrc
         call      outtxt
         ret

cmoslst0:mov       si,offset nadpcmos       ; nadpis
         call      outtxt

         xor       ah,ah                    ; poá†teán° adresa CMOS
cmoslst1:                                 ;* zobrazen° adresy
         push      ax
         mov       al,ah                    ; adresa bajtu
         call      outbyte                  ; zobrazen° bajtu
         mov       al,"="
         call      outch
         pop       ax

         call      rcmos                    ; áten° obsahu z CMOS
         call      outbyte

         inc       ah                       ; zvò®en°
         test      ah,7
         jnz       cmoslst4

         call      outcr
         jmp       short cmoslst5
cmoslst4:
         call      outspc
cmoslst5:
         cmp       ah,80h
         jb        cmoslst1

         mov       si,offset txtchsc
         call      outtxt

         call      chscmos                  ; je spr†vnò kontroln° souáet ?
         pushf
         mov       ax,dx                    ; vypoátenò kontroln° souáet
         call      outwordh                 ; zobrazen° kontroln°ho souátu
         popf
         mov       si,offset txtchsc1       ; text OK
         jc        cmoslst6
         je        cmoslst7
cmoslst6:mov       si,offset txtchsc2       ; text chyby
cmoslst7:call      outtxt
         ret
; -----------------------------------------------------------------------------
public   winlist
winlist:                                  ;* zavadàá pevnÇho disku DL

                                          ;* kontrola á°sla disku
         push      dx                       ; £schova á°sla disku
         mov       ah,8
         int       13h                      ; poskytnut° poátu diskñ
         mov       al,dl                    ; poáet pevnòch diskñ
         pop       dx                       ; n†vrat á°sla disku
         or        al,80h
         cmp       al,dl                    ; je neplatnò disk ?
         ja        winlist1                 ; platnÇ á°slo disku
winlist0:ret                                ; je neplatnÇ á°slo disku
                                          ;* naáten° sektoru do pamàti
winlist1:mov       cx,11                    ; poáet pokusñ o áten°
winlist2:dec       cx
         jcxz      winlist0                 ; sektor nelze naá°st
         push      dx                       ; £schova á°sla disku
         push      cx
         mov       ax,201h                  ; 1 sektor ke áten°
         mov       cx,1                     ; v†lec 0, sektor 1
         xor       dh,dh                    ; hlava 0
         push      cs
         pop       es
         mov       bx,offset diskbuf        ; diskovò buffer
         int       13h                      ; naáten° sektoru do pamàti
         pop       cx
         pop       dx
         jc        winlist2                 ; dal®° pokus o áten° sektoru
;         dec       al                       ; je naáten 1 sektor ?
;         jnz       winlist2                 ; nen° naáten 1 sektor - znovu
                                          ;* zobrazen° sektoru
         and       dl,1                     ; ponech† á°slo disku
         add       dl,"0"                   ; korekce na á°slici ASCII
         mov       ds:[txthd2],dl           ; uloëen° á°sla disku
         mov       si,offset txthd1
         call      outtxt                   ; zobrazen° nadpisu

winsekt:                                  ;* zobrazen° sektoru disku

         mov       cx,32                    ; poáet ©†dkñ k zobrazen°
         mov       si,offset diskbuf        ; buffer se sektorem
winlist3:push      cx                     ;* zobrazen° adresy ©†dku
         mov       ax,si                    ; adresa v bufferu
         sub       ax,offset diskbuf        ; offset v bufferu
         call      outword                  ; zobrazen° slova HEX
         mov       al,":"
         call      outch                    ; oddàlovaá
         call      outspc
                                          ;* zobrazen° á†sti HEX
         push      si
         mov       cx,16
winlist4:lodsb
         call      outbyte                  ; zobrazen° bajtu HEX
         call      outspc
         dec       cx
         jz        winlist7                 ; byl posledn° bajt
         cmp       cx,8                     ; je polovina ?
         jne       winlist5                 ; nen° polovina
         mov       al,"-"
         call      outch
winlist5:test      cx,3
         jne       winlist6
         call      outspc
winlist6:jmp       short winlist4           ; dal®° bajt
winlist7:pop       si
                                          ;* zobrazen° á†sti ASCII
         mov       al,'"'
         call      outch
         mov       cx,16
winlist8:lodsb
         cmp       al,7fh
         je        winlistb
         cmp       al," "
         jae       winlist9
winlistb:mov       al,"."
winlist9:call      outch
         loop      winlist8
         mov       al,'"'
         call      outch

         pop       cx
         call      outcr
         loop      winlist3                 ; dal®° ©†dek

winlista:ret
; -----------------------------------------------------------------------------
public   bootlist
bootlist:                                 ;* zobrazen° zavadàáe disku

         mov       cx,5                     ; poáet pokusñ o naáten° sektoru
bootlst2:dec       cx
         jz        bootlst5                 ; pokus se nepovedl
         push      cx
         push      dx
         mov       al,dl                    ; á°slo disku
         push      cs
         pop       ds
         mov       bx,offset diskbuf        ; diskovò buffer
         mov       cx,1                     ; poáet sektorñ = 1
         xor       dx,dx                    ; poá†teán° sektor = 0
         int       25h                      ; áten° sektoru z disku
         inc       sp
         inc       sp                       ; zru®en° registru p©°znakñ v z†sob.
         pop       dx
         pop       cx
         jc        bootlst2                 ; chyba - dal®° pokus o áten°

bootlst4:                                 ;* zobrazen° nadpisu
         add       dl,"A"                   ; korekce na znak ASCII
         mov       ds:[txtboot2],dl         ; uloëen° oznaáen° disku
         mov       si,offset txtboot1
         call      outtxt                   ; zobrazen° nadpisu

         jmp       winsekt                  ; zobrazen° sektoru

bootlst5:                                 ;* áten° pomoc° paketu
         mov       cx,cs
         mov       cs:[bootpaks],cx         ; segment pro uloëen° dat
         mov       cx,5                     ; poáet pokusñ o naáten° sektoru
bootlst6:dec       cx
         jz        bootlst7                 ; pokus se nepovedl
         push      cx
         push      dx
         mov       al,dl                    ; á°slo disku
         push      cs
         pop       ds
         mov       bx,offset bootpak        ; adresa paketu pro zavadàá
         mov       cx,0ffffh                ; identifikace paketu
         xor       dx,dx                    ; poá†teán° sektor = 0
         int       25h                      ; áten° sektoru z disku
         inc       sp
         inc       sp                       ; zru®en° registru p©°znakñ v z†sob.
         pop       dx
         pop       cx
         jc        bootlst6                 ; chyba - dal®° pokus o áten°
         jmp       short bootlst4           ; zobrazen° sektoru
bootlst7:ret
; -----------------------------------------------------------------------------
;                               ZnakovÇ vòstupy
; -----------------------------------------------------------------------------
public   outspcx

outspcx:                                 ;* zobrazen° oddàlovac°ch mezer
                                            ; VSTUP: AL=poáet mezer
         push      ax
         push      cx
         xor       cx,cx
         mov       cl,al                    ; poáet mezer
         jcxz      outspc2
outspc1: mov       al," "
         call      outch                    ; zobrazen° mezery
         loop      outspc1                  ; dal®° mezera
outspc2: pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        mà©en° frekvence procesoru
; -----------------------------------------------------------------------------
;˛
TstCpu   PROC      NEAR

         mov       al,ds:[Procesor]
         cmp       al,7
         jae       TstCpu1                  ; je vy®®° typ procesoru OK

         ret

; ------ nastaven° dàliáky reproduktoru

TstCpu1: cli
         in        al,[61h]
         and       al,not 3
         mov       bl,al                    ; £schova stavu portu
         out       [61h],al                 ; vypnut° vòstupu na reproduktor
         mov       al,0b4h
         out       [43h],al                 ; povel pro nastaven° frekvence
         mov       al,0
         out       [42h],al                 ; dàlic° konstanta LOW
         jmp       $+2
         out       [42h],al                 ; dàlic° konstanta HIGH
         sti

; ------ p©°prava k mà©en° frekvence procesoru

         mov       di,8000h                 ; pomocn† konstanta
         mov       cx,10                    ; poáet prñchodñ smyákou
         cmp       byte ptr ds:[Procesor],8 ; 80386 a vò®e
         jae       TstCpu2
         mov       cl,1                     ; jinak 1 prñchod

; ------ start mà©en° rychlosti

TstCpu2: mov       ah,0
         mov       al,bl                    ; stav portu 61h
         or        al,1                     ; hradlo á°taáe zapnuto
         cli                                ; mus° bòt z†kaz p©eru®en°
         EVEN                               ; zarovn†n° na sudou adresu
         out       [61h],al                 ; zapnut° á°taáe
         mov       al,0

; ------ proveden° poëadovanÇho mnoëstv° instrukc° MUL

TstCpu3: rept      1000                     ; 1 smyáka celkem asi 1200000 taktñ
         mul       di                       ; 1 instrukce asi 10 aë 120 taktñ
         endm
         dec       cx
         jz        TstCpu4                  ; 10 smyáek -> 100000 aë 1200000 taktñ
         jmp       TstCpu3

; ------ vypnut° á°taáe reproduktoru

TstCpu4: mov       al,bl                    ; pñvodn° stav portu
         out       [61h],al                 ; vypnut° reproduktoru

; ------ áten° dosaëenÇho stavu á°taáe

         in        al,[42h]                 ; konstanta LOW
         mov       ah,al                    ; £schova konstanty LOW
         in        al,[42h]                 ; konstanta HIGH
         xchg      al,ah                    ; oprava po©ad° bajtñ
         neg       ax                       ; ubàhlò poáet taktñ hodin

; ------ n†vrat nastaven° á°taáe

         push      ax
         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n°ë®° bajt
         out       [42h],al                 ; konstanta - vy®®° bajt
         pop       ax

         sti                                ; p©eru®en° opàt povoleno

                                            ; celkem doba asi 0.1 aë 50 ms
; frekvence 1193182 Hz (0.8381 us na impuls)
; - tj. asi 2000 aë 60000 impulsñ
; vòpoáet zhruba  f[MHz]= 1200000 / (impulsu_hodin * 0.8381us)
;                             ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒŸ
;                                   doba mereni v [us]
;
;    f[MHz*10] = 1 430 000 / impulsu_hodin

         cmp       ax,100
         jb        TstCpu9

         xor       bx,bx
         mov       bl,ds:[procesor]         ; procesor
         shl       bx,1
         shl       bx,1
         mov       cx,ds:[hodproc2+bx]      ; dàlic° konstanta pro hodiny
         mov       dx,ds:[hodProc2+bx+2]

         test      word ptr ds:[prepinac],8000h ; je cejchov†n° hodin ?
         jnz       TstCpu8                  ; je cejchov†n° hodin

         xchg      ax,cx

         cmp       dx,cx
         jae       TstCpu9

         div       cx                       ; p©epoáet na kmitoáet

         mov       ds:[Hodiny],ax

         xor       ax,ax
         div       cx
         mov       cx,100
         mul       cx
         add       ax,7f60h
         adc       dx,0
         cmp       dl,100
         jb        TstCpu7
         sub       dl,100
         inc       word ptr ds:[Hodiny]
TstCpu7: mov       ds:[hodinyd],dl
         ret

TstCpu8: mov       ds:[hodiny],ax           ; hodiny procesoru
         mov       ds:[hodinyd],dl          ; vy®®° slovo hodin

TstCpu9:
         ret

TstCpu   ENDP


; -----------------------------------------------------------------------------
;                              D A T A
; -----------------------------------------------------------------------------
identclk db        'TESTCLK'                ; identifikace testu hodin

prepinac dw        1                      ;* p©ep°naáe
                                            ;   bit 0: v®eobecnÇ informace "/S"
                                            ;   bit 1: obsah pamàti DOS "/M"
                                            ;   bit 2: vektory p©eru®en° "/I"
                                            ;   bit 3: obsah pamàti CMOS "/C"
                                            ;   bit 4: zavadàá winchesterñ "/W"
                                            ;   bit 5: zavadàá disku "/B"

                                            ;   bit 15: cejchov†n° hodin "/$"

bootdisk db        0                        ; disk k zobrazen° zavadàáe

texthlp  db        'Volby: /S  - vseobecne informace',13,10
         db        '       /M  - obsah pameti DOS',13,10
         db        '       /I  - vektory preruseni',13,10
         db        '       /C  - obsah pameti CMOS',13,10
         db        '       /W  - hlavni zavadec pevneho disku',13,10
         db        '       /Bx - zavadec disku; x=A,B...',13,10
         db        0

nadpis   db        'Systemove informace V1.31; (c) Miroslav Nemecek',13,10
         db        '-----------------------------------------------',0

txttyp   db        '       Typ pocitace:',0
txtdos   db        '    Operacni system:',0
txtbios  db        '  Datum vzniku BIOS:',0
txtproc  db        '    Hlavni procesor:',0
txtkopr  db        'Matemat. koprocesor:',0
txthod   db        '   Hodiny procesoru:',0
txtmem   db        '  Celkova pamet RAM:',0
txtrom   db        '         Moduly ROM:',0
txtserp  db        '      Seriove porty:',0
txtparp  db        '    Paralelni porty:',0
txtcard  db        '     Graficka karta:',0
txtdisk  db        'Disketove mechaniky:',0
txtwin   db        '        Pevne disky:',0
txtlogd  db        '      Logicke disky:',0

zaver    db        0

tabtyp   label     byte                   ;* tabulka typñ poá°taáñ
         db        'PC',0                   ; 0 (0ffh)
         db        'PC XT',0                ; 1 (0feh)
         db        'PCjr',0                 ; 2 (0fdh)
         db        'AT',0                   ; 3 (0fc00h, 0fc01h)
         db        'XT-286',0               ; 4 (0fc02h)
         db        'XT',0                   ; 5 (0fbh)
         db        'konvertabilni PC',0     ; 6 (0f9h)
         db        'neznamy typ',0          ; 7 nezn†mò typ

tabdos   label     byte                   ;* tabulka operaán°ch systÇmñ
         db        'DOS',0                  ; 0

tabmes   label     byte                   ;* tabulka màs°cñ v roce
         db        0                        ; 0
         db        'ledna',0                ; 1
         db        'unora',0                ; 2
         db        'brezna',0               ; 3
         db        'dubna',0                ; 4
         db        'kvetna',0               ; 5
         db        'cervna',0               ; 6
         db        'cervence',0             ; 7
         db        'srpna',0                ; 8
         db        'zari',0                 ; 9
         db        'rijna',0                ; 10
         db        'listopadu',0            ; 11
         db        'prosince',0             ; 12

tabproc  label     byte                   ;* tabulka procesorñ
         db        '????',0                 ; 0
         db        'Intel 8088',0           ; 1
         db        'Intel 8086',0           ; 2
         db        'NEC V20',0              ; 3
         db        'NEC V30',0              ; 4
         db        'Intel 80188',0          ; 5
         db        'Intel 80186',0          ; 6
         db        'Intel 80286',0          ; 7
         db        'Intel 80386',0          ; 8
         db        'Intel 80386 SX',0       ; 9
         db        'Intel 80486',0          ; 10
         db        'Intel 80486+',0         ; 11
         db        'Intel PENTIUM',0        ; 12

tabprocm db        ' model ',0

tabkopr  label     byte                   ;* tabulka koprocesorñ
         db        '????',0                 ; 0
         db        'nenainstalovan',0       ; 1
         db        'Intel 8087',0           ; 2
         db        'Intel 80287',0          ; 3
         db        'Intel 80387',0          ; 4
         db        'interni 80486',0        ; 5
         db        'interni Pentium',0      ; 6


tabcard  label     byte                   ;* tabulka grafickòch karet

         db        '????',0                 ; 0
         db        'CGA',0                  ; 1
         db        'MCGA',0                 ; 2
         db        'EGA',0                  ; 3
         db        'EGA64',0                ; 4
         db        'EGA Mono',0             ; 5
         db        'IBM8514',0              ; 6
         db        'Hercules',0             ; 7
         db        'ATT400',0               ; 8
         db        'VGA',0                  ; 9
         db        'PC3270',0               ; 10
         db        'VESA SVGA ',0           ; 11


tabega   label     byte                   ;* tabulka velikost° EGA/VGA
         db        '64 KB',0                ; 0
         db        '128 KB',0               ; 1
         db        '192 KB',0               ; 2
         db        '256 KB a vice',0        ; 3

tabdisk  label     byte                   ;* tabulka disketovòch mechanik
         db        'neznama',0              ; 0
         db        '5.25"/360KB',0          ; 1
         db        '5.25"/1.2MB',0          ; 2
         db        '3.5"/720KB',0           ; 3
         db        '3.5"/1.44MB',0          ; 4
         db        '3.5"/2.88MB',0          ; 5

txtmb    label     byte
txtwin1  db        ' MB',0
txtwin2  db        ' (typ ',0
txtkb    db        ' KB',0
txtmhz   db        ' MHz',0

public   txtnadp
txtnadp  db        13,10,'Segment Vlastnik  Jmeno  Velikost   Typ',13,10
         db        '------------------------------------------',13,10,0
vlsys    db        '--------',0
typvol   db        '--volny--',0
typprog  db        '<PROGRAM>',0
typenv   db        'prostredi',0
typdat   db        'data',0
typsys   db        'system',0
txtcelk  db        'Celkova pamet: ',0
txtvoln  db        'Volna pamet  : ',0
txtspoj  db        'Volna spojita: ',0
txtcomm  db        'COMMAND',0
txtumb   db        '  =================[ UMB ]================',13,10,0

public   nadpint
nadpint  db        13,10,'            Adresy vektoru preruseni',13,10
         db        '------------------------------------------------------'
         db        13,10,0

public   nadpcmos
nadpcmos db        13,10,'             Obsah pameti CMOS',13,10
         db        '-----------------------------------------------',13,10,0

public   txterrc
txterrc  db        13,10,'Pamet CMOS neni nainstalovana !',13,10,0

public   txtchsc
txtchsc  db        '   Kontrolni soucet pameti CMOS: ',0
txtchsc1 db        ' (OK)',13,10,0
txtchsc2 db        ' (Chyba !)',13,10,0

txthd1   db        13,10,'                  Hlavni zavadeci sektor pevneho disku '
txthd2   db        '0',13,10
         db        '-----------------------------------------------'
         db        '-----------------------------',13,10,0

txtboot1 db        13,10,'                     Zavadeci sektor logickeho disku '
txtboot2 db        'A',13,10
         db        '-----------------------------------------------'
         db        '-----------------------------',13,10,0

bootpak  dd        0                        ; á°slo poá†teán°ho sektoru
         dw        1                        ; poáet sektorñ
         dw        offset diskbuf           ; adresa bufferu
bootpaks dw        0                        ; segment adresy bufferu

citnum   db        0                        ; á°taá á°slice
citdek   db        0                        ; á°taá zobrazenòch á°slic
pozice   db        0                        ; á°taá pozice na ©†dku
poztab   db        0                        ; pozice tabel†toru

         db        23 DUP(0)


smodel   db        0ffh                     ; typ poá°taáe - systÇmovò model
submodel db        0                        ; typ podmodelu poá°taáe

verze    dw        0                        ; verze a podverze oper. systÇmu

biosden  db        1                        ; den vzniku BIOS
biosmes  db        1                        ; mesic vzniku BIOS
biosrok  dw        1980                     ; rok vzniku BIOS

procesor db        0                      ;* hlavn° procesor
                                            ;   0=nezn†mò
                                            ;   1=Intel 8088
                                            ;   2=Intel 8086
                                            ;   3=NEC V20
                                            ;   4=NEC V30
                                            ;   5=Intel 80188
                                            ;   6=Intel 80186
                                            ;   7=Intel 80286
                                            ;   8=Intel 80386
                                            ;   9=Intel 80386 SX
                                            ;  10=Intel 80486
                                            ;  11=Intel 80486+
                                            ;  12=Intel PENTIUM

modelcpu dw        0                        ; model CPU (0=nen° zn†m)

vendrcpu db        13 dup(0)                ; Vendor ©etàzec CPU

koproc   db        0                      ;* koprocesor
                                            ;   0=nezn†mò
                                            ;   1=ë†dnò
                                            ;   2=8087
                                            ;   3=80287
                                            ;   4=80387
                                            ;   5=intern° 80486
                                            ;   6=intern° Pentium

hodproc  label     word                   ;* tabulka konstant pro hodiny
         dw        675      ;?              ;   0=nezn†mò
         dw        600      ;?              ;   1=Intel 8088
         dw        675                      ;   2=Intel 8086
         dw        700      ;?              ;   3=NEC V20
         dw        900      ;?              ;   4=NEC V30
         dw        800      ;?              ;   5=Intel 80188
         dw        900      ;?              ;   6=Intel 80186
         dw        1533 ;1551               ;   7=80286
         dw        3000     ;?              ;   8=80386
         dw        1817                     ;   9=80386 SX
         dw        6097 ;(7119)             ;  10=80486
         dw        6097                     ;  11=80486+
         dw        13572                    ;  12=Pentium

hodproc2 label     word                   ;* tabulka konstant pro hodiny 2
         dd        10000                    ;   0=nezn†mò
         dd        10000                    ;   1=Intel 8088
         dd        10000                    ;   2=Intel 8086
         dd        11000                    ;   3=NEC V20
         dd        13000                    ;   4=NEC V30
         dd        13000                    ;   5=Intel 80188
         dd        13000                    ;   6=Intel 80186
         dd        25254                    ;   7=80286
         dd        298890                   ;   8=80386
         dd        298700                   ;   9=80386 SX
         dd        310374                   ;  10=80486
         dd        71800                    ;  11=80486+
         dd        131940                   ;  12=Pentium

VideoCard db        0                     ;* grafick† karta
                                            ;     0=dosud nedetekov†no
                                            ;     1=CGA
                                            ;     2=MCGA
                                            ;     3=EGA
                                            ;     4=EGA 64kB
                                            ;     5=EGA Mono
                                            ;    (6=IBM8514)
                                            ;     7=Hercules
                                            ;    (8=ATT400)
                                            ;     9=VGA
                                            ;    10=PC3270
                                            ;    11=VESA SVGA

VesaMEM  dw        0                        ; pamàü VESA (v KB)

disket   db        0                      ;* poáet disket. mechanik
disket1  db        0                      ;* typ mechaniky 1
disket2  db        0                      ;* typ mechaniky 2
disket3  db        0                      ;* typ mechaniky 3
disket4  db        0                      ;* typ mechaniky 4
                                            ;   0=???
                                            ;   1=5.25"/360 KB
                                            ;   2=5.25"/1.2 MB
                                            ;   3=5.25"/720 KB
                                            ;   4=3.5"/1.44 MB
                                            ;   5=3.5"/2.88 B

winchs0  dw        0                        ; velikost disku 0 v MB
wincht0  db        0                        ; typ pevnÇho disku 0
winchs1  dw        0                        ; velikost disku 1 v MB
wincht1  db        0                        ; typ pevnÇho disku 1

memory   dw        0                        ; celkov† pamàü v KB

hodinyd  db        0                        ; desetiny kmitoátu hodin
hodiny   dw        0                        ; hodiny procesoru (v MHz)
hodinyh  dw        0                        ; vy®®° slovo hodin

cit08    dw        0                        ; á°taá pro p©eru®en° INT 08h

diskbuf  label     byte                     ; diskovò buffer

konec    label     byte                     ; konec programu MEMORY

code     ENDS
         END       sysinfo

COMMENT %

 *************************************************************************

                  zav dˆc¡ sektor opera‡n¡ho syst‚mu
                        - disketa 360 KB -
 *************************************************************************

    Zav dˆc¡  sektor  opera‡n¡ho  syst‚mu  je  um¡stˆn  v prvn¡m sektoru na
disketˆ  (hlava  0, v lec 0, sektor 1). P©i startu po‡¡ta‡e jej zavede BIOS
pomoc¡ slu‘by INT 19H od adresy 0:7C00H, na kterou potom p©ed  ©¡zen¡.

    Zav dˆc¡  sektor  syst‚mu  resetuje  disk,  zavede  do pamˆti od adresy
0:0500H  prvn¡ sektor z kladn¡ho adres ©e disku, zkontroluje zda jsou prvn¡
dvˆ  polo‘ky  adres ©e  soubory IO.SYS a MSDOS.SYS. Pokud je v¨e v po© dku,
zavede ze za‡ tku datov‚ho prostoru diskety (tj. ze za‡ tku souboru IO.SYS)
od  adresy  0:0700H prvn¡ t©i sektory a p©ed  ©¡zen¡ na tuto adresu (adresa
0070:0000H). Pokud vznikne p©i nˆkter‚ operaci chyba, ohl s¡ chybu zav dˆn¡
syst‚mu a ‡ek  na stisk libovoln‚ kl vesy.

     %

code     SEGMENT   page
         ASSUME    cs:code,ds:code

         org       7b00h

start:
         push      cs
         pop       ds
         push      cs
         pop       es

         mov       cx,1fbh
         mov       ax,cx
         mov       si,7c00h
suma:    xor       ax,[si]
         ror       ax,1
         inc       si
         loop      suma
         inc       si
         mov       [si],ax

         mov       ax,0301h
         mov       bx,7c00h
         mov       cx,1
         mov       dx,0
         int       13h
         mov       ax,0301h
         int       13h

         mov       ah,4ch
         int       21h


         org       7c00h

startb:  jmp       boot                     ; start zavadˆ‡e syst‚mu


         db        'GOLEM4.0'               ; verze opera‡n¡ho syst‚mu (OEM)

delka    dw        512                      ; d‚lka sektoru (bajt–)
blok     db        2                        ; velikost bloku (sektor–)
rezsekt  dw        1                        ; po‡et rezerv.sektor– p©ed FAT
numfat   db        2                        ; po‡et aloka‡n¡ch tabulek FAT
maxroot  dw        112                      ; max. po‡. pol. z kl. adres ©e
maxsekt  dw        720                      ; celkov˜ po‡et sekt. na m‚diu
typdsk   db        0fdh                     ; typ disku (popisova‡ m‚dia)
sektfat  dw        2                        ; po‡et sektor– v jednom FAT
sektnm   dw        9                        ; po‡et sektor– na stopu
numhlav  dw        2                        ; po‡et hlav disku
hidsekt  dd        0                        ; po‡et skryt˜ch sektor–
maxsekh  dd        0                        ; celk.po‡et sekt.na m‚diu
disk     db        0                        ; ‡¡slo disku
hlava    db        0                        ; ‡¡slo hlavy ke ‡ten¡
ident    db        29h                      ; identifikace
serial   dd        215115d0h                ; s‚riov‚ ‡¡slo diskety
label    db        'NO NAME    '            ; ozna‡en¡ disku

typfat   db        'FAT12   '               ; ozna‡en¡ typu FAT




tabdsk:                                     ; zde se ulo‘¡ tab. disk.param.
                                            ; (p©ekryje ‡ st programu)

COMMENT %

offset, adresa, velikost

 + 0    7c3eh   1     bity 0-3: rychlost krok.; bity 4-7:‡as po ‡ten¡ hlavy
 + 1    7c3fh   1     bit 0:1=pou‘¡t DMA; bity 2-7: ‡as do ‡ten¡ hlavy
 + 2    7c40h   1     ‡ek n¡ motoru p©ed vypnut¡m (v jednotk ch 55 ms)
 + 3    7c41h   1     velikost sektoru (0=128; 1=256; 2=512; 3=1024)
 + 4    7c42h   1     posledn¡ sektor stopy (po‡et sektor–)
 + 5    7c43h   1     d‚lka prodlevy pro ‡tec¡/z pisov‚ operace
 + 6    7c44h   1     max. d‚lka p©enosu dat
 + 7    7c45h   1     d‚lka prodlevy pro form tovac¡ operace
 + 8    7c46h   1     pln¡c¡ znak pro form tov n¡ (norm lnˆ 0F6H = 'ö')
 + 9    7c47h   1     ‡as p©¡tlaku hlavy (v milisekund ch)
 +10    7c48h   1     ‡as pot©ebn˜ k zapnut¡ motoru (v jednotk ch 1/8 sek.)

 +11    7c49h   2     ‡¡ta‡ relat. ‡¡sla sektoru p©i ‡ten¡ (ni‘¨¡ slovo)
 +13    7c4Bh   2     ‡¡ta‡ relat. ‡¡sla sektoru p©i ‡ten¡ (vy¨¨¡ slovo)
 +15    7c4dh   2     ‡¡slo v lce ke ‡ten¡
 +17    7c4fh   1     ‡¡slo sektoru ke ‡ten¡
 +18    7c50h   2     po‡ te‡n¡ sektor z kladn¡ho adres ©e (ni‘¨¡ slovo)
 +20    7c52h   2     po‡ te‡n¡ sektor z kladn¡ho adres ©e (vy¨¨¡ slovo)

        %

boot:                                       ; start programu zavadˆ‡e


         cli                                ; z kaz p©eru¨en¡
         xor       ax,ax                    ; segment = 0000
         mov       ss,ax                    ; nastaven¡ segm. z sobn¡ku 0
         mov       sp,7c00h                 ; ukazatel z sob. pod program
         push      ss                       ; = 00
         pop       es                       ; ES <- 0000 (segment 0)
         push      ss
         pop       ds
         mov       si,offset txtboot        ; text 'BOOT:'
         call      tisktxt                  ; tisk textu 'BOOT :'
         xor       ax,ax
         mov       bx,78h                   ; ukazatel disk. param. INT 13H
         lds       si,ss:[bx]               ; DS:SI <-- tab. disk. param.
         push      ds                       ; segment tab. disk. parametr–
         push      si                       ; offset tabulky disk.parametr–
         push      ss                       ; segment 0000
         push      bx                       ; adr. ukaz. tab. disk. param.
         mov       di,offset tabdsk         ; za‡ tek tabulky parametr–
         mov       cx,11                    ; d‚lka tabulky disk. parametr–
         cld                                ; smˆr p©enosu nahoru
         rep       movsb                    ; na‡ten¡ tab. disk. parametr–
         push      es                       ; segment 0 (DI=7C49H)
         pop       ds                       ; DS <-- 0000
         mov       byte ptr [di-2],0fh      ; 7C47H <-- 0FH ‡as p©¡tlaku
         mov       cx,[sektnm]              ; po‡et sektor– na stopu
         mov       byte ptr [di-7],cl       ; 7C42H <-- posledn¡ sekt.stopy
         mov       word ptr [bx+2],ax       ; adresa tab.disk.par.<--tabdsk
         mov       word ptr [bx],offset tabdsk; nov  adresa tab. disk. par.
         sti                                ; povolen¡ p©eru¨en¡
         int       13h                      ; reset disku (AH=0)
         jc        boote2                   ; chyba zav dˆn¡ syst‚mu
         xor       ax,ax                    ; AX <- 0000
         cmp       [maxsekt],ax             ; celkov˜ po‡et sekt. na m‚diu
         jz        boot1                    ; nen¡ ‘ dn˜ sektor
         mov       cx,[maxsekt]             ; celkov˜ po‡et sekt. na m‚diu
         mov       word ptr [maxsekh],cx    ; celkov˜ po‡et sekt. na m‚diu
boot1:   mov       al,[numfat]              ; po‡et aloka‡n¡ch tabulek FAT
         mul       word ptr [sektfat]       ; po‡et sektor– v jednom FAT
         add       ax,word ptr [hidsekt]    ; po‡et skryt˜ch sektor–-LOW
         adc       dx,word ptr [hidsekt+2]  ; po‡et skryt˜ch sektor–-HIGH
         add       ax,[rezsekt]             ; po‡et rezerv.sektor– p©ed FAT
         adc       dx,0                     ; p©enos do vy¨¨¡ho slova
         mov       word ptr [tabdsk+18],ax  ; po‡ t.sekt.z kl.adres ©e-LOW
         mov       word ptr [tabdsk+20],dx  ; po‡ t.sekt.z kl.adres ©e-HIGH
         mov       word ptr [tabdsk+11],ax  ; po‡ te‡n¡ sektor dat-LOW
         mov       word ptr [tabdsk+13],dx  ; po‡ te‡n¡ sektor dat-HIGH
         mov       ax,32                    ; d‚lka polo‘ky adres. (bajt–)
         mul       word ptr [maxroot]       ; v˜po‡et d‚lky z kl. adres ©e
         mov       bx,[delka]               ; d‚lka sektoru (bajt–)
         add       ax,bx                    ; zaokrouhl. na vy¨¨¡ po‡et s.
         dec       ax                       ; sn¡‘en¡ o posledn¡ polo‘ku
         div       bx                       ; v˜po‡et po‡tu sekt. adres ©e
         add       word ptr [tabdsk+11],ax  ; po‡ te‡n¡ sektor dat-LOW
         adc       word ptr [tabdsk+13],0   ; po‡ te‡n¡ sektor dat-HIGH
         mov       bx,0500h                 ; adresa k zaveden¡ adres ©e
                                            ; kontrola zav dˆc¡ho sektoru
         mov       ax,word ptr [hidsekt]    ; po‡et skryt˜ch sektor–-LOW
         mov       dx,word ptr [hidsekt+2]  ; po‡et skryt˜ch sektor–-HIGH
         call      readset                  ; ‡ten¡ zav dˆc¡ho sektoru
boote2:  jc        booterr                  ; chyba ‡ten¡ souboru
         mov       cx,507                   ; d‚lka sektoru - 5
         mov       ax,cx
         mov       si,bx
chcksm:  xor       ax,[si]
         ror       ax,1
         inc       si
         loop      chcksm
         inc       si
         sub       ax,[si]                  ; kontrola kontroln¡ho sou‡tu
         mov       si,offset txterr         ; chybov‚ hl ¨en¡ 'VADNY'
         je        chcksm2                  ; kontroln¡ sou‡et OK
         jmp       booter1
chcksm2:
         mov       dx,word ptr [tabdsk+20]  ; po‡ t.sekt.z kl.adres ©e-HIGH
         mov       ax,word ptr [tabdsk+18]  ; po‡ t.sekt.z kl.adres ©e-LOW
         call      readset                  ; ‡ten¡ adres ©e od 0:0500H
         jc        booterr                  ; chyba ‡ten¡ adres ©e
         mov       di,bx                    ; 1. polo‘ka adres ©e (sektor)
         mov       cx,11                    ; d‚lka jm‚na souboru IO.SYS
         mov       si,offset soubio         ; jm‚no souboru IO.SYS
         rep       cmpsb                    ; kontrola jm‚na
         jnz       booterr                  ; nen¡ shoda - hl ¨en¡ chyby
         lea       di,[bx+32]               ; DI - 2. polo‘ka v adres ©i
         mov       si,offset soubdos        ; jm‚no souboru MSDOS.SYS
         mov       cx,11                    ; d‚lka jm‚na MSDOS.SYS
         rep       cmpsb                    ; porovn n¡ jm‚na MSDOS.SYS
         jz        readio                   ; shoda-na‡ten¡ zavadˆ‡e IO.SYS
booterr: mov       si,offset txtsys         ; text 'NENI SYSTEM'
booter1: call      tisktxt                  ; tisk chybov‚ho hl ¨en¡
         xor       ah,ah                    ; funkce ‡ten¡ znaku z kl ves.
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         pop       si                       ; adresa ukazat.tab.disk.par.
         pop       ds                       ; segment 0000
         pop       [si]                     ; n vrat p–vodn¡ho ukaz.tab.d.p.
         pop       [si+2]                   ; p–vodn¡ segment ukaz.tab.d.p.
         int       19h                      ; skok do slu‘by zaveden¡ syst.

                                            ; na‡ten¡ zavadˆ‡e IO.SYS
                                            ; ES = segment (=0000)
readio:  mov       bx,0700h                 ; adresa po‡ tku bufferu
         mov       cx,3                     ; po‡et sektor– k na‡ten¡ = 3
         mov       ax,word ptr [tabdsk+11]  ; rel. ‡¡slo sektoru - LOW
         mov       dx,word ptr [tabdsk+13]  ; rel. ‡¡slo sektoru - HIGH
nxtsekt: push      ax                       ; ‡¡slo sektoru - LOW
         push      dx                       ; ‡¡slo sektoru - HIGH
         push      cx                       ; po‡et sektor–
         call      readset                  ; na‡ten¡ 1 sektoru do pamˆti
         pop       cx                       ; po‡et sektor–
         pop       dx                       ; ‡¡slo sektoru
         pop       ax                       ; ‡¡slo stopy
         jc        booterr                  ; chybov‚ hl ¨en¡
         add       ax,1                     ; zv˜¨en¡ ukaz. stopy (LOW)
         adc       dx,0                     ; zv˜¨en¡ ukaz. stopy (HIGH)
         add       bx,[delka]               ; zv˜¨en¡ ukl dac¡ adr.o sektor
         loop      nxtsekt                  ; dal¨¡ sektor ke ‡ten¡
         push      si
         mov       si,offset txtok
         call      tisktxt
         pop       si
         mov       ch,[typdsk]              ; typ disku (popisova‡ m‚dia)
         mov       dl,[disk]                ; ‡¡slo disku
         mov       bx,word ptr [tabdsk+11]  ; rel. ‡¡slo n sled. sektoru
         mov       ax,word ptr [tabdsk+13]  ;    -  "  -  (ni‘¨¡ slovo)
         db        0eah,0,0,70h,0           ; instrukce JMP FAR 0070:0000h
;        jmp        far 0070:0000h          ; start modulu IO.SYS

                                            ; tisk textu na adrese DS:SI
tisktxt: lodsb                              ; p©e‡ten¡ znaku k tisku
         or        al,al                    ; byl koncov˜ znak ?
         jz        bootret                  ; konec tisku textu
         mov       ah,0eh                   ; funkce tisku znaku v TTY m¢du
         mov       bx,0007h                 ; = b¡l‚ p¡smo, str nka 0
         int       10h                      ; tisk znaku v AL
         jmp       short tisktxt            ; dal¨¡ znak k tisku


                                            ; na‡ten¡ 1 sektoru s nastaven¡m
                                            ; vstup:AX = rel.sektor (LOW)
                                            ;       DX = rel.sektor (HIGH)
readset:
         cmp       dx,[sektnm]              ; po‡et sektor– na stopu
         jc        setpar2                  ; nen¡ chyba p©ete‡en¡
         stc                                ; p©¡znak chyby p©ete‡en¡
bootret: ret                                ; n vrat p©i chybˆ
setpar2: div       word ptr [sektnm]        ; po‡et sektor– na stopu
         inc       dl                       ; ‡¡slo sektoru ke ‡ten¡
         mov       byte ptr [tabdsk+17],dl  ; ‡¡slo sektoru ke ‡ten¡
         xor       dx,dx
         div       word ptr [numhlav]       ; dˆleno po‡tem hlav disku
         mov       [hlava],dl               ; ‡¡slo hlavy ke ‡ten¡
         mov       word ptr [tabdsk+15],ax  ; ‡¡slo v lce ke ‡ten¡

                                            ; na‡ten¡ 1 sektoru do pamˆti
         mov       dx,ax                    ; ‡¡slo v lce ke ‡ten¡
         mov       ax,0201h                 ; funkce ‡ten¡ sekt. do pamˆti
         mov       cl,6                     ; po‡et rotac¡
         shl       dh,cl                    ; vyn soben¡ * 64 (bity 9,8)
         or        dh,byte ptr [tabdsk+17]  ; ‡ten˜ sekt.OR bity 9,8 stopy
         mov       cx,dx                    ; CL = ‡.v lce; CH = ‡.sektoru
         xchg      ch,cl                    ; CH = ‡.v lce; CL = ‡.sektoru
         mov       dl,[disk]                ; ‡¡slo disku
         mov       dh,[hlava]               ; ‡¡slo hlavy ke ‡ten¡
         int       13h                      ; ‡ten¡ sektor– do pamˆti
         ret

txtboot  db        13,10,'#Boot: ',0
txtok    db        'OK',13,0
txterr   db        'ZAVADEC JE NARUSENY !',0
txtsys   db        'NENI SYSTEM !',0

soubio   db        'IO      SYS'
soubdos  db        'MSDOS   SYS'

summ     dw        0                        ; kontroln¡ sou‡et
         dw        0aa55h                   ; identifika‡n¡ slovo sektoru

         code      ends
         end       start

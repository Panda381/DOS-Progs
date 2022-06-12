stack    SEGMENT   stack
         dw        64 dup (?)
stack    ENDS

code     SEGMENT   page
         ASSUME    cs:code,ds:code

COMMENT %

 *************************************************************************

                  zav dˆc¡ sektor opera‡n¡ho syst‚mu

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
         org       7c00H

start:   jmp       short boot               ; start zavadˆ‡e

         db        90h                      ; instrukce NOP
         db        'MSDOS4.0'               ; firemn¡ n zev a verze (OEM)
delka    dw        512                      ; d‚lka sektoru (bajt–)
blok     db        2                        ; velikost bloku (sektor–)
rezsekt  dw        1                        ; po‡et rezerv.sektor– p©ed FAT
numfat   db        2                        ; po‡et aloka‡n¡ch tabulek FAT
maxroot  dw        0070h                    ; max. po‡. pol. z kl. adres ©e
maxsekt  dw        02d0h                    ; celkov˜ po‡. sektor– na m‚diu
typdsk   db        0fdh                     ; typ disku (popisova‡ m‚dia)
sektfat  dw        2                        ; po‡et sektor– v jednom FAT
sektnm   dw        9                        ; po‡et sektor– na stopu
numhlav  dw        2                        ; po‡et hlav disku
hidsekt  dw        0                        ; po‡et skryt˜ch sektor–
d7c1e    dw        0
d7c20    dw        0
d7c22    db        0,0
disk     db        0                        ; ‡¡slo disku
hlava    db        0                        ; ‡¡slo hlavy ke ‡ten¡
d7c26    db        29h,0d0h,15h,51h,21h
d7c2b    db        'NO NAME    FAT12   '



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
 + 7    7c45h   1     d‚lka prodelvy pro form tovac¡ operace
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
         xor       ax,ax                    ; segment = 0
         mov       ss,ax                    ; nastaven¡ segm. z sobn¡ku 0
         mov       sp,offset start          ; ukazatel z sob. pod program
         push      ss                       ; = 00
         pop       es                       ; ES = 00 (segment 0)
         mov       bx,78h                   ; ukazatel disk. param. INT 13H
         lds       si,ss:[bx]               ; DS:SI <-- tab. disk. param.
         push      ds                       ; segment tab. disk. parametr–
         push      si                       ; offset tabulky disk.parametr–
         push      ss                       ; segment 0
         push      bx                       ; adr. ukaz. tab. disk. param.
         mov       di,offset tabdsk         ; za‡ tek tabulky parametr–
         mov       cx,11                    ; d‚lka tabulky disk. parametr–
         cld                                ; smˆr p©enosu nahoru
         rep       movsb                    ; na‡ten¡ tab. disk. parametr–
         push      es                       ; segment 0
         pop       ds                       ; DS <-- 0
         mov       byte ptr [di-2],0fh      ; 7c3c <-- 0fh
         mov       cx,[sektnm]              ; po‡et sektor– na stopu
         mov       byte ptr [di-7],cl       ; 7c37 <-- 0
         mov       word ptr [bx+2],ax       ; adresa tab.disk.par.<--tabdsk
         mov       word ptr [bx],offset tabdsk; nov  adresa tab. disk. par.
         sti                                ; povolen¡ p©eru¨en¡
         int       13h                      ; reset disku
         jc        booterr                  ; chyba (tisk hl ¨en¡)
         xor       ax,ax                    
         cmp       [maxsekt],ax             ; celkov˜ po‡et sekt. na m‚diu
         jz        boot1                    ; nen¡ ‘ dn˜ sektor
         mov       cx,[maxsekt]             ; celkov˜ po‡et sekt. na m‚diu
         mov       [d7c20],cx               ; = 0
boot1:   mov       al,[numfat]              ; po‡et aloka‡n¡ch tabulek FAT
         mul       word ptr [sektfat]       ; po‡et sektor– v jednom FAT
         add       ax,[hidsekt]             ; po‡et skryt˜ch sektor–
         adc       dx,[d7c1e]               ; = 0
         add       ax,[rezsekt]             ; po‡et rezerv.sektor– p©ed FAT
         adc       dx,0                     
         mov       word ptr [tabdsk+18],ax  ; po‡ t. sektor z kl. adres ©e
         mov       word ptr [tabdsk+20],dx  ; po‡ t. sektor z kl. adres ©e
         mov       word ptr [tabdsk+11],ax  ; ‡¡ta‡ rel. ‡. sekt. (LOW)
         mov       word ptr [tabdsk+13],dx  ; ‡¡ta‡ rel. ‡. sekt. (HIGH)
         mov       ax,32                    ; d‚lka polo‘ky adres. (bajt–)
         mul       word ptr [maxroot]       ; v˜po‡et d‚lky z kl. adres ©e
         mov       bx,[delka]               ; d‚lka sektoru (bajt–)
         add       ax,bx                    ;
         dec       ax                       
         div       bx                       ; v˜po‡et po‡ te‡. sektoru dat
         add       word ptr [tabdsk+11],ax  ; ‡¡ta‡ rel. ‡. sekt. (LOW)
         adc       word ptr [tabdsk+13],0   ; ‡¡ta‡ rel. ‡. sekt. (HIGH)
         mov       bx,0500h                 ; adresa k zaveden¡ adres ©e
         mov       dx,word ptr [tabdsk+20]  ; po‡ t. sektor z kl. adres ©e
         mov       ax,word ptr [tabdsk+18]  ; po‡ t. sektor z kl. adres ©e
         call      setpar                   ; nastav.sektoru, v lce a hlavy
         jc        booterr                  ; chyba (p©ete‡en¡ disku)
         mov       al,1                     ; po‡et sektor– ke ‡ten¡ = 1
         call      readsekt                 ; ‡ten¡ sekt. adres. od 0:0500H
         jc        booterr                  ; chyba ‡ten¡ adres ©e
         mov       di,bx                    ; konec sektoru adres ©e
         mov       cx,11                    ; d‚lka jm‚na souboru IO.SYS
         mov       si,offset soubio         ; jm‚no souboru IO.SYS
         rep       cmpsb                    ; kontrola jm‚na
         jnz       booterr                  ; nen¡ - hl ¨en¡ chyby
         lea       di,[bx+32]               ; DI - ukazuje na 2. polo‘ku
         mov       si,offset soubdos        ; jm‚no souboru DOS.SYS
         mov       cx,11                    ; d‚lka jm‚na DOS.SYS
         rep       cmpsb                    ; porovn n¡ jm‚na DOS.SYS
         jz        readio                   ; nata‘en¡ zavadˆ‡e syst‚mu
booterr: mov       si,offset texterr        ; text Nen¡ syst‚mov˜ disk ...
         call      tisktxt                  ; tisk chybov‚ho hl ¨en¡
         xor       ah,ah                    ; funkce ‡ten¡ znaku z kl ves.
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         pop       si                       ;
         pop       ds                       
         pop       [si]                     
         pop       [si+2]                   
         int       19h                      ; skok do slu‘by zaveden¡ syst.
booter2: pop       ax                       
         pop       ax                       
         pop       ax                       
         jmp       booterr                  ; skok zpˆt na hl ¨en¡
                                            ; na‡ten¡ 3 sektor– soub.IO.SYS
                                            ; ES = segment (=0)
readio:  mov       bx,0700h                 ; adresa po‡ tku bufferu
         mov       cx,3                     ; po‡et sektor– k na‡ten¡ = 3
         mov       ax,word ptr [tabdsk+11]  ; rel. ‡¡slo sektoru - LOW
         mov       dx,word ptr [tabdsk+13]  ; rel. ‡¡slo sektoru - HIGH
nxtsekt: push      ax                       ; ‡¡slo stopy - ni‘¨¡ slovo
         push      dx                       ; ‡¡slo stopy - vy¨¨¡ slovo
         push      cx                       ; po‡et sektor–
         call      setpar                   ; nastav.sektoru, v lce a hlavy
         jc        booter2                  ; chybov‚ hl ¨en¡
         mov       al,1                     ; po‡et sektor– ke ‡ten¡ = 1
         call      readsekt                 ; na‡ten¡ sektor– do pamˆti
         pop       cx                       ; po‡et sektor–
         pop       dx                       ; ‡¡slo sektoru
         pop       ax                       ; ‡¡slo stopy
         jc        booterr                  ; chybov‚ hl ¨en¡
         add       ax,1                     ; zv˜¨en¡ ukaz. stopy (LOW)
         adc       dx,0                     ; zv˜¨en¡ ukaz. stopy (HIGH)
         add       bx,[delka]               ; zv˜¨en¡ ukl dac¡ adr.o sektor
         loop      nxtsekt                  ; dal¨¡ sektor ke ‡ten¡
         mov       ch,[typdsk]              ; typ disku (popisova‡ m‚dia)
         mov       dl,[disk]                ; ‡¡slo disku
         mov       bx,word ptr [tabdsk+11]  ; rel. ‡¡slo n sled. sektoru
         mov       ax,word ptr [tabdsk+13]  ;    -  "  -  (ni‘¨¡ slovo)

         db        0eah,0,0,70h,0
;        jmp       far ptr 0070h:0000h      ; start modulu IO.SYS

                                            ; tisk textu na adrese DS:SI
tisktxt: lodsb                              ; p©e‡ten¡ znaku k tisku
         or        al,al                    ; byl koncov˜ znak ?
         jz        bootret                  ; konec tisku textu
         mov       ah,0eh                   ; funkce tisku znaku v TTY m¢du
         mov       bx,0007h                 ; = b¡l‚ p¡smo, str nka 0
         int       10h                      ; tisk znaku v AL
         jmp       tisktxt                  ; dal¨¡ znak k tisku

                                            ; nastav.sektoru, v lce a hlavy
                                            ; vstup:AX = rel.sektor (LOW)
                                            ;       DX = rel.sektor (HIGH)
setpar:  cmp       dx,[sektnm]              ; po‡et sektor– na stopu
         jnc       setpar2                  ; nen¡ dal¨¡ sektor na stopˆ
         div       word ptr [sektnm]        ; po‡et sektor– na stopu
         inc       dl                       ; ‡¡slo sektoru ke ‡ten¡
         mov       byte ptr [tabdsk+17],dl  ; ‡¡slo sektoru ke ‡ten¡
         xor       dx,dx
         div       word ptr [numhlav]       ; dˆleno po‡tem hlav disku
         mov       [hlava],dl               ; ‡¡slo hlavy ke ‡ten¡
         mov       word ptr [tabdsk+15],ax  ; ‡¡slo v lce ke ‡ten¡
         clc                                ; p©evod OK
         ret                                
setpar2: stc                                ; nastaven¡ p©¡znaku chyby
bootret: ret                                
                                            ; na‡ten¡ sektor– do pamˆti
                                            ; vstup:  AL = po‡et sektor–
readsekt:mov       ah,2                     ; funkce ‡ten¡ sekt. do pamˆti
         mov       dx,word ptr [tabdsk+15]  ; ‡¡slo v lce ke ‡ten¡
         mov       cl,6                     ; po‡et rotac¡
         shl       dh,cl                    ; vyn soben¡ * 64 (bity 9,8)
         or        dh,byte ptr [tabdsk+17]  ; ‡ten˜ sekt.OR bity 9,8 stopy
         mov       cx,dx                    ; CL = ‡.v lce; CH = ‡.sektoru
         xchg      ch,cl                    ; CH = ‡.v lce; CL = ‡.sektoru
         mov       dl,[disk]                ; ‡¡slo disku
         mov       dh,[hlava]               ; ‡¡slo hlavy ke ‡ten¡
         int       13h                      ; ‡ten¡ sektor– do pamˆti
         ret                                

texterr  db        0dh,0ah,'Non-System disk or disk error'
         db        0dh,0ah,'Replace and press any key'
         db        ' when ready',0dh,0ah,0

soubio   db        'IO      SYS'
soubdos  db        'MSDOS   SYS'

         db        0,0,0,0,0,0,0,0,0,0,0,0,0,85,170

         code      ends

         end       start

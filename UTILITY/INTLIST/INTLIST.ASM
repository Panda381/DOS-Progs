;------------------------------------------------------------------------------
;                     Program pro zobrazen¡ obsahu pamˆti
;------------------------------------------------------------------------------
code     SEGMENT   page
         ASSUME    cs:code,ds:code
         org       100h
start:
                                          ;* zobrazen¡ nadpisu
         lea       si,[txtnadp]
         call      outtxt                   ; zobrazen¡ nadpisu

         xor       ax,ax
         mov       es,ax                    ; str nka 0 pamˆti
         xor       di,di                    ; ukazatel ‡tec¡ adresy
         mov       cx,256                   ; po‡et p©eru¨en¡ k zobrazen¡
list1:   mov       al,0
         sub       al,cl                    ; ‡¡slo p©eru¨en¡
         call      hexbyte                  ; zobrazen¡ ‡¡sla p©eru¨en¡
         mov       al,"h"
         call      outch                    ; znak "h"
         mov       al,2
         call      outspc                   ; oddˆlovac¡ mezera
         mov       ax,es:[di]               ; ni‘¨¡ slovo adresy
         mov       dx,es:[di+2]             ; vy¨¨¡ slovo adresy
         call      hexdwrd                  ; zobrazen¡ obsahu na adres ch
         mov       al,2
         call      outspc                   ; oddˆlovac¡ mezera

         call      outtxt                   ; zobrazen¡ pozn mky k p©eru¨en¡
         call      outcr                    ; od© dkov n¡
         add       di,4                     ; zv˜¨en¡ ukazatele v pamˆti
         loop      list1                    ; zobrazen¡ dal¨¡ho p©eru¨en¡

         mov       ax,4c00h
         int       21h                      ; n vrat z programu

; -----------------------------------------------------------------------------
;                               Znakov‚ v˜stupy
; -----------------------------------------------------------------------------
public   outspc

outspc:                                   ;* zobrazen¡ oddˆlovac¡ch mezer
                                            ; VSTUP: AL=po‡et mezer
         push      ax
         push      cx
         xor       cx,cx
         mov       cl,al                    ; po‡et mezer
         jcxz      outspc2
outspc1: mov       al," "
         call      outch                    ; zobrazen¡ mezery
         loop      outspc1                  ; dal¨¡ mezera
outspc2: pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
public   outcr
outcr:                                    ;* od© dkov n¡
         push      ax
         mov       al,13
         call      outch
         mov       al,10
         call      outch
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   hexdwrd,hexwrd,hexbyte,hexchr
hexdwrd:                                  ;* zobrazen¡ dvojslova DX:AX
         push      ax
         mov       ax,dx
         call      hexwrd                   ; zobrazen¡ vy¨¨¡ho slova
         mov       al,":"                   ; oddˆlova‡ slov
         call      outch                    ; zobrazen¡ oddˆlova‡e slov
         pop       ax

hexwrd:                                   ;* zobrazen¡ slova HEX
         push      ax
         mov       al,ah                    ; vy¨¨¡ bajt slova
         call      hexbyte                  ; zobrazen¡ vy¨¨¡ho bajtu slova
         pop       ax

hexbyte:                                  ;* zobrazen¡ bajtu HEX
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      hexchr                   ; zobrazen¡ vy¨¨¡ tetr dy bajtu HEX
         pop       ax
hexchr:                                   ;* zobrazen¡ tetr dy bajtu
         push      ax
         and       al,0fh                   ; ni‘¨¡ tetr da bajtu
         cmp       al,10                    ; je znak HEX ?
         jb        hexchr2                  ; je ‡¡slice
         add       al,7                     ; korekce na znak HEX
hexchr2: add       al,"0"                   ; korekce na znak ASCII
         call      outch                    ; zobrazen¡ znaku
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   outtxt
outtxt:                                   ;* zobrazen¡ textu
                                            ; VSTUP: DS:SI=adresa textu
         push      ax
outtx0:  lodsb
         or        al,al
         jz        outtx1
         call      outch                    ; zobrazen¡ znaku
         jmp       short outtx0
outtx1:  pop       ax
         ret
; -----------------------------------------------------------------------------
public   outch
outch:                                    ;* zobrazen¡ znaku
                                            ; VSTUP: AL=znak
         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen¡
         mov       ah,2
         int       21h                      ; zobrazen¡ znaku
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                           Data a texty
; -----------------------------------------------------------------------------
public   txtnadp
txtnadp  db        'INT    Obsah                   Popis',13,10
         db        '----------------------------------------------'
         db        '--------------------------',13,10,0

txt00    db        'Chyba p©i dˆlen¡ ‡¡sla nulou',0
txt01    db        'Proveden¡ instrukce p©i krokovac¡m re‘imu procesoru',0
txt02    db        'Nemaskovateln‚ p©eru¨en¡ NMI (chyba parity RAM) - IRQ 13',0
txt03    db        'Bod p©eru¨en¡ p©i ladˆn¡ programu debuggerem',0
txt04    db        'Chyba p©ete‡en¡ aritmetick‚ operace (INTO)',0
txt05    db        'Vyti¨tˆn¡ obsahu obrazovky <Print Screen>',0
txt06    db        'Nedefinovan˜ opera‡n¡ k¢d instrukce (80286+)',0
txt07    db        'Matematick˜ koprocesor nen¡ k dispozici (80286+)',0
txt08    db        'P©eru¨en¡ od syst‚m. hodin (perioda 54.9237 ms) - IRQ 0',0
txt09    db        'P©eru¨en¡ od kl vesnice - IRQ 1',0
txt0a    db        'Zpˆtn˜ bˆh EGA, kask dn¡ p©eru¨en¡ AT (IRQ 8-15) - IRQ 2',0
txt0b    db        'P©eru¨en¡ od s‚riov‚ho portu COM2 a COM4 - IRQ 3',0
txt0c    db        'P©eru¨en¡ od s‚riov‚ho portu COM1 a COM3 - IRQ 4',0
txt0d    db        'P©eru¨en¡ od ©adi‡e pevn˜ch disk– XT a od LPT2 - IRQ 5',0
txt0e    db        'P©eru¨en¡ od ©adi‡e pru‘n˜ch disk– - IRQ 6',0
txt0f    db        'P©eru¨en¡ od tisk rny LPT1 - IRQ 7',0
txt10    db        'Servis obsluhy displeje',0
txt11    db        '€ten¡ tabulky vybaven¡',0
txt12    db        'Hl ¨en¡ o velikosti pamˆti v re ln‚m m¢du',0
txt13    db        'Servis diskov˜ch operac¡',0
txt14    db        'Servis s‚riov˜ch komunika‡n¡ch port–',0
txt15    db        'Roz¨i©uj¡c¡ a kazetov‚ slu‘by',0
txt16    db        'Obsluha vstupu z kl vesnice',0
txt17    db        'Obsluha v˜stupu na tisk rnu',0
txt18    db        'P©ed n¡ ©¡zen¡ vestavˆn‚mu interpreteru ROM-BASIC',0
txt19    db        'Zavaden¡ opera‡n¡ho syst‚mu',0
txt1a    db        'Slu‘by syst‚mov‚ho ‡asova‡e a hodin',0
txt1b    db        'P©eru¨en¡ kl vesnic¡ p©i <Ctrl>-<Break>',0
txt1c    db        'U‘ivatelsk‚ ‡asovac¡ impulsy (perioda 54.9237 ms)',0
txt1d    db        'Ukazatel na tabulku videoparametr– 6845',0
txt1e    db        'Ukazatel na tabulku disketov˜ch parametr–',0
txt1f    db        'Ukazatel na tabulku grafick˜ch znak–',0
txt20    db        'P©eru¨en¡ programu DOS',0
txt21    db        'Slu‘by opera‡n¡ho syst‚mu DOS',0
txt22    db        'Adresa pro ukon‡en¡ programu DOS',0
txt23    db        'Adresa obsluhy p©eru¨en¡ <Ctrl>-<Break> DOS',0
txt24    db        'Obsluha kritick˜ch chyb DOS',0
txt25    db        'Absolutn¡ ‡ten¡ z disku DOS',0
txt26    db        'Absolutn¡ z pis na disk DOS',0
txt27    db        'Ukon‡en¡ programu a ponech n¡ rezidentn¡m',0
txt28    db        'Obsluha p©i ‡ek n¡ na znak z kl vesnice',0
txt29    db        'V˜stup znaku na standardn¡ v˜stupn¡ za©¡zen¡ DOS',0
txt2a    db        'Obsluha s¡Ÿov‚ho za©¡zen¡ Microsoft Networks',0
txt2b    db        'Rezervov no - vnit©n¡ rutina DOS',0
txt2c    db        'Rezervov no - vnit©n¡ rutina DOS',0
txt2d    db        'Rezervov no - vnit©n¡ rutina DOS',0
txt2e    db        'Proveden¡ povelu DOS',0
txt2f    db        'P©ep¡nateln  p©eru¨en¡ DOS',0
txt30    db        'Instrukce FAR JMP pro vol n¡ DOS podle CP/M (CALL 5)',0
txt31    db        '... pokra‡ov n¡ instrukce FAR JMP z INT 30h',0
txt32    db        'Rezervov no',0
txt33    db        'Slu‘by ovlada‡e my¨i MS MOUSE',0
txt34    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d D8h',0
txt35    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d D9h',0
txt36    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d DAh',0
txt37    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d DBh',0
txt38    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d DCh',0
txt39    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d DDh',0
txt3a    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d DEh',0
txt3b    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - opera‡n¡ k¢d DFh',0
txt3c    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - instrukce s ES',0
txt3d    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - instrukce FWAIT',0
txt3e    db        'Emul tor plovouc¡ ‡ rky Borland/Microsoft - zkr cen‚ vol n¡',0
txt3f    db        'P©eru¨en¡ obsluhy p©ekryvn˜ch segment– Microsoft LINK.EXE',0
txt40    db        'Pevn˜ disk - p©em¡stiteln˜ ovlada‡ floppy disk–',0
txt41    db        'Ukazatel na tabulku parametr– pevn‚ho disku 0',0
txt42    db        'Vstupn¡ bod EGA na standardn¡ obsluhu displeje BIOS',0
txt43    db        'Ukazatel na inicializa‡n¡ font EGA',0
txt44    db        'Ukazatel na tabulku grafick˜ch znak– EGA',0
txt45    db        'Z100 - s‚riov˜ port B Master 8259',0
txt46    db        'Ukazatel na tabulku parametr– pevn‚ho disku 1',0
txt47    db        'Z100 - paraleln¡ port tisk rny Master 8259',0
txt48    db        'Obsluha kl vesnice PC Jr',0
txt49    db        'P©evodn¡ tabulka orienta‡n¡ch k¢d– kl ves PC Jr',0
txt4a    db        'U‘ivatelsk˜ ‡asov˜ alarm',0
txt4b    db        'Z100 - linka 3 Slave 8250 - S100',0
txt4c    db        'Z100 - linka 4 Slave 8250 - S100',0
txt4d    db        'Z100 - linka 5 Slave 8250 - S100',0
txt4e    db        'Z100 - linka 6 Slave 8250 - S100',0
txt4f    db        'Z100 - linka 7 Slave 8250 - S100',0
txt50    db        'P©eru¨en¡ ‡asova‡em CMOS-alternat. p©eru¨en¡ IRQ 0 (DESQview)',0
txt51    db        'Alternativn¡ p©eru¨en¡ IRQ 1 (DESQview)',0
txt52    db        'Alternativn¡ p©eru¨en¡ IRQ 2 (DESQview)',0
txt53    db        'Alternativn¡ p©eru¨en¡ IRQ 3 (DESQview)',0
txt54    db        'Alternativn¡ p©eru¨en¡ IRQ 4 (DESQview)',0
txt55    db        'Alternativn¡ p©eru¨en¡ IRQ 5 (DESQview)',0
txt56    db        'Alternativn¡ p©eru¨en¡ IRQ 6 (DESQview)',0
txt57    db        'Alternativn¡ p©eru¨en¡ IRQ 7 (DESQview)',0
txt58    db        'Rezervov no',0
txt59    db        'Grafick˜ interface GSS*CGI',0
txt5a    db        'Adapt‚r aloka‡n¡ch blok– BIOS',0
txt5b    db        'Pou‘ito adapt‚rem aloka‡n¡ch blok– BIOS',0
txt5c    db        'Obsluha s¡Ÿov‚ho adapt‚ru NETBIOS',0
txt5d    db        'Rezervov no',0
txt5e    db        'Rezervov no',0
txt5f    db        'Rezervov no',0
txt60    db        'U‘ivatelsk‚ p©eru¨en¡ - vyu‘¡v  SYS_PROF.EXE a ovlada‡ FTP',0
txt61    db        'U‘ivatelem definovateln‚ p©eru¨en¡',0
txt62    db        'U‘ivatelem definovateln‚ p©eru¨en¡',0
txt63    db        'U‘ivatelem definovateln‚ p©eru¨en¡',0
txt64    db        'U‘ivatelsk‚ p©eru¨en¡ - vyu‘¡v  s¡Ÿ Novell: LOW-LEVEL API',0
txt65    db        'U‘ivatelsk‚ p©eru¨en¡ - vyu‘¡v  SD62.COM',0
txt66    db        'U‘ivatelsk‚ p©eru¨en¡ - vyu‘¡v  THESPLUS',0
txt67    db        'Ovlada‡ roz¨¡©en‚ pamˆti LIM EMS',0
txt68    db        'APPC/PC',0
txt69    db        'Nepou‘ito',0
txt6a    db        'Rezidentn¡ help OPTHELP.COM v syst‚mu SLR assembleru OPTASM',0
txt6b    db        'Nepou‘ito',0
txt6c    db        'Pokra‡ov n¡ programu po n vratu nap jen¡ PC Jr',0
txt6d    db        'Internˆ pou‘¡v  VGA',0
txt6e    db        'Nepou‘ito',0
txt6f    db        'Vyu‘ito v HP ES-12 BIOS, Novell NetWare a 10-NET BIOS',0
txt70    db        'Hodiny re ln‚ho ‡asu - IRQ 8',0
txt71    db        'S¡Ÿov˜ adapt‚r LAN (p©esmˆrov no na INT 0Ah) - IRQ 9',0
txt72    db        'Rezervov no - IRQ 10',0
txt73    db        'Rezervov no - IRQ 11',0
txt74    db        'P©eru¨en¡ od my¨i v PS50+ - IRQ 12',0
txt75    db        'P©eru¨en¡ od koprocesoru 80287 p©i chybˆ (INT 02h) - IRQ 13',0
txt76    db        'P©eru¨en¡ od ©adi‡e pevn‚ho disku AT - IRQ 14',0
txt77    db        'Rezervov no - IRQ 15',0
txt78    db        'Nepou‘ito',0
txt79    db        'Nepou‘ito',0
txt7a    db        'S¡Ÿ Novell NetWare - LOW-LEVEL API, interface za©¡zen¡ AutoCAD',0
txt7b    db        'Btrieve API',0
txt7c    db        'Interpreter povel– IBM REXX88PC',0
txt7d    db        'Nepou‘ito',0
txt7e    db        'Nepou‘ito',0
txt7f    db        'Pou‘ito v HDILOAD.EXE, Halo88-API, HLLAPI',0
txt80    db        'Q-PRO4',0
txt81    db        'BASIC',0
txt82    db        'BASIC',0
txt83    db        'BASIC',0
txt84    db        'BASIC',0
txt85    db        'BASIC',0
txt86    db        'NETBIOS - p©esmˆrov no INT 18h',0
txt87    db        'Interpreter BASIC',0
txt88    db        'Interpreter BASIC',0
txt89    db        'Interpreter BASIC',0
txt8a    db        'Interpreter BASIC',0
txt8b    db        'Interpreter BASIC',0
txt8c    db        'Interpreter BASIC',0
txt8d    db        'Interpreter BASIC',0
txt8e    db        'Interpreter BASIC',0
txt8f    db        'Interpreter BASIC',0
txt90    db        'Interpreter BASIC',0
txt91    db        'Interpreter BASIC',0
txt92    db        'Interpreter BASIC',0
txt93    db        'Interpreter BASIC',0
txt94    db        'Interpreter BASIC',0
txt95    db        'Interpreter BASIC',0
txt96    db        'Interpreter BASIC',0
txt97    db        'Interpreter BASIC',0
txt98    db        'Interpreter BASIC',0
txt99    db        'Interpreter BASIC',0
txt9a    db        'Interpreter BASIC',0
txt9b    db        'Interpreter BASIC',0
txt9c    db        'Interpreter BASIC',0
txt9d    db        'Interpreter BASIC',0
txt9e    db        'Interpreter BASIC',0
txt9f    db        'Interpreter BASIC',0
txta0    db        'Interpreter BASIC',0
txta1    db        'Interpreter BASIC',0
txta2    db        'Interpreter BASIC',0
txta3    db        'Interpreter BASIC',0
txta4    db        'Interpreter BASIC, pou‘ito v API',0
txta5    db        'Interpreter BASIC',0
txta6    db        'Interpreter BASIC',0
txta7    db        'Interpreter BASIC',0
txta8    db        'Interpreter BASIC',0
txta9    db        'Interpreter BASIC',0
txtaa    db        'Interpreter BASIC',0
txtab    db        'Interpreter BASIC',0
txtac    db        'Interpreter BASIC',0
txtad    db        'Interpreter BASIC',0
txtae    db        'Interpreter BASIC',0
txtaf    db        'Interpreter BASIC',0
txtb0    db        'Interpreter BASIC',0
txtb1    db        'Interpreter BASIC',0
txtb2    db        'Interpreter BASIC',0
txtb3    db        'Interpreter BASIC',0
txtb4    db        'Interpreter BASIC',0
txtb5    db        'Interpreter BASIC',0
txtb6    db        'Interpreter BASIC',0
txtb7    db        'Interpreter BASIC',0
txtb8    db        'Interpreter BASIC',0
txtb9    db        'Interpreter BASIC',0
txtba    db        'Interpreter BASIC',0
txtbb    db        'Interpreter BASIC',0
txtbc    db        'Interpreter BASIC',0
txtbd    db        'Interpreter BASIC',0
txtbe    db        'Interpreter BASIC',0
txtbf    db        'Interpreter BASIC',0
txtc0    db        'Interpreter BASIC',0
txtc1    db        'Interpreter BASIC',0
txtc2    db        'Interpreter BASIC',0
txtc3    db        'Interpreter BASIC',0
txtc4    db        'Interpreter BASIC',0
txtc5    db        'Interpreter BASIC',0
txtc6    db        'Interpreter BASIC',0
txtc7    db        'Interpreter BASIC',0
txtc8    db        'Interpreter BASIC',0
txtc9    db        'Interpreter BASIC',0
txtca    db        'Interpreter BASIC',0
txtcb    db        'Interpreter BASIC',0
txtcc    db        'Interpreter BASIC',0
txtcd    db        'Interpreter BASIC',0
txtce    db        'Interpreter BASIC',0
txtcf    db        'Interpreter BASIC',0
txtd0    db        'Interpreter BASIC',0
txtd1    db        'Interpreter BASIC',0
txtd2    db        'Interpreter BASIC',0
txtd3    db        'Interpreter BASIC',0
txtd4    db        'Interpreter BASIC',0
txtd5    db        'Interpreter BASIC',0
txtd6    db        'Interpreter BASIC',0
txtd7    db        'Interpreter BASIC',0
txtd8    db        'Interpreter BASIC',0
txtd9    db        'Interpreter BASIC',0
txtda    db        'Interpreter BASIC',0
txtdb    db        'Interpreter BASIC',0
txtdc    db        'Interpreter BASIC',0
txtdd    db        'Interpreter BASIC',0
txtde    db        'Interpreter BASIC',0
txtdf    db        'Interpreter BASIC',0
txte0    db        'Interpreter BASIC, vol n¡ funkc¡ CP/M-86',0
txte1    db        'Interpreter BASIC',0
txte2    db        'Interpreter BASIC',0
txte3    db        'Interpreter BASIC',0
txte4    db        'Interpreter BASIC, Logitech Modula v2.0',0
txte5    db        'Interpreter BASIC',0
txte6    db        'Interpreter BASIC',0
txte7    db        'Interpreter BASIC',0
txte8    db        'Interpreter BASIC',0
txte9    db        'Interpreter BASIC',0
txtea    db        'Interpreter BASIC',0
txteb    db        'Interpreter BASIC',0
txtec    db        'Interpreter BASIC',0
txted    db        'Interpreter BASIC',0
txtee    db        'Interpreter BASIC',0
txtef    db        'Interpreter BASIC, interface GEM',0
txtf0    db        'Interpreter BASIC',0
txtf1    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf2    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf3    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf4    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf5    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf6    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf7    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtf8    db        '€asova‡ interval– 10 ms (TANDY)',0
txtf9    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtfa    db        'Stav p©ipravenosti USART RS-232 (TANDY)',0
txtfb    db        'Stav p©ipravenosti USART Rx kl vesnice (TANDY)',0
txtfc    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtfd    db        'Rezervov no pro u‘ivatelsk‚ p©eru¨en¡',0
txtfe    db        'Obsah vektoru zni‡en n vratem z ochrann‚ho m¢du AT',0
txtff    db        'Obsah vektoru zni‡en n vratem z ochrann‚ho m¢du AT',0

code     ENDS
         END       start               ; startovac¡ adresa

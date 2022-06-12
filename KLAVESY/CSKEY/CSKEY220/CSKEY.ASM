
; *****************************************************************************
;
;                         Ovladaá áeskÇ kl†vesnice
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:   jmp       init                     ; instalace programu

Ident    db        'CSKEY V 2.20; (c) Miroslav Nàmeáek',13,10
Ident0   label     byte

; -----------------------------------------------------------------------------
;                          Rezidentn° data
; -----------------------------------------------------------------------------
old08    dd        0                        ; pñvodn° obsluha INT 08h
old09    dd        0                        ; pñvodn° obsluha INT 09h
old10    dd        0                        ; pñvodn° obsluha INT 10h
old16    dd        0                        ; pñvodn° obsluha INT 16h

switch   db        01010001b                ; p©°znaky kl†vesnice
                                            ; bit 0 - bit 2 = á°slo kl†vesnice
                                            ;                 (1 aë 7)
                                            ; bit 4 = je funkce stm°v†n°
                                            ; bit 5 = ztmaven° displeje
                                            ; bit 6 = zapnuta zvukov† signaliz.
                                            ; bit 7 = byl prefix

switchk  db        0                        ; pouëitò k¢d kl†vesnice
                                            ; bit 0-1: 0=Kamenickòch
                                            ;          1=Latin 2
                                            ;          2=T602
                                            ;          (3=uëivatelsk†)
                                            ; bit 2:   1=sloven®tina

parint   db        0                      ;* p©°znak obsluh p©eru®en°
                                            ; bit 0 = prob°h† INT 10h
                                            ; bit 1 = prob°h† INT 09h
                                            ; bit 2 = prob°h† INT 16h
                                            ; (bit 3 = prob°h† INT 21h)
                                            ; bit 4 = nen° poëad. obsluhy ztmav.
                                            ; bit 5 = poëadavek p©eru®en° prog.
                                            ; bit 6 = prob°h† obsluha ztmaven°
                                            ; bit 7 = displej je ztmaven

prefkey1 dw        "``"                     ; prefixy pro norm†ln° a prog. kl†v.
prefkey2 dw        "+="                     ; prefixy pro p°sa©skou kl†vesnici

levs     db        3                        ; hlasitost p°pnut° 0 aë 9
levr     db        1                        ; hlasitost p©i opakov†n° 0 aë 9
ton      db        4                        ; vò®ka t¢nu 0 aë 9

timech   db        0                        ; znak nastaven° doby
timeoff  dw        5463                     ; doba pro vypnut° displeje (5 min.)
count    dw        1092                     ; á°taá ztmavnut° (1 minuta)

typdisp  db        0                        ; typ displeje:
                                            ;    0=nestandardn°
                                            ;    1=CGA
                                            ;    2=MDA
                                            ;    3=EGA

znakz    dw        32                       ; poslednà vloëenò znak
lastch   db        0                        ; poslednà stisknut† kl†vesa

; -----------------------------------------------------------------------------
;               Obsluha p©eru®en° od kl†vesnice INT 09H
; -----------------------------------------------------------------------------
int091:  jmp       dword ptr cs:[old09]     ; pñvodn° obsluha kl†vesnice

int09:                                      ; program obsluhy kl†vesnice

         test      byte ptr cs:[parint],2   ; prob°h† jië obsluha INT 09h ?
         jnz       int091                   ; prob°h† jië obsluha INT 09h
         or        byte ptr cs:[parint],2   ; p©°znak, ëe prob°h† obsluha INT 09
         push      ax                       ; £schova registru AX
         push      bx                       ; £schova registru BX
         push      cx                       ; £schova registru CX
         push      dx                       ; £schova registru DX
         push      si                       ; £schova registru SI
         push      ds                       ; £schova registru DS
         in        al,[60h]                 ; áten° k¢du kl†vesy
         test      al,80h                   ; je stisk kl†vesy ?
         jnz       cskey0                   ; je povolen° kl†vesy
         mov       bx,cs:[timeoff]          ; doba pro vypnut° displeje
         mov       word ptr cs:[count],bx   ; novÇ nastaven° á°taáe
         and       byte ptr cs:[switch],0dfh; nastaven° poëadavku zapnut° disp.
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
cskey0:  mov       ah,al                    ; £schova k¢du kl†vesy
         mov       bx,40h                   ; segment dat BIOS
         mov       ds,bx                    ; DS <- segment dat BIOS 0040h
         mov       bx,word ptr ds:[1ch]     ; ukl†dac° adresa znakñ
         pushf                              ; simulace vol†n° INT
         call      dword ptr cs:[old09]     ; pñvodn° obsluha kl†vesnice
         test      byte ptr cs:[parint],80h ; je displej ztmaven ?
         jz        cskey01                  ; displej nen° ztmaven
         mov       ds:[1ch],bx              ; zru®en° p©ijatÇ kl†vesy
         xor       ah,ah                    ; zru®en° uschovanÇ kl†vesy
cskey01: cmp       bx,word ptr ds:[1ch]     ; byl p©ijat znak ?
         jnz       cskey1                   ; byl p©ijat znak z kl†vesnice
                                          ;* nebyl p©ijat ë†dnò znak
         call      beepoff                  ; k¢d kl†vesy pro p°pnut°
         call      insert                   ; obsluha opakov†n° kl†vesy <Insert>
         jc        konec                    ; nebyla kl†vesa <Insert>
cskey1:                                   ;* byl p©ijat k¢d kl†vesy
         call      beep                     ; zvukov† signalizace stisku kl†vesy
         call      ramecek                  ; kreslen° r†meákñ
         jnc       konec                    ; operace OK - konec obsluhy
         call      opakovani                ; zn†soben° kurzorovòch kl†ves
         jnc       konec                    ; operace OK - konec obsluhy
         call      delpref                  ; zru®en° prefixu
         jnc       konec                    ; prefix byl zru®en
         call      prefix                   ; obsluha kl†vesy prefixu
         jnc       konec                    ; byl prefix - konec obsluhy
         call      prepinac                 ; p©ep°naá funkc° kl†vesnice
         jnc       konec                    ; byl p©ep°naá - konec obsluhy
         call      beepset                  ; nastaven° zvukovÇ signalizace
         jnc       konec                    ; nastaven° porvedeno
         call      prekod                   ; p©ek¢dov†n° p©ijatÇho znaku

konec:
         cmp       bx,word ptr ds:[1ch]     ; je v bufferu znak ?
         jz        cskey3                   ; v bufferu nen° znak
         mov       ax,[bx]                  ; znak v bufferu
         or        ah,ah
         jz        cskey2
         cmp       ah,53h                   ; kl†vesa <Delete>
         je        cskey2
         cmp       al,0e0h
         je        cskey3
         cmp       al,0f0h
         je        cskey3
         cmp       al,20h
         jb        cskey3
         cmp       al,7fh
         je        cskey3
cskey2:  mov       cs:[znakz],ax            ; £schova posledn°ho znaku
cskey3:  pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         and       byte ptr cs:[parint],not 2; zru®en° p©°znaku obsluhy INT 09h
         iret
; -----------------------------------------------------------------------------
;                        Podprogramy pro INT 09h
; -----------------------------------------------------------------------------
insert:                                     ; obsluha opakov†n° kl†vesy <Insert>
                                            ; VSTUP: AH=orientaán° k¢d kl†vesy

         cmp       ah,52h                   ; byla kl†vesa <Insert> ?
         stc                                ; p©°znak - nen° kl†vesa <Insert>
         jnz       insert1                  ; nen° kl†vesa <Insert>
         test      byte ptr ds:[17h],8      ; je stisknuta kl†vesa <Alt> ?
         jnz       insert1                  ; je stisknuta kl†vesa <Alt>
         xor       al,al                    ; AL <- 0
         call      inskey                   ; vloëen° kl†vesy <Insert>
insert1: ret
; -----------------------------------------------------------------------------
beepoff:                                    ; nebyla stisknuta kl†vesa
         cmp       al,0e0h                  ; je prefix k¢du kl†vesy ?
         je        beepof1                  ; je prefixovò k¢d kl†vesy
         mov       cs:[lastch],al           ; uloëen° k¢du kl†vesy
beepof1: ret

beep:                                     ;* zvukov† signalizace
         test      byte ptr cs:[switch],40h ; je zapnuta zvukov† signalizace ?
         jz        beep4                    ; zvukov† signalizace vypnut†
         push      ax
         push      bx
         push      cx                       ; £schova registru CX
         in        al,[61h]
         push      ax                       ; £schova nastaven° portu
         mov       cl,cs:[levs]             ; hlasitost p°pnut°
         mov       bx,20                    ; konstanta pro dÇlku t¢nu
         cmp       ah,cs:[lastch]           ; je opakov†n° posledn° kl†vesy ?
         mov       cs:[lastch],ah           ; uloëen° k¢du kl†vesy
         jne       beep0                    ; nen° opakov†n° kl†vesy
         mov       cl,cs:[levr]             ; hlasitost p©i opakov†n°
         mov       bx,4                     ; konstanta pro dÇlku t¢nu
beep0:   shl       bx,cl                    ; vòpoáet dÇlky p°pnut°
         mov       cx,bx                    ; dÇlka p°pnut°
         mov       bx,0a00h
         sub       bh,cs:[ton]              ; vò®ka t¢nu
         cmp       cs:[ton],0               ; je povoleno nastaven° t¢nu ?
         je        beep1                    ; nastaven° t¢nu nen° povoleno
         mov       al,0b6h                  ; povel pro nastaven° kan†lu 2
         out       [43h],al                 ; nastaven° kan†lu 2
         mov       al,bl                    ; nië®° bajt dàliáky
         out       [42h],al                 ; nastaven° nië®°ho bajtu dàliáky
         mov       al,bh                    ; vy®®° bajt dàliáky
         out       [42h],al                 ; nastaven° vy®®°ho bajtu dàliáky
beep1:   in        al,[61h]
         or        al,3                     ; zapnut° reproduktoru
         out       [61h],al
         loop      $                        ; áek†n° po zadanou dÇlku t¢nu
         pop       ax                       ; n†vrat nastaven° portu
         out       [61h],al
         pop       cx
         pop       bx
         pop       ax
beep4:   ret

beepset:                                  ;* nastaven° zvukovÇ signalizace
         test      byte ptr cs:[switch],80h ; byl zad†n prefix ?
         jz        beepset2                 ; nebyl zad†n prefix
         cmp       byte ptr [bx],"="        ; je zapnut° zvukovÇ signalizace ?
         je        beepset0                 ; je zapnut° zvukovÇ signalizace
         cmp       byte ptr [bx],"+"        ; je zapnut° zvukovÇ signalizace ?
         jne       beepset1                 ; nen° zapnut° zvukovÇ signalizace
beepset0:and       byte ptr cs:[switch],7fh ; zru®en° p©°znaku prefixu
         or        byte ptr cs:[switch],40h ; zapnut° zvukovÇ signalizace
         mov       word ptr ds:[1ch],bx     ; zru®en° kl†vesy z bufferu
         ret
beepset1:cmp       byte ptr [bx],"-"        ; je vypnut° zvukovÇ signalizace ?
         jne       beepset2                 ; nen° vypnut° zvukovÇ signalizace
         and       byte ptr cs:[switch],3fh ; vypnut° zvukovÇ signalizace
         mov       word ptr ds:[1ch],bx     ; zru®en° kl†vesy z bufferu
         ret
beepset2:stc                                ; p©°znak - operace neprovedena
         ret
; -----------------------------------------------------------------------------
ramecek:                                    ; kreslen° r†meákñ <Shift>-<Alt>
                                            ; VùSTUP: CY=funkce neprovedena

         mov       al,ds:[17h]              ; status p©esmykaáñ
         test      al,3                     ; je stisknut p©esmykaá <Shift> ?
         jz        ramec3                   ; nen° stisknut p©esmykaá <Shift>
         and       al,0ch                   ; p©°znaky <Ctrl> a <Alt>
         cmp       al,8                     ; je <Alt> bez <Ctrl> ?
         jnz       ramec3                   ; je jin† kombinace p©esmykaáñ
         mov       ax,[bx]                  ; p©ijatò k¢d kl†vesy
         cmp       ah,98h                   ; je kurzorov† kl†vesa nahoru ?
         je        ramec1                   ; je kurzorov† kl†vesa nahoru
         cmp       ah,0a0h                  ; je kurzorov† kl†vesa dolñ ?
         je        ramec1                   ; je kurzorov† kl†vesa dolñ
         cmp       ah,9bh                   ; je kurzorov† kl†vesa vlevo ?
         je        ramec1                   ; je kurzorov† kl†vesa vlevo
         cmp       ah,9dh                   ; je kurzorov† kl†vesa vpravo ?
         jne       ramec3                   ; nen° kurzorov† kl†vesa vpravo
         mov       ax,cs:[znakz]            ; poslednà zadanò znak ASCII
         mov       [bx],ax                  ; n†hrada poslednà zadanòm znakem
         jmp       short ramec2             ; ukonáen° obsluhy
ramec1:  push      ax                       ; £schova k¢du p©ijatÇ kl†vesy
         mov       ax,cs:[znakz]            ; poslednà zadanò znak ASCII
         mov       [bx],ax                  ; n†hrada poslednà zadanòm znakem
         cmp       ah,53h                   ; je klavesa <Delete> ?
         je        ramec10                  ; je klavesa <Delete>
         mov       ax,4b00h                 ; k¢d kurzoru vlevo
         call      inskey                   ; vloëen° k¢du kurzoru vlevo
ramec10: pop       ax                       ; n†vrat k¢du pñvodn° kl†vesy
         sub       ah,50h                   ; korekce na normalni kod klavesy
         call      inskey                   ; vloëen° pñvodn°ho k¢du kl†vesy
ramec2:  clc                                ; p©°znak - operace OK
         ret

ramec3:  stc                                ; p©°znak - k¢d kl†vesy nenalezen
         ret
; -----------------------------------------------------------------------------
opakovani:                                  ; n†soben° kurz. kl†ves <Ctrl>-<Alt>
                                            ; VùSTUP: CY=funkce neprovedena

         mov       al,ds:[17h]              ; status p©esmykaáñ
         and       al,0fh                   ; p©°znaky <Ctrl>, <Alt> a <Shift>
         cmp       al,0ch                   ; jsou stisknuty <Ctrl>-<Alt>
         jne       opakov3                  ; nen° kombinace <Ctrl>-<Alt>
         mov       ax,[bx]                  ; p©ijatò k¢d kl†vesy
         cmp       ah,98h                   ; je kurzorov† kl†vesa nahoru ?
         jz        opakov1                  ; je kurzorov† kl†vesa nahoru
         cmp       ah,0a0h                  ; je kurzorov† kl†vesa dolñ ?
         jz        opakov1                  ; je kurzorov† kl†vesa dolñ
         cmp       ah,9bh                   ; je kurzorov† kl†vesa vlevo ?
         jz        opakov1                  ; je kurzorov† kl†vesa vlevo
         cmp       ah,9dh                   ; je kurzorov† kl†vesa vpravo ?
         jnz       opakov3                  ; nen° kurzorov† kl†vesa vpravo
opakov1: sub       ah,50h                   ; maskov†n° na k¢d bez <Alt>-<Ctrl>
         mov       [bx],ax                  ; n†hrada k¢du kl†vesy
         mov       cx,9                     ; dopl§uj°c° poáet k¢dñ kl†ves
opakov2: call      inskey                   ; vloëen° k¢du kl†vesy do bufferu
         loop      opakov2                  ; vloëen° k¢du dal®° kl†vesy
         clc                                ; p©°znak - operace provedena OK
         ret

opakov3: stc                                ; p©°znak - k¢d kl†vesy nenalezen
         ret
; -----------------------------------------------------------------------------
delpref:                                    ; zru®en° prefixu kl†vesou <Delete>
         test      byte ptr cs:[switch],80h ; byl jië nàkterò prefix ?
         jz        delpref2                 ; nebyl ë†dnò prefix
         cmp       byte ptr [bx+1],0eh      ; je kl†vesa <BS> ?
         je        delpref1                 ; je kl†vesa <BS>
         cmp       byte ptr [bx+1],53h      ; je kl†vesa <Delete> ?
         jne       delpref2                 ; nebyla kl†vesa <Delete>
delpref1:and       byte ptr cs:[switch],7fh ; zru®en° p©°znaku prefixu
         mov       ds:[1ch],bx              ; zru®en° kl†vesy
         clc                                ; p©°znak - operace OK
         ret

delpref2:stc                                ; p©°znak - nen° zru®en° prefixu
         ret
; -----------------------------------------------------------------------------
prefix:                                     ; obsluha prefixovÇ kl†vesy
                                            ; VùSTUP: CY=funkce neprovedena

         cmp       byte ptr ds:[bx+1],36h   ; maxim†ln° povolenò znak
         ja        prefix3                  ; nen° povolen† kl†vesa
         mov       al,cs:[switch]
         and       al,7                     ; á°slo kl†vesnice
         mov       dx,cs:[prefkey1]         ; prefixy norm†ln° kl†vesnice
         cmp       al,3                     ; je kl†vesnice 3 ?
         jne       prefix0                  ; nen° kl†vesnice 3
         mov       dx,cs:[prefkey2]         ; prefixy p°sa©skÇ kl†vesnice
prefix0: mov       si,offset tab003         ; á†rka
         cmp       byte ptr ds:[bx],dl      ; je prefix ` (á†rka vlevo) ?
         je        prefix1                  ; je prefix `
         cmp       byte ptr [bx],dh         ; je prefix ' (á†rka vpravo) ?
         jne       prefix3                  ; nen° ani prefix '
         mov       si,offset tab004         ; h†áek
prefix1: cmp       dh,dl
         jne       prefix11                 ; nen° optim†ln° kl†vesnice
         mov       si,offset tab001         ; áesk† optim†ln°
         test      byte ptr cs:[switchk],4  ; sloven®tina ?
         jz        prefix11                 ; áe®tina
         mov       si,offset tab002         ; slovensk† optim†ln°
prefix11:mov       cx,offset(tab002-tab001) ; poáet poloëek

         push      di
         push      ax
         mov       di,offset tab0+1
prefix12:mov       al,cs:[si]
         mov       cs:[di],al
         inc       si
         add       di,2
         loop      prefix12
         pop       ax
         pop       di

         test      byte ptr cs:[switch],80h ; byl jië nàkterò prefix ?
         jnz       prefix2                  ; byl jië nàkterò prefix
         or        byte ptr cs:[switch],80h ; nastaven° prefixu ` nebo '
         mov       word ptr ds:[1ch],bx     ; zru®en° kl†vesy z bufferu
         clc                                ; p©°znak - operace provedena OK
         ret

prefix2: and       byte ptr cs:[switch],7fh ; zru®en° obou prefixñ
         stc                                ; operace OK, ale moënÇ p©ek¢dov†n°
         ret

prefix3: stc                                ; p©°znak - nen° prefixov† kl†vesa
         ret
; -----------------------------------------------------------------------------
prepinac:                                   ; p©ep°naá funkc° kl†vesnice

         test      byte ptr cs:[switch],80h ; byl zad†n prefix ?
         jz        prepin9                  ; nebyl ë†dnò prefix
         mov       al,[bx]                  ; p©ijatò k¢d kl†vesy - ASCII
         sub       al,"0"                   ; je znak men®° neë "0" ?
         jc        prepin9                  ; nen° znak p©ep°naáe
         jnz       prepin1                  ; nen° znak "0"
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
         and       byte ptr cs:[switch],4fh ; reset p©°znaku stm°v†n°
         jmp       short prepin80           ; n†vrat z obsluhy
prepin1: cmp       al,9                     ; je znak "9" ?
         jne       prepin2                  ; nen° znak "9"
         and       byte ptr cs:[switch],7fh ; reset p©°znaku prefixu
         or        byte ptr cs:[switch],10h ; zapnut° funkce stm°v†n°
         jmp       short prepin80           ; n†vrat z obsluhy
prepin2: cmp       al,8                     ; je znak "8" ?
         jne       prepin3                  ; nen° znak "8"
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
         and       byte ptr cs:[switch],7fh ; reset p©°znaku prefixu
         or        byte ptr cs:[switch],30h ; zapnut° stm°v†n°
         mov       word ptr cs:[count],2    ; citac vypnuti
prepin80:jmp       short prepin8            ; n†vrat z obsluhy

prepin9: stc                                ; p©°znak - nen° znak p©ep°naáe
         ret

prepin3: cmp       al,7                     ; je znak "7" ?
         ja        prepin9                  ; nen° p©ep°naá kl†vesnice
         and       byte ptr cs:[switch],78h ; nulov†n° á°sla kl†vesnice
         or        byte ptr cs:[switch],al  ; nastaven° novÇho á°sla kl†vesnice
prepin8: mov       word ptr ds:[1ch],bx     ; zru®en° kl†vesy z bufferu
         clc                                ; p©°znak - operace provedena OK
         ret
; -----------------------------------------------------------------------------
prekod:                                     ; p©ek¢dov†n° k¢du kl†vesy

         mov       al,cs:[switch]           ; p©ep°naáe
         and       al,7
         cmp       al,3                     ; je p°sa©sk† kl†vesnice ?
         jne       prekod06                 ; nen° p°sa©sk† kl†vesnice
                                          ;* p©ek¢dov†n° Z a Y
         mov       ax,ds:[bx]               ; p©ijat† kl†vesa
         cmp       ah,2ch                   ; je kl†vesa "Z" ?
         je        prekod03                 ; je kl†vesa "Z"
         cmp       ah,15h                   ; je kl†vesa "Y" ?
         jne       prekod06                 ; nen° kl†vesa "Y"
prekod03:xor       word ptr ds:[bx],2c1ah XOR 1519h ; zmàna kl†vesy Y <-> Z

prekod06:xor       ax,ax                    ; AX <- 0000
         mov       al,cs:[switch]           ; p©ep°naá kl†vesnice
         test      al,80h                   ; byl zad†n prefix ?
         jz        prekod1                  ; nebyl zad†n ë†dnò prefix
         and       byte ptr cs:[switch],7fh ; nulov†n° p©°znakñ prefixñ
         xor       al,al                    ; á°slo 0 = prefixov† kl†vesnice
prekod1: mov       si,offset adrtab1        ; tab. adres s vypnutòm <Caps Lock>
         test      byte ptr ds:[17h],40h    ; je zapnut <Caps Lock> ?
         jz        prekod2                  ; <Caps Lock> je vypnut
         mov       si,offset adrtab2        ; tab. adres se zapnutòm <Caps Lock>
prekod2: and       al,7                     ; ponech† á°slo kl†vesnice
         add       si,ax
         add       si,ax                    ; poloëka adresy tabulky
         mov       si,cs:[si]               ; adresa k¢dovac° tabulky
         or        si,si                    ; je kl†vesnice definovan† ?
         jz        prekod5                  ; kl†vesnice nen° definovan†
prekod21:xor       cx,cx                    ; CX <- 0000
         mov       cl,cs:[si]               ; poáet k¢dñ kl†ves v tabulce
         mov       dl,cl                    ; £schova p©°znaku 2-bajtovÇho k¢du
         and       cl,7fh                   ; zru®en° p©°znaku 2-bajtovòch k¢dñ
         jcxz      prekod8                  ; nen° ë†dnò k¢d v tabulce
         inc       si                       ; zaá†tek tabulky
         mov       ax,[bx]                  ; hledanò k¢d kl†vesy
prekod3: inc       si
         test      dl,80h                   ; je 2-bajtovò k¢d ?
         jz        prekod6                  ; je 1-bajtovò k¢d
         inc       si
         cmp       ax,cs:[si-2]             ; test, zda je hledanò k¢d kl†vesy
         jne       prekod7                  ; nen° hledanò k¢d kl†vesy
prekod4: xor       ax,ax                    ; AX <- 0000
         mov       al,cs:[si]               ; novò k¢d znaku
         mov       [bx],ax                  ; n†hrada novòm znakem
prekod5: clc                                ; p©°znak - p©ek¢dov†n° OK
         ret
prekod6: cmp       al,cs:[si-1]             ; test, zda je hledanò znak
         je        prekod4                  ; je hledanò znak
prekod7: inc       si                       ; p©eskoáen° novÇho k¢du znaku
         loop      prekod3                  ; test dal®°ho k¢du kl†vesy
         jmp       short prekod21           ; dal®° á†st tabulky
prekod8: stc                                ; p©°znak - k¢d kl†vesy nenalezen
         ret
; -----------------------------------------------------------------------------
inskey:                                     ; vloëen° znaku AX do bufferu
         push      bx                       ; ukazatel naposledy vloëenÇho znaku
         mov       bx,word ptr ds:[1ch]     ; ukazatel pro uloëen° dal®°ho znaku
         push      bx                       ; ukazatel novà uloëenÇho znaku
         inc       bx
         inc       bx                       ; zvò®en° pozice
         cmp       bx,3eh                   ; je p©ekroáen° konce bufferu ?
         jc        insk1                    ; nen°
         mov       bx,1eh                   ; zaá†tek bufferu
insk1:   cmp       bx,word ptr ds:[1ah]     ; ukazatel pro áten° znaku
         jz        insk2                    ; nen° volnÇ m°sto v bufferu
         mov       word ptr ds:[1ch],bx     ; novò ukazatel
         pop       bx                       ; ukazatel novà uloëenÇho znaku
         mov       ds:[bx],ax               ; uloëen° znaku
         add       sp,2                     ; zruseni ukazatele BX
         clc                                ; p©°znak - znak uloëen OK
         ret

insk2:   pop       bx                       ; n†vrat ukazatele znakñ
         pop       bx                       ; pñvodn° ukazatel bufferu
         stc                                ; p©°znak - nen° volnÇ m°sto
         ret

; *****************************************************************************
;
;                    Obsluha p©eru®en° od systÇmovòch hodin
;
; *****************************************************************************
int08:                                      ; obsluha systÇmovòch hodin


         pushf
         call      dword ptr cs:[old08]     ; obsluha áasovaáe INT 08h
         test      byte ptr cs:[parint],51h ; je moënÇ obslouëit displej ?
         jnz       int083                   ; nen° moënÇ provÇst obsluhu
         or        byte ptr cs:[parint],50h ; nastaven° p©°znaku obsluhy displ.
         call      displ                    ; obsluha ztmaven° displeje
         and       byte ptr cs:[parint],0bfh; zru®en° p©°znaku obsluhy displeje
int083:  test      byte ptr cs:[switch],10h ; je funkce stm°v†n° ?
         jz        int082                   ; nen° funkce stm°v†n°
         cmp       word ptr cs:[count],0    ; je jië dosaëeno 0 ?
         jne       int081                   ; nen° je®tà dosaëeno 0
         or        byte ptr cs:[switch],20h ; p©°znak - displej m† bòt ztmavnut
         mov       word ptr cs:[count],2    ; konstanta pro opakovanÇ stm°v†n°
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
int081:  dec       word ptr cs:[count]      ; sn°ëen° á°taáe stm°v†n°
int082:  iret

; *****************************************************************************
;
;                             Monitorov†n° p©eru®en°
;
; *****************************************************************************

int10:                                      ; obsluha p©eru®en° INT 10h
         or        byte ptr cs:[parint],1   ; nastaven° p©°znaku obsluhy INT 10h
         pushf
         call      dword ptr cs:[old10]     ; vol†n° pñvodn° obsluhy INT 10h
         pushf                              ; £schova registru p©°znakñ
         and       byte ptr cs:[parint],0feh; nulov†n° p©°znaku obsluhy INT 10h

intret:                                   ;* (v z†sobn°ku je registr p©°znakñ)
         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP
         push      ax                       ; £schova AX
         mov       ax,ss:[bp+2]             ; novò registr p©°znakñ
         and       ax,41h                   ; ponech†n° p©°znakñ ZF a CF
         and       word ptr ss:[bp+8],not 41h ; zru®en° pñvodn°ho ZF a CF
         or        ss:[bp+8],ax             ; novÇ p©°znaky ZF a CF
         pop       ax                       ; n†vrat AX
         pop       bp                       ; n†vrat BP
         popf                               ; n†vrat registru p©°znakñ
         IRET


int16:                                      ; obsluha p©eru®en° INT 16h

         pushf
         cmp       ax,173h                  ; prvn° identifikaán° slovo
         jne       Int160
         cmp       bx,8951h                 ; druhÇ identifikaán° slovo
         jne       Int160

         push      ds
         push      es
         push      si
         push      di
         push      cx

         push      cs
         pop       ds
         mov       si,offset Ident
         mov       di,si
         mov       cx,offset(Ident0-Ident)
         cld
         repe      cmpsb

         pop       cx
         pop       di
         pop       si
         pop       es
         pop       ds
         jne       Int160

         push      cs
         pop       es
         jmp       short intret


Int160:  popf

         or        byte ptr cs:[parint],4   ; nastaven° p©°znaku obsluhy INT 16h
         test      byte ptr cs:[parint],51h ; je moënÇ obslouëit displej ?
         jnz       int161                   ; nen° moënÇ provÇst obsluhu
         or        byte ptr cs:[parint],50h ; nastaven° p©°znaku obsluhy displ.
         call      displ                    ; obsluha ztmaven° displeje
         and       byte ptr cs:[parint],0bfh; zru®en° p©°znaku obsluhy displeje
int161:  pushf
         call      dword ptr cs:[old16]     ; vol†n° pñvodn° obsluhy INT 16h
         pushf                              ; £schova registru p©°znakñ
         and       byte ptr cs:[parint],0fbh; nulov†n° p©°znaku obsluhy INT 16h
         jmp       short intret             ; n†vrat z p©eru®en°


displ:                                      ; obsluha ztmaven° displeje
         push      ax                       ; £schova AX
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es
         push      bp
         push      cs
         pop       es
         test      byte ptr cs:[switch],20h ; m† bòt displej ztmaven ?
         jnz       dispoff                  ; displej m† bòt ztmaven
dispon:                                   ;* displej m† bòt rozsv°cen
         test      byte ptr cs:[parint],80h ; je displej jië rozsv°cen ?
         jz        dispret                  ; displej je jië rozsv°cen
         and       byte ptr cs:[parint],7fh ; nastaven° p©°znaku rozsv°cen°
         mov       al,cs:[typdisp]          ; typ displeje
         or        al,al                    ; je zn†mò typ displeje ?
         jz        dispret                  ; je nezn†mò typ displeje
         dec       al                       ; je grafick† karta CGA ?
         jnz       disp10                   ; nen° grafick† karta CGA
         call      cgaon                    ; zapnut° displeje CGA
         jmp       short dispret            ; n†vrat z obsluhy
disp10:  dec       al                       ; je grafick† karta MDA ?
         jnz       disp11                   ; nen° grafick† karta MDA
         call      mdaon                    ; zapnut° displeje MDA
         jmp       short dispret            ; n†vrat z obsluhy
disp11:  dec       al                       ; je grafick† karta EGA ?
         jnz       dispret                  ; nen° grafick† karta EGA
         call      egaon                    ; zapnut° displeje EGA
         jmp       short dispret            ; n†vrat z obsluhy

                                          ;* displej m† bòt vypnut
dispoff:
         or        byte ptr cs:[parint],80h ; nastaven° p©°znaku ztmaven°
         mov       al,cs:[typdisp]          ; typ displeje
         or        al,al                    ; je zn†mò typ displeje ?
         jz        dispret                  ; je nezn†mò typ displeje
         dec       al                       ; je grafick† karta CGA ?
         jnz       disp20                   ; nen° grafick† karta CGA
         call      cgaoff                   ; vypnut° displeje CGA
         jmp       short dispret            ; n†vrat z obsluhy
disp20:  dec       al                       ; je grafick† karta MDA ?
         jnz       disp21                   ; nen° grafick† karta MDA
         call      mdaoff                   ; vypnut° displeje MDA
         jmp       short dispret            ; n†vrat z obsluhy
disp21:  dec       al                       ; je grafick† karta EGA ?
         jnz       dispret                  ; nen° grafick† karta EGA
         call      egaoff                   ; vypnut° displeje EGA

dispret: pop       bp
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


egaon:                                    ;* zapnut° karty EGA
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; b†zov† ©°dic° adresa displeje
         and       dl,0f0h                  ; z†klad ©°dic° adresy
         or        dl,0ah                   ; adresa stavovÇho registru displeje
         in        al,dx                    ; synchonizace ©°dic°ho registru
         mov       dl,0c0h                  ; port ©adiáe EGA
         mov       al,31h                   ; registr barvy okol°
         out       dx,al                    ; volba registru okol°
         xor       al,al                    ; 0=barva áern†
         out       dx,al                    ; nastaven° okol° na áernou
         mov       al,ds:[465h]             ; souáasnÇ nastaven° registru m¢du
         or        al,8                     ; nastaven° p©°znaku zapnut° disp.
         mov       ds:[465h],al             ; uloëen° novÇ hodnoty registru m¢du
         ret

egaoff:                                   ;* vypnut° karty EGA
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; b†zov† ©°dic° adresa displeje
         and       dl,0f0h                  ; z†klad ©°dic° adresy
         or        dl,0ah                   ; adresa stavovÇho registru displeje
         in        al,dx                    ; synchonizace ©°dic°ho registru
         mov       dl,0c0h                  ; port ©adiáe EGA
         mov       al,11h                   ; registr barvy okol°
         out       dx,al                    ; volba registru okol°
         xor       al,al                    ; barva áern†
         out       dx,al                    ; nastaven° okol° na áernou
         mov       al,ds:[465h]             ; souáasnÇ nastaven° registru m¢du
         and       al,0f7h                  ; nastaven° p©°znaku vypnut° disp.
         mov       ds:[465h],al             ; uloëen° novÇ hodnoty registru m¢du
         ret

mdaon:                                    ;* zapnut° displeje MDA
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; adresa ©°dic°ho registru MDA
         call      radmda                   ; zji®tàn° poátu ©†dkñ MDA
         mov       al,6                     ; registr 6 = poáet vert. ©†dkñ
         out       dx,al                    ; nastaven° registru 6
         inc       dx                       ; data registru 6
         mov       al,ah                    ; poáet ©†dkñ displeje
         out       dx,al                    ; nastaven° poátu ©†dkñ displeje
         mov       al,ds:[465h]             ; souáasnÇ nastaven° registru m¢du
         or        al,8                     ; nastaven° p©°znaku zapnut° disp.
         mov       ds:[465h],al             ; uloëen° novÇ hodnoty registru m¢du
         ret

mdaoff:                                   ;* vypnut° displeje MDA
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; ©°dic° registr videokarty
         mov       al,6                     ; registr 6 = poáet vert. ©†dkñ
         out       dx,al                    ; nastaven° registru 6
         inc       dx                       ; data registru 6
         xor       al,al                    ; poáet ©†dkñ displeje = 0
         out       dx,al                    ; nastaven° poátu ©†dkñ na 0
         mov       al,ds:[465h]             ; souáasnÇ nastaven° registru m¢du
         and       al,not 8                 ; nastaven° p©°znaku vypnut° disp.
         mov       ds:[465h],al             ; uloëen° novÇ hodnoty
         ret

cgaon:                                    ;* zapnut° karty CGA
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; adresa ©°dic°ho registru displeje
         add       dx,4                     ; registr m¢du
         mov       al,ds:[465h]             ; souáasnÇ nastaven° registr m¢du
         or        al,8                     ; nastaven° bitu 3 (je vòstup)
         out       dx,al                    ; zapnut° displeje
         mov       ds:[465h],al             ; uloëen° novÇ hodnoty
         ret


cgaoff:                                   ;* vypnut° karty CGA
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; adresa ©°dic°ho registru displeje
         add       dx,4                     ; registr m¢du
         mov       al,ds:[465h]             ; souáasnÇ nastaven° m¢du
         and       al,0f7h                  ; nulov†n° bitu 3
         out       dx,al                    ; vypnut° displeje
         mov       ds:[465h],al             ; uloëen° novÇ hodnoty
         ret

radmda:                                   ;* zji®tàn° poátu ©†dkñ MDA
                                          ;* VSTUP: DX=adresa ©°dic°ho registru
                                          ;* VùSTUP: AH=poáet ©†dkñ displeje
         push      dx
         and       dl,0f0h                  ; z†kladn° adresa karty MDA
         or        dl,0ah                   ; stavovò registr video©adiáe
radmda1: in        al,dx                    ; áten° stavovÇho registru karty MDA
         test      al,80h                   ; prob°h† synchroimpuls ?
         jz        radmda1                  ; áek†n° na ukonáen° synchroimpulsu
radmda2: in        al,dx                    ; áten° stavovÇho registru karty MDA
         test      al,80h                   ; prob°h† synchroimpuls ?
         jnz       radmda2                  ; áek†n° na zaá†tek synchroimpulsu
         pop       dx
         push      dx                       ; £schova adresy registru
         and       dl,0f0h                  ; z†kladn° adresa karty MDA
         or        dl,0bh                   ; registr svàtelnÇho pera
         xor       al,al                    ; AL <- 00
         out       dx,al                    ; vymaz†n° registru svàtelnÇho pera
         and       dl,0f0h                  ; z†kladn° adresa karty MDA
         or        dl,9                     ; alternativn° adresa
         out       dx,al                    ; vymaz†n° registru svàtelnÇho pera
         pop       dx                       ; n†vrat adresy registru
         mov       al,10h                   ; registr svàtelnÇho pera HIGH
         out       dx,al                    ; nastaven° registru 10h
         inc       dx                       ; data registru 10h
         in        al,dx                    ; áten° vy®®° adresy svàtelnÇho pera
         mov       bh,al                    ; £schova vy®®° adresy svàt. pera
         dec       dx                       ; adresa registru
         mov       al,11h                   ; registr svàtelnÇho pera LOW
         out       dx,al                    ; nastaven° registru 11h
         inc       dx                       ; data registru 11h
         in        al,dx                    ; áten° nië®° adresy svàtelnÇho pera
         mov       bl,al                    ; £schova nië®° adresy svàt. pera
         dec       dx                       ; n†vrat adresy registru
         mov       ah,25                    ; poáet ©†dkñ = 25
         cmp       bx,0b8dh                 ; je max. pozice pera 2957 ?
         jb        radmda3                  ; je men®° poáet pozic
         mov       ah,87                    ; poáet ©†dkñ = 87
radmda3: ret

; *****************************************************************************
;
;                                 Tabulky znakñ
;
; *****************************************************************************
                                          ;* <Caps Lock> je vypnut
adrtab1  dw        offset tab0              ; 0:tabulka po prefixu
         dw        0                        ; 1:pñvodn° kl†vesnice IBM
         dw        offset tab21             ; 2:program†torsk† kl†vesnice mal†
         dw        offset tab31             ; 3:p°sa©sk† kl†vesnice mal†
         dw        offset tab4              ; 4:grafick† kl†vesnice 1
         dw        offset tab5              ; 5:grafick† kl†vesnice 2
         dw        offset tab6              ; 6:grafick† kl†vesnice 3
         dw        offset tab7              ; 7:grafick† kl†vesnice 4

                                          ;* <Caps Lock> je zapnut
adrtab2  dw        offset tab0              ; 0:tabulka po prefixu
         dw        0                        ; 1:pñvodn° kl†vesnice IBM
         dw        offset tab22             ; 2:program†torsk† kl†vesnice velk†
         dw        offset tab32             ; 3:p°sa©sk† kl†vesnice velk†
         dw        offset tab4              ; 4:grafick† kl†vesnice 1
         dw        offset tab5              ; 5:grafick† kl†vesnice 2
         dw        offset tab6              ; 6:grafick† kl†vesnice 3
         dw        offset tab7              ; 7:grafick† kl†vesnice 4

tab001   db        'bBqQwWeErRtTyYuUiIoOpPaAsSdDfFhHjJkKlLzZcCnNmM,.\' ; optim.á
tab002   db        'bBqQwWeEfFtTyYuUiIoOpPaAsSdDrRhHjJkKlLzZcCnNmM,.\' ; optim.s
tab003   db        'bBqQwWeEfFtTyYuUiIoOpPaAsSdDrRhHjJkKmMzZcCnNlL,.\' ; á†rka
tab004   db        'bBqQeEwWrRtTyYjJiIkKpPaAsSdDfFhHuUoOlLzZcCnNmM,.\' ; h†áek

tab00    label     byte                   ;* adresa zaá†tku tabulek

tab0     db        49                    ;* tabulka po prefixu
         db        "b·"                     ; "·"
         db        "B·"                     ; "·"
         db        "qÑ"                     ; "Ñ"
         db        "Qé"                     ; "é"
         db        "wà"                     ; "à"
         db        "Wâ"                     ; "â"
         db        "eÇ"                     ; "Ç"
         db        "Eê"                     ; "ê"
         db        "r©"                     ; "©"
         db        "Rû"                     ; "û"
         db        "tü"                     ; "ü"
         db        "TÜ"                     ; "Ü"
         db        "yò"                     ; "ò"
         db        "Yù"                     ; "ù"
         db        "u£"                     ; "£"
         db        "Uó"                     ; "ó"
         db        "i°"                     ; "°"
         db        "Iã"                     ; "ã"
         db        "o¢"                     ; "¢"
         db        "Oï"                     ; "ï"
         db        "pî"                     ; "î"
         db        "Pô"                     ; "ô"
         db        "a†"                     ; "†"
         db        "Aè"                     ; "è"
         db        "s®"                     ; "®"
         db        "Sõ"                     ; "õ"
         db        "dÉ"                     ; "É"
         db        "DÖ"                     ; "Ö"
         db        "f™"                     ; "™"
         db        "F´"                     ; "´"
         db        "hÅ"                     ; "Å"
         db        "Hö"                     ; "ö"
         db        "jñ"                     ; "ñ"
         db        "J¶"                     ; "¶"
         db        "kì"                     ; "ì"
         db        "Kß"                     ; "ß"
         db        "lå"                     ; "å"
         db        "Lú"                     ; "ú"
         db        "zë"                     ; "ë"
         db        "Zí"                     ; "í"
         db        "cá"                     ; "á"
         db        "CÄ"                     ; "Ä"
         db        "n§"                     ; "§"
         db        "N•"                     ; "•"
         db        "mç"                     ; "ç"
         db        "Mä"                     ; "ä"
         db        ",Æ"                     ; "Æ"
         db        ".Ø"                     ; "Ø"
         db        "\≠"                     ; "≠"
         db        0

tab21    db        10+128                 ;* program†torsk† kl†vesnice mal†
         db        31h,2,150                ; "ñ"
         db        32h,3,136                ; "à"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,169                ; "©"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

tab22    db        10+128                 ;* program†torsk† kl†vesnice velk†
         db        31h,2,166                ; "¶"
         db        32h,3,137                ; "â"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,158                ; "û"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

tab31    db        14+128                 ;* p°sa©sk† kl†vesnice mal†
         db        31h,2,"+"                ; "+"
         db        32h,3,136                ; "à"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,169                ; "©"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";ñ"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

tab32    db        14+128                 ;* p°sa©sk† kl†vesnice velk†
         db        31h,2,"+"                ; "+"
         db        32h,3,137                ; "â"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,158                ; "û"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";¶"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

tab4     db        15+128                 ;* grafick† kl†vesnice 1
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

tab5     db        15+128                 ;* grafick† kl†vesnice 2
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


tab6     db        15+128                 ;* grafick† kl†vesnice 3
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        212                      ; "‘"
         dw        5032h                    ; [2]
         db        207                      ; "œ"
         dw        5133h                    ; [3]
         db        190                      ; "æ"
         dw        4b34h                    ; [4]
         db        198                      ; "∆"
         dw        4c35h                    ; [5]
         db        216                      ; "ÿ"
         dw        4d36h                    ; [6]
         db        181                      ; "µ"
         dw        4737h                    ; [7]
         db        213                      ; "’"
         dw        4838h                    ; [8]
         db        209                      ; "—"
         dw        4939h                    ; [9]
         db        184                      ; "∏"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0                        

tab7     db        15+128                 ;* grafick† kl†vesnice 4
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        211                      ; "”"
         dw        5032h                    ; [2]
         db        208                      ; "–"
         dw        5133h                    ; [3]
         db        189                      ; "Ω"
         dw        4b34h                    ; [4]
         db        199                      ; "«"
         dw        4c35h                    ; [5]
         db        215                      ; "◊"
         dw        4d36h                    ; [6]
         db        182                      ; "∂"
         dw        4737h                    ; [7]
         db        214                      ; "÷"
         dw        4838h                    ; [8]
         db        210                      ; "“"
         dw        4939h                    ; [9]
         db        183                      ; "∑"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; zde je konec rezidentn° á†sti programu

; *****************************************************************************
;
;                        Instalace programu
;
; *****************************************************************************
init:                                     ;* nalezen° rezidentn°ho programu

         push      cs
         pop       es
         mov       ax,173h
         mov       bx,8951h
         int       16h                      ; poskytnut° segmentu rez. á†sti

init2:                                    ;* nastaven° parametrñ z p©°kaz. ©†dku
         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; poáet znakñ p©°kazovÇho ©†dku
init3:   jcxz      init32                   ; nen° dal®° parametr
         call      dekpar                   ; dek¢dov†n° parametru
         mov       dx,offset texthlp        ; text n†povàdy
         jc        init4                    ; chyba zadani parametru - napoveda
         jmp       short init3              ; dekodovani dalsiho parametru
init32:                                   ;* instalace nebo ukonáen° programu
         mov       bx,cs                    ; segment tohoto programu
         mov       ax,es                    ; segment nainstalovanÇho programu
         cmp       ax,bx                    ; je program nainstalov†n ?
         je        init5                    ; program nen° nainstalov†n
                                          ;* hlaseni o zmene parametru
         mov       dx,offset textjein       ; hlaseni, ze je jiz nainstalovan
         cmp       byte ptr ds:[citpar],0   ; byl zadan nejaky parametr ?
         je        init4                    ; neni zadan zadny parametr
         mov       dx,offset textset        ; hlaseni o nastaveni parametru
init4:   call      sethelp                  ; nastaveni textu napovedy
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn°ho textu
         mov       ax,4c00h                 ; funkce n†vratu z programu
         int       21h                      ; ukonáen° programu

init5:                                    ;* instalace programu do pamàti

                                          ;* uvolneni segmentu prostredi
         mov       es,cs:[2ch]              ; segment prostredi
         mov       ah,49h
         int       21h                      ; uvolneni segmentu prostredi

         call      testdis                  ; test grafickÇ karty
                                          ;* £schova adres vektorñ p©eru®en°
         mov       ax,3508h                 ; p©eáten° vektoru p©eru®en° 08h
         int       21h
         mov       word ptr [old08],bx      ; uloëen° pñvodn°ho vekt. p©eru®en°
         mov       word ptr [old08+2],es    ; segment nad©azenÇ instalace
         mov       ax,3509h                 ; p©eáten° vektoru p©eru®en° 09h
         int       21h
         mov       word ptr [old09],bx      ; uloëen° pñvodn°ho vekt. p©eru®en°
         mov       word ptr [old09+2],es    ; segment nad©azenÇ instalace
         mov       ax,3510h                 ; p©eáten° vektoru p©eru®en° 10h
         int       21h
         mov       word ptr [old10],bx      ; uloëen° pñvodn°ho vekt. p©eru®en°
         mov       word ptr [old10+2],es    ; segment nad©azenÇ instalace
         mov       ax,3516h                 ; p©eáten° vektoru p©eru®en° 16h
         int       21h
         mov       word ptr [old16],bx      ; uloëen° pñvodn°ho vekt. p©eru®en°
         mov       word ptr [old16+2],es    ; segment nad©azenÇ instalace
                                          ;* nastaven° vektorñ p©eru®en°
         cli                                ; zakaz preruseni
         mov       dx,offset int08          ; adresa vlastn° obsluhy INT 08h
         mov       ax,2508h
         int       21h                      ; nastaven° novÇ adresy INT 08H
         mov       dx,offset int09          ; adresa vlastn° obsluhy INT 09h
         mov       ax,2509h
         int       21h                      ; nastaven° novÇ adresy INT 09H
         mov       dx,offset int10          ; adresa vlastn° obsluhy INT 10h
         mov       ax,2510h
         int       21h                      ; nastaven° novÇ adresy INT 10H
         mov       dx,offset int16          ; adresa vlastn° obsluhy INT 16h
         mov       ax,2516h
         int       21h                      ; nastaven° novÇ adresy INT 16H
         sti                                ; povoleni preruseni
                                          ;* instalace programu do pamàti
         push      cs
         pop       es                       ; ES <- CS
         mov       dx,offset textins        ; hl†®en° o instalaci programu
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn°ho textu
         mov       dx,offset init           ; konec rezidentn° á†sti
         int       27h                      ; instalace do pamàti

; ------------------------ instalace ztmavovani displeje ----------------------
testdis:                                  ;* test (rozpozn†n°) videokarty
         mov       ah,12h                   ; funkce alternativ. nastaven° EGA
         mov       bl,10h                   ; podsluëba - informace o EGA
         int       10h                      ; poskytnut° informac° o EGA
         cmp       bl,10h                   ; funkce nen° podporov†na ?
         je        testdis1                 ; funkce nen° podporov†na (nen° EGA)
         mov       byte ptr ds:[typdisp],3  ; je grafick† karta EGA
         ret
testdis1:mov       ah,0fh                   ; funkce dotazu na videom¢d
         int       10h                      ; dotaz na aktivn° videom¢d
         cmp       al,7                     ; je textovò reëim MDA ?
         jne       testdis2                 ; nen° textovò reëim MDA - je CGA
         call      testmda                  ; test grafickÇ karty MDA
         jz        testdis2                 ; nen° grafick† karta MDA
         mov       byte ptr ds:[typdisp],2  ; je grafick† karta MDA
         ret
testdis2:mov       byte ptr ds:[typdisp],1  ; je grafick† karta CGA
         ret

testmda:                                  ;* test grafickÇ karty MDA
                                          ;* VùSTUP: ZY=nen° karta MDA
         push      ds                       ; £schova registru DS
         push      dx                       ; £schova registru DX
         push      cx                       ; £schova registru CX
         xor       ax,ax                    ; AX <- 0000
         mov       ds,ax                    ; DS <- 0000
         mov       dx,ds:[463h]             ; b†zov† ©°dic° adresa displeje
         and       dl,0f0h                  ; z†klad adresy
         or        dl,0ah                   ; adresa stavovÇho registru
         mov       cx,2000h                 ; maxim†ln° doba pro test impulsu
testmda1:in        al,dx                    ; vstup ze stavovÇho registru
         test      al,80h                   ; je synchronizaán° impuls MDA ?
         jz        testmda2                 ; p©i®el impuls - je karta MDA
         loop      testmda1                 ; dal®° áek†n° na impuls MDA
testmda2:or        cx,cx                    ; bylo p©eteáen° áekac° smyáky ?
         pop       cx                       ; n†vrat registru CX
         pop       dx                       ; n†vrat registru DX
         pop       ds                       ; n†vrat registru DS
         ret
; --------------------- dekodovani zadanych parametru -------------------------

readb:                                    ;* áten° znaku z p©°kaz. ©†dku
                                          ;* VùSTUP: CY=nen° dal®° znak
                                          ;*         ZY=je mezera nebo tabel†tor

         stc                                ; nastaven° p©°znaku chyby
         jcxz      readb2                   ; nen° jië dal®° znak
         lodsb                              ; naáten° znaku z p©°kaz. ©†dku
         cmp       al,"a"                   ; je malÇ p°smeno ?
         jb        readb0                   ; nen° malÇ p°smeno
         cmp       al,"z"                   ; je malÇ p°smeno ?
         ja        readb0                   ; nen° malÇ p°smeno
         sub       al,32                    ; korekce na velkÇ p°smeno
readb0:  dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "                   ; je mezera ?
         je        readb1                   ; je znak mezery
         cmp       al,","                   ; je oddàlovac° á†rka ?
         je        readb1                   ; je oddàlovac° á†rka
         cmp       al,9                     ; je tabel†tor ?
readb1:  clc                                ; p©°znak - operace OK
readb2:  ret

dekpar:                                   ;* dek¢dov†n° parametru
                                          ;* VùSTUP: CY = chyba parametru

         call      readb                    ; naáten° znaku z p©°kaz. ©†dku
         jbe       dekpar1                  ; nen° dal®° znak nebo je oddàlovaá
         cmp       al,"/"                   ; je £vodn° znak parametru ?
         je        dekpar2                  ; je £vodn° znak parametru
         stc                                ; p©°znak chyby
dekpar1: ret                                ; n†vrat s chybou
dekpar2: call      readb                    ; naáten° dal®°ho znaku
         jc        dekpar1                  ; nen° dal®° znak - chyba
         inc       byte ptr ds:[citpar]     ; zvò®en° á°taáe parametrñ
                                          ;* parametr /0
         cmp       al,"0"                   ; vypnut° funkce ztmavov†n° ?
         jne       dekpar3                  ; nen° vypnut° ztmavov†n°
         and       byte ptr es:[switch],0cfh; reset p©°znaku stm°v†n°
         and       byte ptr es:[parint],0efh; poëadavek na obsluhu displeje
         ret
                                          ;* parametr /9
dekpar3: cmp       al,"9"                   ; je zapnut° ztmavov†n°
         jne       dekpar4                  ; nen° zapnut° ztmavov†n°
         or        byte ptr es:[switch],10h ; zapnut° funkce sm°v†n°
         ret
                                          ;* parametr /8
dekpar4: cmp       al,"8"                   ; je nucenÇ ztmaven° displeje ?
         jne       dekpar5                  ; nen° nucenÇ ztmaven° displeje
         and       byte ptr es:[parint],0efh; poëadavek na obsluhu displeje
         or        byte ptr es:[switch],30h ; ztmaven° displeje
         mov       word ptr es:[count],4    ; citac ztmaveni displeje
         ret
                                          ;* prepinac klavesnice
dekpar5: cmp       al,"7"                   ; je k¢d p©ep°naáe kl†vesnice ?
         ja        dekpar8                  ; nen° k¢d p©ep°naáe kl†vesnice
         cmp       al,"1"                   ; je k¢d p©ep°naáe kl†vesnice ?
         jb        dekpar8                  ; nen° k¢d p©ep°naáe kl†vesnice
         sub       al,"0"                   ; korekce na á°slo kl†vesnice
         and       byte ptr es:[switch],0f8h; nulov†n° á°sla kl†vesnice
         or        byte ptr es:[switch],al  ; nastaven° novÇho á°sla kl†vesnice
         ret
                                          ;* parametr /+
dekpar8: cmp       al,"+"                   ; je zapnut° zvukovÇ signalizace ?
         jne       dekpar9                  ; nen° zapnut° zvukovÇ signalizace
         or        byte ptr es:[switch],40h ; zapnut° zvukovÇ signalizace
         ret
                                          ;* parametr /-
dekpar9: cmp       al,"-"                   ; je vypnut° zvukovÇ signalizace ?
         jne       dekpara                  ; nen° vypnut° zvukovÇ signalizace
         and       byte ptr es:[switch],0bfh; vypnut° zvukovÇ signalizace
         ret
                                          ;* parametr /P
dekpara: cmp       al,"P"                   ; je definice prefixovòch kl†ves ?
         jne       dekparb                  ; nen° definice prefix. kl†ves
         call      readb                    ; naáten° prvn°ho prefixu
         jbe       dekparx                  ; je oddàlovac° znak nebo nen° znak
         mov       byte ptr es:[prefkey1],al ; nastaven° prvn°ho prefixu
         call      readb                    ; naáten° druhÇho prefixu
         jbe       dekpary                  ; je oddàlovac° znak nebo nen° znak
         mov       byte ptr es:[prefkey1+1],al ; nastaven° druhÇho prefixu
         call      readb                    ; naáten° t©et°ho prefixu
         jbe       dekpary                  ; je oddàlovac° znak nebo nen° znak
         mov       byte ptr es:[prefkey2],al ; nastaven° t©et°ho prefixu
         call      readb                    ; naáten° átvrtÇho prefixu
         jbe       dekpary                  ; je oddàlovac° znak nebo nen° znak
         mov       byte ptr es:[prefkey2+1],al ; nastaven° átvrtÇho prefixu
         ret
                                          ;* parametr /H
dekparb: cmp       al,"H"                   ; je definice hlasitosti zvuku ?
         jne       dekparc                  ; nen° definice hlasitosti
         call      deknum                   ; dekodovani cisla parametru
         jc        dekparx                  ; chyba
         mov       es:[levs],al             ; nastaven° hlasitosti zvuku
         ret
                                          ;* parametr /R
dekparc: cmp       al,"R"                   ; je definice hlasitosti zvuku ?
         jne       dekpard                  ; nen° definice hlasitosti
         call      deknum                   ; dekodovani cisla parametru
         jc        dekparx                  ; chyba
         mov       es:[levr],al             ; nastaven° hlasitosti opakov†n°
         ret
                                          ;* chyba zadani parametru
dekparx: dec       byte ptr ds:[citpar]     ; navrat á°taáe parametrñ
         stc                                ; p©°znak - nepovolenò parametr
         ret
                                          ;* operace OK
dekpary: clc
         ret
                                          ;* parametr /T
dekpard: cmp       al,"T"                   ; je definice vò®ky t¢nu ?
         jne       dekpare                  ; nen° definice hlasitosti
         call      deknum                   ; dekodovani cisla parametru
         jc        dekparx                  ; chyba
         mov       es:[ton],al              ; nastaven° vò®ky t¢nu
         ret
                                          ;* parametr /D
dekpare: cmp       al,"D"                   ; je nastaven° doby ztmaven° ?
         jne       dekparg                  ; nen° nastaven° doby ztmaven°
         call      deknum                   ; dekodovani cisla parametru
         jc        dekparx                  ; chyba
         mov       es:[timech],al           ; á°slo nastaven° áasu
         or        al,al                    ; je 0 ?
         jnz       dekparf1
         mov       al,10                    ; je hodnota 10
dekparf1:xor       dx,dx
         xor       ah,ah
         mov       bx,1093
         mul       bx                       ; vòpoáet doby pro ztmaven°
         mov       es:[timeoff],ax          ; doba pro vypnut°
         mov       es:[count],ax            ; á°taá p©ed vypnut°m
         clc
         ret
                                          ;* parametr /K
dekparg: cmp       al,"K"
         jne       dekparh
         and       byte ptr es:[switchk],not 3
         call      konvk                    ; p©enos fontñ
         ret
                                          ;* parametr /L
dekparh: cmp       al,"L"
         jne       dekpari
         and       byte ptr es:[switchk],not 3
         or        byte ptr es:[switchk],1
         call      konvk                    ; p©enos fontñ
         ret
                                          ;* parametr /X
dekpari: cmp       al,"X"
         jne       dekparj
         and       byte ptr es:[switchk],not 3
         or        byte ptr es:[switchk],2
         call      konvk                    ; p©enos fontñ
         ret
                                          ;* parametr /C
dekparj:
         cmp       al,"C"
         jne       dekpark
         and       byte ptr es:[switchk],not 4
         call      konvk                    ; p©enos fontñ
         ret
                                          ;* parametr /S
dekpark: cmp       al,"S"
         jne       dekparl
         or        byte ptr es:[switchk],4
         call      konvk                    ; p©enos fontñ
         ret



dekparm:
dekparz:
         stc
         ret

                                          ;* parametr /! - odinstalovani
dekparl: cmp       al,"!"
         jne       dekparm


                                          ;* kontrola, zda lze odinstalovat
         mov       cx,es                    ; segment rezidentni casti
         mov       ax,cs
         cmp       ax,cx
         mov       dx,offset textzins
         je        dekparl6                 ; neni nainstalovan

         mov       ax,3508h                 ; p©eáten° vektoru p©eru®en° 08h
         int       21h
         mov       ax,es
         cmp       ax,cx
         jne       dekparl2
         mov       ax,3509h                 ; p©eáten° vektoru p©eru®en° 09h
         int       21h
         mov       ax,es
         cmp       ax,cx
         jne       dekparl2
         mov       ax,3510h                 ; p©eáten° vektoru p©eru®en° 10h
         int       21h
         mov       ax,es
         cmp       ax,cx
         jne       dekparl2
         mov       ax,3516h                 ; p©eáten° vektoru p©eru®en° 16h
         int       21h
         mov       ax,es
         cmp       ax,cx
         jne       dekparl2

                                         ;* nastaveni puvodnich vektoru
         mov       dx,word ptr es:[old08]
         mov       ds,word ptr es:[old08+2]
         mov       ax,2508h
         int       21h                      ; nastaven° novÇ adresy INT 08H
         mov       dx,word ptr es:[old09]
         mov       ds,word ptr es:[old09+2]
         mov       ax,2509h
         int       21h                      ; nastaven° novÇ adresy INT 09H
         mov       dx,word ptr es:[old10]
         mov       ds,word ptr es:[old10+2]
         mov       ax,2510h
         int       21h                      ; nastaven° novÇ adresy INT 10H
         mov       dx,word ptr es:[old16]
         mov       ds,word ptr es:[old16+2]
         mov       ax,2516h
         int       21h                      ; nastaven° novÇ adresy INT 16H

                                          ;* uvolneni segmentu
         mov       ah,49h
         int       21h                      ; uvolneni pameti

                                          ;* uspesne odinstalovan
         mov       dx,offset textdins
         jmp       short dekparl6
                                          ;* nelze odinstalovat
dekparl2:mov       dx,offset textnins
dekparl6:mov       ah,9
         push      cs
         pop       ds
         int       21h
         mov       ax,4c00h
         int       21h


deknum:                                   ;* dekodovani cislice
         call      readb                    ; naáten° á°slice definice
         jbe       deknum1                  ; chyba
         sub       al,"0"                   ; je á°slice ?
         jc        deknum1                  ; nen° á°slice
         cmp       al,10                    ; je platn† á°slice ?
         cmc
         ja        deknum2                  ; nen° platn† á°slice
deknum1: stc
deknum2: ret

konvk:                                    ;* konverze kl†vesnice
                                            ; VSTUP: ES=segment rezidentn° CSKEY
         push      cx
         push      di
         push      si
         mov       si,word ptr es:[switchk] ; k¢d kl†vesnice
         and       si,7
         add       si,si
         mov       si,ds:[si+adrkod]        ; tabulka k¢dñ - adresa k¢du
         mov       di,offset tab00          ; adresa zaá†tku tabulek
         mov       cx,offset(init-tab00)    ; dÇlka tabulky
         cld
         rep       movsb                    ; p©enos tabulky
         pop       si
         pop       di
         pop       cx
         ret

; --------------------------- inicializace textu napovedy ---------------------
sethelp:                                  ;* inicializace textu napovedy
                                            ; VSTUP: ES=segment s parametry
                                            ;        DS=segment s textem

         push      ax
         push      bx
         push      di
         push      ds
         push      es
         pop       ds
         pop       es
         mov       di,offset textsetp + 29  ; zacatek parametru v textu
                                          ;* typ klavesnice
         mov       ah,ds:[switch]
         and       ah,7                     ; typ klavesnice
         add       ah,"0"                   ; znak typu klavesnice
         mov       al,"/"
         stosw
                                          ;* kod cestiny
         mov       bl,ds:[switchk]          ; kod klavesnice
         test      bl,4                     ; je slovenstina ?
         mov       bh,"S"                   ; slovenstina
         jnz       sethlp2                  ; je slovenstina
         mov       bh,"C"                   ; cestina
sethlp2: mov       ah,"K"                   ; kod Kamenickych
         and       bl,3                     ; vystupni kod
         jz        sethlp22                 ; je kod Kamenickych
         mov       ah,"L"                   ; kod Latin 2
         dec       bl
         jz        sethlp22                 ; je kod Latin 2
         mov       ah,"X"                   ; kod T602
sethlp22:stosw                              ; ulozeni znaku
         mov       ah,bh
         stosw                              ; kod cestina/slovenstina
                                          ;* zvukova signalizace zap/vyp
         mov       ah,"+"                   ; sig. zapnuta
         test      byte ptr ds:[switch],40h ; je signalizace zapnuta ?
         jnz       sethlp31                 ; je zapnuta
         mov       ah,"-"                   ; je vypnuta
sethlp31:stosw
                                          ;* hlasitost
         mov       ah,"H"                   ; hlasitost
         mov       bl,ds:[levs]             ; hlasitost
         call      sethlpn                  ; nastaveni parametru s cislem
                                          ;* opakovani
         mov       ah,"R"                   ; opakovani
         mov       bl,ds:[levr]             ; hlasitost pri opakovani
         call      sethlpn                  ; nastaveni parametru s cislem
                                          ;* vyska tonu
         mov       ah,"T"                   ; ton
         mov       bl,ds:[ton]              ; ton
         call      sethlpn                  ; nastaveni parametru s cislem
                                          ;* zapnut° ztmovanov†n°
         mov       ah,"9"
         test      byte ptr es:[switch],10h ; je zapnuta funkce ztm°v†n° ?
         jnz       sethlp5                  ; je funkce ztm°v†n°
         mov       ah,"0"                   ; nen° funkce ztm°v†n°
sethlp5: stosw
                                          ;* doba ztm°v†n°
         mov       ah,"D"
         mov       bl,ds:[timech]           ; nastavenÇ á°slo doby
         call      sethlpn
                                          ;* prefixovÇ kl†vesy
         mov       ah,"P"
         stosw                              ; oznaáen° prefixovòch kl†ves
         mov       ax,ds:[prefkey1]         ; prefixovÇ kl†vesy norm†ln°
         stosw
         mov       ax,ds:[prefkey2]
         stosw

         push      ds
         push      es
         pop       ds
         pop       es
         pop       di
         pop       bx
         pop       ax
         ret

sethlpn:                                  ;* nastaveni parametru s cislem
         stosw
         add       bl,"0"
         mov       es:[di],bl
         inc       di
         ret

; ------------------------------- data ----------------------------------------

citpar   db        0                        ; citac zadanych parametru

adrkod   label     word                     ; tabulka adres k¢dñ
         dw        offset tabkc             ; k¢d Kamenickòch - áe®tina
         dw        offset tablc             ; k¢d Latin 2 - áe®tina
         dw        offset tabxc             ; k¢d TEXT602 - áe®tina
         dw        offset tabkc             ; rezerva
         dw        offset tabks             ; k¢d Kamenickòch - sloven®tina
         dw        offset tabls             ; k¢d Latin 2 - sloven®tina
         dw        offset tabxs             ; k¢d TEXT602 - sloven®tina
         dw        offset tabks             ; rezerva

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze Kamenickòch
; -----------------------------------------------------------------------------
tabkc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b·"                     ; "·"
         db        "B·"                     ; "·"
         db        "qÑ"                     ; "Ñ"
         db        "Qé"                     ; "é"
         db        "wà"                     ; "à"
         db        "Wâ"                     ; "â"
         db        "eÇ"                     ; "Ç"
         db        "Eê"                     ; "ê"
         db        "r©"                     ; "©"
         db        "Rû"                     ; "û"
         db        "tü"                     ; "ü"
         db        "TÜ"                     ; "Ü"
         db        "yò"                     ; "ò"
         db        "Yù"                     ; "ù"
         db        "u£"                     ; "£"
         db        "Uó"                     ; "ó"
         db        "i°"                     ; "°"
         db        "Iã"                     ; "ã"
         db        "o¢"                     ; "¢"
         db        "Oï"                     ; "ï"
         db        "pî"                     ; "î"
         db        "Pô"                     ; "ô"
         db        "a†"                     ; "†"
         db        "Aè"                     ; "è"
         db        "s®"                     ; "®"
         db        "Sõ"                     ; "õ"
         db        "dÉ"                     ; "É"
         db        "DÖ"                     ; "Ö"
         db        "f™"                     ; "™"
         db        "F´"                     ; "´"
         db        "hÅ"                     ; "Å"
         db        "Hö"                     ; "ö"
         db        "jñ"                     ; "ñ"
         db        "J¶"                     ; "¶"
         db        "kì"                     ; "ì"
         db        "Kß"                     ; "ß"
         db        "lå"                     ; "å"
         db        "Lú"                     ; "ú"
         db        "zë"                     ; "ë"
         db        "Zí"                     ; "í"
         db        "cá"                     ; "á"
         db        "CÄ"                     ; "Ä"
         db        "n§"                     ; "§"
         db        "N•"                     ; "•"
         db        "mç"                     ; "ç"
         db        "Mä"                     ; "ä"
         db        ",Æ"                     ; "Æ"
         db        ".Ø"                     ; "Ø"
         db        "\≠"                     ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,150                ; "ñ"
         db        32h,3,136                ; "à"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,169                ; "©"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,166                ; "¶"
         db        32h,3,137                ; "â"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,158                ; "û"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,136                ; "à"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,169                ; "©"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";ñ"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,137                ; "â"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,158                ; "û"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";¶"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        212                      ; "‘"
         dw        5032h                    ; [2]
         db        207                      ; "œ"
         dw        5133h                    ; [3]
         db        190                      ; "æ"
         dw        4b34h                    ; [4]
         db        198                      ; "∆"
         dw        4c35h                    ; [5]
         db        216                      ; "ÿ"
         dw        4d36h                    ; [6]
         db        181                      ; "µ"
         dw        4737h                    ; [7]
         db        213                      ; "’"
         dw        4838h                    ; [8]
         db        209                      ; "—"
         dw        4939h                    ; [9]
         db        184                      ; "∏"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0                        

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        211                      ; "”"
         dw        5032h                    ; [2]
         db        208                      ; "–"
         dw        5133h                    ; [3]
         db        189                      ; "Ω"
         dw        4b34h                    ; [4]
         db        199                      ; "«"
         dw        4c35h                    ; [5]
         db        215                      ; "◊"
         dw        4d36h                    ; [6]
         db        182                      ; "∂"
         dw        4737h                    ; [7]
         db        214                      ; "÷"
         dw        4838h                    ; [8]
         db        210                      ; "“"
         dw        4939h                    ; [9]
         db        183                      ; "∑"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze Latin 2
; -----------------------------------------------------------------------------
tablc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "q",132                  ; "Ñ"
         db        "Q",142                  ; "é"
         db        "w",216                  ; "à"
         db        "W",183                  ; "â"
         db        "e",130                  ; "Ç"
         db        "E",144                  ; "ê"
         db        "r",253                  ; "©"
         db        "R",252                  ; "û"
         db        "t",156                  ; "ü"
         db        "T",155                  ; "Ü"
         db        "y",236                  ; "ò"
         db        "Y",237                  ; "ù"
         db        "u",163                  ; "£"
         db        "U",233                  ; "ó"
         db        "i",161                  ; "°"
         db        "I",214                  ; "ã"
         db        "o",162                  ; "¢"
         db        "O",224                  ; "ï"
         db        "p",148                  ; "î"
         db        "P",153                  ; "ô"
         db        "a",160                  ; "†"
         db        "A",181                  ; "è"
         db        "s",231                  ; "®"
         db        "S",230                  ; "õ"
         db        "d",212                  ; "É"
         db        "D",210                  ; "Ö"
         db        "f",234                  ; "™"
         db        "F",232                  ; "´"
         db        "h",129                  ; "Å"
         db        "H",154                  ; "ö"
         db        "j",133                  ; "ñ"
         db        "J",222                  ; "¶"
         db        "k",147                  ; "ì"
         db        "K",226                  ; "ß"
         db        "l",150                  ; "å"
         db        "L",149                  ; "ú"
         db        "z",167                  ; "ë"
         db        "Z",166                  ; "í"
         db        "c",159                  ; "á"
         db        "C",172                  ; "Ä"
         db        "n",229                  ; "§"
         db        "N",213                  ; "•"
         db        "m",146                  ; "ç"
         db        "M",145                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",245                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,133                ; "ñ"
         db        32h,3,216                ; "à"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,253                ; "©"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,222                ; "¶"
         db        32h,3,183                ; "â"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,252                ; "û"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,216                ; "à"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,253                ; "©"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",163                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",133                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,183                ; "â"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,252                ; "û"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",233                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",222                  ; "¶"
         db        ":",34
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - áesk† verze TEXT602
; -----------------------------------------------------------------------------
tabxc    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",177                  ; "·"
         db        "B",177                  ; "·"
         db        "q",209                  ; "Ñ"
         db        "Q",241                  ; "é"
         db        "w",197                  ; "à"
         db        "W",229                  ; "â"
         db        "e",215                  ; "Ç"
         db        "E",247                  ; "ê"
         db        "r",210                  ; "©"
         db        "R",242                  ; "û"
         db        "t",212                  ; "ü"
         db        "T",244                  ; "Ü"
         db        "y",217                  ; "ò"
         db        "Y",249                  ; "ù"
         db        "u",213                  ; "£"
         db        "U",245                  ; "ó"
         db        "i",201                  ; "°"
         db        "I",233                  ; "ã"
         db        "o",207                  ; "¢"
         db        "O",239                  ; "ï"
         db        "p",205                  ; "î"
         db        "P",237                  ; "ô"
         db        "a",193                  ; "†"
         db        "A",225                  ; "è"
         db        "s",211                  ; "®"
         db        "S",243                  ; "õ"
         db        "d",196                  ; "É"
         db        "D",228                  ; "Ö"
         db        "f",198                  ; "™"
         db        "F",230                  ; "´"
         db        "h",200                  ; "Å"
         db        "H",232                  ; "ö"
         db        "j",202                  ; "ñ"
         db        "J",234                  ; "¶"
         db        "k",208                  ; "ì"
         db        "K",240                  ; "ß"
         db        "l",204                  ; "å"
         db        "L",236                  ; "ú"
         db        "z",218                  ; "ë"
         db        "Z",250                  ; "í"
         db        "c",195                  ; "á"
         db        "C",227                  ; "Ä"
         db        "n",206                  ; "§"
         db        "N",238                  ; "•"
         db        "m",203                  ; "ç"
         db        "M",235                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",131                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,202                ; "ñ"
         db        32h,3,197                ; "à"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,210                ; "©"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,234                ; "¶"
         db        32h,3,229                ; "â"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,242                ; "û"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,197                ; "à"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,210                ; "©"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",213                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",202                  ; "ñ"
         db        ":",34                   ; "'"
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~",222                  ; "¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,229                ; "â"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,242                ; "û"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",245                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",234                  ; "¶"
         db        ":",34
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~",222                  ; "¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0


; -----------------------------------------------------------------------------
;                        Slovensk† verze Kamenickòch
; -----------------------------------------------------------------------------
tabks    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "qÑ"                     ; "Ñ"
         db        "Qé"                     ; "é"
         db        "wà"                     ; "à"
         db        "Wâ"                     ; "â"
         db        "eÇ"                     ; "Ç"
         db        "Eê"                     ; "ê"
         db        "f©"                     ; "©"
         db        "Fû"                     ; "û"
         db        "tü"                     ; "ü"
         db        "TÜ"                     ; "Ü"
         db        "yò"                     ; "ò"
         db        "Yù"                     ; "ù"
         db        "u£"                     ; "£"
         db        "Uó"                     ; "ó"
         db        "i°"                     ; "°"
         db        "Iã"                     ; "ã"
         db        "o¢"                     ; "¢"
         db        "Oï"                     ; "ï"
         db        "pî"                     ; "î"
         db        "Pô"                     ; "ô"
         db        "a†"                     ; "†"
         db        "Aè"                     ; "è"
         db        "s®"                     ; "®"
         db        "Sõ"                     ; "õ"
         db        "dÉ"                     ; "É"
         db        "DÖ"                     ; "Ö"
         db        "r™"                     ; "™"
         db        "R´"                     ; "´"
         db        "hÅ"                     ; "Å"
         db        "Hö"                     ; "ö"
         db        "jñ"                     ; "ñ"
         db        "J¶"                     ; "¶"
         db        "kì"                     ; "ì"
         db        "Kß"                     ; "ß"
         db        "lå"                     ; "å"
         db        "Lú"                     ; "ú"
         db        "zë"                     ; "ë"
         db        "Zí"                     ; "í"
         db        "cá"                     ; "á"
         db        "CÄ"                     ; "Ä"
         db        "n§"                     ; "§"
         db        "N•"                     ; "•"
         db        "mç"                     ; "ç"
         db        "Mä"                     ; "ä"
         db        ",Æ"                     ; "Æ"
         db        ".Ø"                     ; "Ø"
         db        "\≠"                     ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,147                ; "ì"
         db        32h,3,140                ; "å"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,159                ; "ü"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,167                ; "ß"
         db        32h,3,156                ; "ú"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,134                ; "Ü"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,140                ; "å"
         db        33h,4,168                ; "®"
         db        34h,5,135                ; "á"
         db        35h,6,159                ; "ü"
         db        36h,7,145                ; "ë"
         db        37h,8,152                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";ì"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,156                ; "ú"
         db        33h,4,155                ; "õ"
         db        34h,5,128                ; "Ä"
         db        35h,6,134                ; "Ü"
         db        36h,7,146                ; "í"
         db        37h,8,157                ; "ù"
         db        38h,9,143                ; "è"
         db        39h,10,139               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";ß"
         db        ":",34
         db        "'≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        212                      ; "‘"
         dw        5032h                    ; [2]
         db        207                      ; "œ"
         dw        5133h                    ; [3]
         db        190                      ; "æ"
         dw        4b34h                    ; [4]
         db        198                      ; "∆"
         dw        4c35h                    ; [5]
         db        216                      ; "ÿ"
         dw        4d36h                    ; [6]
         db        181                      ; "µ"
         dw        4737h                    ; [7]
         db        213                      ; "’"
         dw        4838h                    ; [8]
         db        209                      ; "—"
         dw        4939h                    ; [9]
         db        184                      ; "∏"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0                        

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        211                      ; "”"
         dw        5032h                    ; [2]
         db        208                      ; "–"
         dw        5133h                    ; [3]
         db        189                      ; "Ω"
         dw        4b34h                    ; [4]
         db        199                      ; "«"
         dw        4c35h                    ; [5]
         db        215                      ; "◊"
         dw        4d36h                    ; [6]
         db        182                      ; "∂"
         dw        4737h                    ; [7]
         db        214                      ; "÷"
         dw        4838h                    ; [8]
         db        210                      ; "“"
         dw        4939h                    ; [9]
         db        183                      ; "∑"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze Latin 2
; -----------------------------------------------------------------------------
tabls    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",225                  ; "·"
         db        "B",225                  ; "·"
         db        "q",132                  ; "Ñ"
         db        "Q",142                  ; "é"
         db        "w",216                  ; "à"
         db        "W",183                  ; "â"
         db        "e",130                  ; "Ç"
         db        "E",144                  ; "ê"
         db        "f",253                  ; "©"
         db        "F",252                  ; "û"
         db        "t",156                  ; "ü"
         db        "T",155                  ; "Ü"
         db        "y",236                  ; "ò"
         db        "Y",237                  ; "ù"
         db        "u",163                  ; "£"
         db        "U",233                  ; "ó"
         db        "i",161                  ; "°"
         db        "I",214                  ; "ã"
         db        "o",162                  ; "¢"
         db        "O",224                  ; "ï"
         db        "p",148                  ; "î"
         db        "P",153                  ; "ô"
         db        "a",160                  ; "†"
         db        "A",181                  ; "è"
         db        "s",231                  ; "®"
         db        "S",230                  ; "õ"
         db        "d",212                  ; "É"
         db        "D",210                  ; "Ö"
         db        "r",234                  ; "™"
         db        "R",232                  ; "´"
         db        "h",129                  ; "Å"
         db        "H",154                  ; "ö"
         db        "j",133                  ; "ñ"
         db        "J",222                  ; "¶"
         db        "k",147                  ; "ì"
         db        "K",226                  ; "ß"
         db        "l",150                  ; "å"
         db        "L",149                  ; "ú"
         db        "z",167                  ; "ë"
         db        "Z",166                  ; "í"
         db        "c",159                  ; "á"
         db        "C",172                  ; "Ä"
         db        "n",229                  ; "§"
         db        "N",213                  ; "•"
         db        "m",146                  ; "ç"
         db        "M",145                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",245                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,147                ; "ì"
         db        32h,3,150                ; "å"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,156                ; "ü"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,226                ; "ß"
         db        32h,3,149                ; "ú"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,155                ; "Ü"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,150                ; "å"
         db        33h,4,231                ; "®"
         db        34h,5,159                ; "á"
         db        35h,6,156                ; "ü"
         db        36h,7,167                ; "ë"
         db        37h,8,236                ; "ò"
         db        38h,9,160                ; "†"
         db        39h,10,161               ; "°"
         db        30h,11,130               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",163                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",147                  ; "ì"
         db        ":",34                   ; '"'
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,149                ; "ú"
         db        33h,4,230                ; "õ"
         db        34h,5,172                ; "Ä"
         db        35h,6,155                ; "Ü"
         db        36h,7,166                ; "í"
         db        37h,8,237                ; "ù"
         db        38h,9,181                ; "è"
         db        39h,10,214               ; "ã"
         db        30h,11,144               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",233                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",226                  ; "ß"
         db        ":",34
         db        "'",245                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        205                      ; "Õ"
         dw        4f31h                    ; [1]
         db        200                      ; "»"
         dw        5032h                    ; [2]
         db        202                      ; " "
         dw        5133h                    ; [3]
         db        188                      ; "º"
         dw        4b34h                    ; [4]
         db        204                      ; "Ã"
         dw        4c35h                    ; [5]
         db        206                      ; "Œ"
         dw        4d36h                    ; [6]
         db        185                      ; "π"
         dw        4737h                    ; [7]
         db        201                      ; "…"
         dw        4838h                    ; [8]
         db        203                      ; "À"
         dw        4939h                    ; [9]
         db        187                      ; "ª"
         dw        532eh                    ; [.]
         db        186                      ; "∫"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        196                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        192                      ; "¿"
         dw        5032h                    ; [2]
         db        193                      ; "¡"
         dw        5133h                    ; [3]
         db        217                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        195                      ; "√"
         dw        4c35h                    ; [5]
         db        197                      ; "≈"
         dw        4d36h                    ; [6]
         db        180                      ; "¥"
         dw        4737h                    ; [7]
         db        218                      ; "⁄"
         dw        4838h                    ; [8]
         db        194                      ; "¬"
         dw        4939h                    ; [9]
         db        191                      ; "ø"
         dw        532eh                    ; [.]
         db        179                      ; "≥"
         dw        0e02fh                   ; [/]
         db        176                      ; "∞"
         dw        372ah                    ; [*]
         db        177                      ; "±"
         dw        4a2dh                    ; [-]
         db        178                      ; "≤"
         dw        4e2bh                    ; [+]
         db        219                      ; "€"
         db        0

; -----------------------------------------------------------------------------
;                     K¢dy - slovensk† verze TEXT602
; -----------------------------------------------------------------------------
tabxs    label     byte
;tab0                                     ;* tabulka po prefixu
         db        49
         db        "b",177                  ; "·"
         db        "B",177                  ; "·"
         db        "q",209                  ; "Ñ"
         db        "Q",241                  ; "é"
         db        "w",197                  ; "à"
         db        "W",229                  ; "â"
         db        "e",215                  ; "Ç"
         db        "E",247                  ; "ê"
         db        "f",210                  ; "©"
         db        "F",242                  ; "û"
         db        "t",212                  ; "ü"
         db        "T",244                  ; "Ü"
         db        "y",217                  ; "ò"
         db        "Y",249                  ; "ù"
         db        "u",213                  ; "£"
         db        "U",245                  ; "ó"
         db        "i",201                  ; "°"
         db        "I",233                  ; "ã"
         db        "o",207                  ; "¢"
         db        "O",239                  ; "ï"
         db        "p",205                  ; "î"
         db        "P",237                  ; "ô"
         db        "a",193                  ; "†"
         db        "A",225                  ; "è"
         db        "s",211                  ; "®"
         db        "S",243                  ; "õ"
         db        "d",196                  ; "É"
         db        "D",228                  ; "Ö"
         db        "r",198                  ; "™"
         db        "R",230                  ; "´"
         db        "h",200                  ; "Å"
         db        "H",232                  ; "ö"
         db        "j",202                  ; "ñ"
         db        "J",234                  ; "¶"
         db        "k",208                  ; "ì"
         db        "K",240                  ; "ß"
         db        "l",204                  ; "å"
         db        "L",236                  ; "ú"
         db        "z",218                  ; "ë"
         db        "Z",250                  ; "í"
         db        "c",195                  ; "á"
         db        "C",227                  ; "Ä"
         db        "n",206                  ; "§"
         db        "N",238                  ; "•"
         db        "m",203                  ; "ç"
         db        "M",235                  ; "ä"
         db        ",",174                  ; "Æ"
         db        ".",175                  ; "Ø"
         db        "\",131                  ; "≠"
         db        0

;tab21                                    ;* program†torsk† kl†vesnice mal†
         db        10+128
         db        31h,2,208                ; "ì"
         db        32h,3,204                ; "å"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,212                ; "ü"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        0

;tab22                                    ;* program†torsk† kl†vesnice velk†
         db        10+128
         db        31h,2,240                ; "ß"
         db        32h,3,236                ; "ú"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,244                ; "Ü"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        0

;tab31                                    ;* p°sa©sk† kl†vesnice mal†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,204                ; "å"
         db        33h,4,211                ; "®"
         db        34h,5,195                ; "á"
         db        35h,6,212                ; "ü"
         db        36h,7,218                ; "ë"
         db        37h,8,217                ; "ò"
         db        38h,9,193                ; "†"
         db        39h,10,201               ; "°"
         db        30h,11,215               ; "Ç"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",213                  ; "£"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",208                  ; "ì"
         db        ":",34                   ; "'"
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~",222                  ; "¯"
         db        0

;tab32                                    ;* p°sa©sk† kl†vesnice velk†
         db        14+128
         db        31h,2,"+"                ; "+"
         db        32h,3,236                ; "ú"
         db        33h,4,243                ; "õ"
         db        34h,5,227                ; "Ä"
         db        35h,6,244                ; "Ü"
         db        36h,7,250                ; "í"
         db        37h,8,249                ; "ù"
         db        38h,9,225                ; "è"
         db        39h,10,233               ; "ã"
         db        30h,11,247               ; "ê"
         db        "/",35h,"-"              ; "-"
         db        "*",9,"8"                ; "8"
         db        "-",12,"="               ; "="
         db        "+",13,"~"               ; "~"

         db        24
         db        "!1"
         db        "@2"
         db        "#3"
         db        "$4"
         db        "%5"
         db        "^6"
         db        "&7"
         db        "(9"
         db        ")0"
         db        "_%"
         db        "='"
         db        "[",245                  ; "ó"
         db        "{/"
         db        "])"
         db        "}("
         db        ";",240                  ; "ß"
         db        ":",34
         db        "'",131                  ; "≠"
         db        34,"!"
         db        "<?"
         db        ">:"
;         db        "/-"
         db        "?_"
         db        "|;"
         db        "~",222                  ; "¯"
         db        0

;tab4                                     ;* grafick† kl†vesnice 1
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab5                                     ;* grafick† kl†vesnice 2
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0


;tab6                                     ;* grafick† kl†vesnice 3
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

;tab7                                     ;* grafick† kl†vesnice 4
         db        15+128
         dw        5230h                    ; [0]
         db        199                      ; "ƒ"
         dw        4f31h                    ; [1]
         db        194                      ; "¿"
         dw        5032h                    ; [2]
         db        251                      ; "¡"
         dw        5133h                    ; [3]
         db        226                      ; "Ÿ"
         dw        4b34h                    ; [4]
         db        214                      ; "√"
         dw        4c35h                    ; [5]
         db        223                      ; "≈"
         dw        4d36h                    ; [6]
         db        246                      ; "¥"
         dw        4737h                    ; [7]
         db        192                      ; "⁄"
         dw        4838h                    ; [8]
         db        219                      ; "¬"
         dw        4939h                    ; [9]
         db        224                      ; "ø"
         dw        532eh                    ; [.]
         db        231                      ; "≥"
         dw        0e02fh                   ; [/]
         db        150                      ; "€"
         dw        372ah                    ; [*]
         db        150                      ; "€"
         dw        4a2dh                    ; [-]
         db        150                      ; "€"
         dw        4e2bh                    ; [+]
         db        150                      ; "€"
         db        0

textins  db        'Ovladac cs. klavesnice CSKEY V 2.20 nainstalovan.',13,10,'$'

textjein db        'CSKEY V 2.20 je jiz nainstalovan (?=informace).',13,10,'$'

textset  db        'Parametry CSKEY nastaveny podle pozadavku.',13,10,'$'

textnins db        'Program CSKEY nelze odinstalovat z pameti.',13,10
         db        'Odinstalujte nejdrive programy za nim.',13,10,'$'

textdins db        'Program CSKEY byl odinstalovan z pameti.',13,10,'$'

textzins db        'Program CSKEY nelze odinstalovat, nebyl nainstalovan.',13,10,'$'

texthlp  db        'Ovladac CS. klavesnice CSKEY V 2.20; (c) Miroslav Nemecek',13,10
         db        '…ÕÕÕÕÕ TYP KLAVESNICE ÕÕÕÕÕÕÀÕÕÕÕÕÕ KOD CESTINY ÕÕÕÕÕÕÕÕª',13,10
         db        '∫ /1 standardni             ∫ /K kod bratri Kamenickych ∫',13,10
         db        '∫ /2 programatorska         ∫    (†áÉÇà°§¢©®ü£ñòë)      ∫',13,10
         db        '∫ /3 pisarska               ∫ /L kod Latin 2            ∫',13,10
         db        '∫ /4,/6 semigraf.-dvoj.cara ∫    (†ü‘Çÿ°Â¢˝Áú£ÖÏß)      ∫',13,10
         db        '∫ /5,/7 semigraf.-jedn.cara ∫ /X textovy editor TEXT602 ∫',13,10
         db        'ÃÕÕÕ SIGNALIZACE KLAVESY ÕÕÕŒÕÕÕ ZTMAVOVANI DISPLEJE ÕÕÕπ',13,10
         db        '∫ /+  signalizace zapnuta   ∫ /8  okamzite ztmaveni     ∫',13,10
         db        '∫ /-  signalizace vypnuta   ∫ /9  zapnuti ztmavovani    ∫',13,10
         db        '∫ /Hn norm. hlasitost n=0-9 ∫ /0  vypnuti ztmavovani    ∫',13,10
         db        '∫ /Rn hlas. opakovani n=0-9 ∫ /Dn doba pro ztmaveni     ∫',13,10
         db        '∫ /Tn vyska tonu n=0;1-9    ∫   n=1-9 [min]; 0=10 [min] ∫',13,10
         db        'ÃÕÕÕÕÕ NASTAVENI PREPINACICH (PREFIXOVYCH) KLAVES ÕÕÕÕÕÕπ',13,10
         db        '∫ /P.... 1-4 znaky (dva pro kl./1,/2,/4-/7; dva pro /3) ∫',13,10
         db        'ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ VERZE KLAVESNICE ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ',13,10
         db        '∫ /S slovenska klavesnice     /C ceska klavesnice       ∫',13,10
         db        '»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ /! odinstalovani z pameti ÕÕÕÕÕÕÕÕÕÕÕÕº',13,10
textsetp db        'Soucasne nastaveni: CSKEY.COM/1/K/C/+/H3/R1/T4/9/D5/P``=+',13,10
         db        '$'

code     ENDS

         END       start                    ; startovac° adresa

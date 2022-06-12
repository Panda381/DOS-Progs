COMMENT %
           Driver pro obsluhu kl†vesnice s áeskòm fontem znakñ
%


code     SEGMENT   page
         ASSUME    cs:code,ds:code

         org       100h

start:   jmp       init                     ; instalace programu

ident    db        'CSKEY V2.01 - ovladaá áeskÇ kl†vesnice '
         db        '(c) Nàmeáek 5.12.1990'
ident0:

; -----------------------------------------------------------------------------
;               Obsluha p©eru®en° kl†vesnic° INT 09H
; -----------------------------------------------------------------------------

old09    dd        0                        ; pñvodn° obsluha p©eru®en° INT 09
                                            ; (pouë°v† se tÇë pro identifikaci)

switch   db        01010001b                ; p©°znaky kl†vesnice
                                            ; bit 0 - bit 2 = á°slo kl†vesnice
                                            ;                 (1 aë 5)
                                            ; bit 3 = 0:Kamenic., 1:Latin2
                                            ; bit 4 = je funkce stm°v†n°
                                            ; bit 5 = ztmaven° displeje
                                            ; bit 6 = zapnuta zvukov† signaliz.
                                            ; bit 7 = byl prefix

parint   db        0                        ; p©°znak obsluh p©eru®en°
                                            ; bit 0 = prob°h† INT 10h
                                            ; bit 1 = prob°h† INT 09h
                                            ; bit 2 = prob°h† INT 16h
                                            ; bit 3 = prob°h† INT 21h
                                            ; bit 4 = nen° poëad. obsluhy ztmav.
                                            ; bit 5 = poëadavek p©eru®en° prog.
                                            ; bit 6 = prob°h† obsluha ztmaven°
                                            ; bit 7 = displej je ztmaven

pozc     db        0                        ; bit 0 = poëad. nastaven° prost©ed°
                                            ; bit 1 = poëad. prost©ed° IBM

prefkey1 dw        "'`"                     ; prefixy pro norm†ln° a prog. kl†v.
prefkey2 dw        "=`"                     ; prefixy pro p°sa©skou kl†vesnici

levs     db        3                        ; hlasitost p°pnut° 0 aë 9
levr     db        1                        ; hlasitost p©i opakov†n° 0 aë 9
ton      db        4                        ; vò®ka t¢nu 0 aë 9

timeoff  dw        5463                     ; doba pro vypnut° displeje (5 min.)
count    dw        1092                     ; á°taá ztmavnut° (1 minuta)

typdisp  db        0                        ; typ displeje:
                                            ;    0=nestandardn°
                                            ;    1=CGA
                                            ;    2=MDA
                                            ;    3=EGA

intbuf   db        16*4 DUP (0)             ; buffer pro z†znam p©eru®en°

int09:                                      ; program obsluhy kl†vesnice

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
         mov       word ptr cs:[count],bx   ; n†vrat nastaven° á°taáe
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
         call      num5                     ; vloëen° "5" z numerickÇho pole
         jnc       cskey1                   ; k¢d kl†vesy byl vloëen
         call      insert                   ; obsluha opakov†n° kl†vesy <Insert>
         jc        konec                    ; nebyla kl†vesa <Insert>
cskey1:                                   ;* byl p©ijat k¢d kl†vesy
         call      beep                     ; zvukov† signalizace stisku kl†vesy
         call      ramecek                  ; kreslen° r†meákñ
         jnc       konec                    ; operace OK - konec obsluhy
         call      opakovani                ; zn†soben° kurzorovòch kl†ves
         jnc       konec                    ; operace OK - konec obsluhy
         call      preruseni                ; obsluha p©eru®en° programu
         jnc       konec                    ; operace provedena OK
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
         and       byte ptr cs:[parint],0fdh; zru®en° p©°znaku obsluhy INT 09h
         iret

znakz    dw        32                       ; poslednà vloëenò znak

; *****************************************************************************
;
;                              Podprogramy
;
; *****************************************************************************

num5:                                       ; vloëen° kl†vesy "5" z num. pole
                                            ; VSTUP: AH=orientaán° k¢d kl†vesy

         cmp       ah,4ch                   ; byla kl†vesa [5] ?
         stc                                ; p©°znak - nebyla kl†vesa [5]
         jnz       num51                    ; nen° kl†vesa <Insert>
         mov       al,0f0h                  ; k¢d identifikace kl†vesy
         call      inskey0                  ; vloëen° kl†vesy do syst. bufferu
num51:   ret

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

lastch   db        0                        ; poslednà stisknut† kl†vesa

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
         cmp       byte ptr [bx],"+"        ; je zapnut° zvukovÇ signalizace ?
         jne       beepset1                 ; nen° zapnut° zvukovÇ signalizace
         and       byte ptr cs:[switch],7fh ; zru®en° p©°znaku prefixu
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

preruseni:                                  ; p©eru®en° prog. <Ctrl>-<Alt>-<Esc>
                                            ; VùSTUP: CY=funkce neprovedena

         mov       al,ds:[17h]              ; status p©esmykaáñ
         and       al,0fh                   ; p©°znaky <Ctrl>, <Alt> a <Shift>
         cmp       al,0ch                   ; jsou stisknuty <Ctrl>-<Alt>
         jne       prerus3                  ; nen° kombinace <Ctrl>-<Alt>
         mov       ax,[bx]                  ; p©ijatò k¢d kl†vesy
         cmp       ah,1                     ; je kl†vesa <Esc> ?
         jne       prerus3                  ; nen° kl†vesa <Esc>
         or        byte ptr cs:[parint],20h ; poëadavek p©eru®en° programu
         clc                                ; p©°znak - operace provedena OK
         ret

prerus3: stc                                ; p©°znak - k¢d kl†vesy nenalezen
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

         mov       al,cs:[switch]
         and       al,7                     ; á°slo kl†vesnice
         mov       dx,cs:[prefkey1]         ; prefixy norm†ln° kl†vesnice
         cmp       al,3                     ; je kl†vesnice 3 ?
         jne       prefix0                  ; nen° kl†vesnice 3
         mov       dx,cs:[prefkey2]         ; prefixy p°sa©skÇ kl†vesnice
prefix0: cmp       byte ptr ds:[bx],dh      ; je prefix ` (á†rka vlevo) ?
         je        prefix1                  ; je prefix `
         cmp       byte ptr [bx],dl         ; je prefix ' (á†rka vpravo) ?
         jne       prefix3                  ; nen° ani prefix '
prefix1: test      byte ptr cs:[switch],80h ; byl jië nàkterò prefix ?
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
         cmp       al,"&"                   ; je nastaven° prost©ed° IBM ?
         jne       prepin0                  ; nen° nastaven° prost©ed° IBM
         or        byte ptr cs:[pozc],2     ; poëadavek nastaven° prost©ed° IBM
         and       byte ptr cs:[switch],7fh ; reset p©°znaku prefixu
         jmp       short prepin80           ; n†vrat z obsluhy
prepin0: sub       al,"0"                   ; je znak men®° neë "0" ?
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
         jne       prepin4                  ; nen° znak "7"
         and       byte ptr cs:[switch],7fh ; reset p©°znaku prefixu
         or        byte ptr cs:[switch],8   ; nastaven° p©°znaku Latin2
         or        byte ptr cs:[pozc],1     ; poëadavek nastaven° prost©ed°
         jmp       short prepin8            ; n†vrat z obsluhy
prepin4: cmp       al,6                     ; je znak "6" ?
         jne       prepin5                  ; nen° znak "6"
         and       byte ptr cs:[switch],77h ; nastaven° p©°znaku Kamenickòch
         or        byte ptr cs:[pozc],1     ; poëadavek nastaven° prost©ed°
         jmp       short prepin8            ; n†vrat z obsluhy
prepin5: cmp       al,5                     ; je k¢d p©ep°naáe kl†vesnice ?
         ja        prepin9                  ; nen° p©ep°naá kl†vesnice
         and       byte ptr cs:[switch],78h ; nulov†n° á°sla kl†vesnice
         or        byte ptr cs:[switch],al  ; nastaven° novÇho á°sla kl†vesnice
prepin8: mov       word ptr ds:[1ch],bx     ; zru®en° kl†vesy z bufferu
         clc                                ; p©°znak - operace provedena OK
         ret


; -----------------------------------------------------------------------------

prekod:                                     ; p©ek¢dov†n° k¢du kl†vesy

         xor       ax,ax                    ; AX <- 0000
         mov       al,cs:[switch]           ; p©ep°naá kl†vesnice
         test      al,80h                   ; byl zad†n prefix ?
         jz        prekod1                  ; nebyl zad†n ë†dnò prefix
         and       byte ptr cs:[switch],7fh ; nulov†n° p©°znakñ prefixñ
         and       al,8                     ; nulov†n° á°sla kl†vesnice
prekod1: mov       si,offset adrtab1        ; tab. adres s vypnutòm <Caps Lock>
         test      byte ptr ds:[17h],40h    ; je zapnut <Caps Lock> ?
         jz        prekod2                  ; <Caps Lock> je vypnut
         mov       si,offset adrtab2        ; tab. adres se zapnutòm <Caps Lock>
prekod2: and       al,0fh                   ; ponech† á°slo kl†vesnice
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
         call      inskey0                  ; vloëen° znaku do syst. bufferu
         ret


inskey0:
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

old08    dd        0                        ; pñvodn° obsluha INT 08h (hodiny)

int08:                                      ; obsluha systÇmovòch hodin


         pushf
         call      dword ptr cs:[old08]     ; obsluha áasovaáe INT 08h
         test      byte ptr cs:[parint],51h ; je moënÇ obslouëit displej ?
         jnz       int083                   ; nen° moënÇ provÇst obsluhu
         or        byte ptr cs:[parint],50h ; nastaven° p©°znaku obsluhy displ.
         call      displ                    ; obsluha ztmaven° displeje
         and       byte ptr cs:[parint],0bfh; zru®en° p©°znaku obsluhy displeje
int083:  test      byte ptr cs:[parint],20h ; je poëadov†no p©eru®en° programu ?
         jz        int080                   ; nen° poëadov†no p©eru®en°
         test      byte ptr cs:[parint],4fh ; je moënÇ p©eru®en° ?
         jnz       int080                   ; nen° moënÇ p©eru®en°
         and       byte ptr cs:[parint],0dfh; zru®en° p©°znaku p©eru®en°
         pop       ax                       ; zru®en° n†vratovÇ adresy
         pop       ax                       ; zru®en° segmentu n†vratovÇ adresy
         pop       ax                       ; zru®en° registru p©°znakñ
         jmp       interp                   ; proveden° p©eru®en° programu
int080:  test      byte ptr cs:[switch],10h ; je funkce stm°v†n° ?
         jz        int082                   ; nen° funkce stm°v†n°
         cmp       word ptr cs:[count],0    ; je jië dosaëeno 0 ?
         jne       int081                   ; nen° je®tà dosaëeno 0
         or        byte ptr cs:[switch],20h ; p©°znak - displej m† bòt ztmavnut
         mov       word ptr cs:[count],2    ; konstanta pro opakovanÇ stm°v†n°
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
int081:  dec       word ptr cs:[count]      ; sn°ëen° á°taáe stm°v†n°
int082:  test      byte ptr cs:[pozc],3     ; poëadov†no nastaven° prost©ed° ?
         jz        int084                   ; nen° poëadov†no nastaven° prost©.
         test      byte ptr cs:[parint],6fh ; je moënÇ nastaven° prost©ed° ?
         jnz       int084                   ; nen° moënÇ nastaven° prost©ed°
         push      ax
         push      bx
         push      dx
         test      byte ptr cs:[pozc],2     ; je poëadov†n
         mov       byte ptr cs:[pozc],0     ; zru®en° poëadavku nastaven° prost.
         mov       bx,437                   ; pñvodn° prost©ed° IBM
         jnz       int085                   ; je poëadov†no nastaven° prost©.IBM
         test      byte ptr cs:[switch],8   ; je áe®tina Kamenickòch ?
         mov       bx,850                   ; k¢d áe®tiny Kamenickòch
         jz        int085                   ; je poëadov†na áe®tina Kamenickòch
         mov       bx,852                   ; k¢d prost©ed° Latin 2
int085:  mov       ax,6602h                 ; funkce nastaven° prost©ed° v BX
         mov       dx,-1                    ; p©°znak nastaven° prost©ed°
         push      bx                       ; £schova k¢du prost©ed°
         int       21h                      ; nastaven° n†rodn°ho prost©ed°
         pop       bx                       ; n†vrat k¢du prost©ed°
         mov       ax,38ffh
         mov       dx,-1
         int       21h                      ; nastaven° k¢du prost©ed°
         pop       dx
         pop       bx
         pop       ax
int084:  iret



loadint:                                    ; uloëen° vektorñ p©eru®en°
                                            ; tento podprogram uschov† vektory
                                            ; p©eru®en° pro funkci p©eru®en°
                                            ; programu <Ctrl>-<Alt>-<Esc>
                                            ; VSTUP: ES-c°lovò segment bufferu
         push      ax
         push      cx
         push      si
         push      di
         push      ds
         pushf                              ; £schova registru p©°znakñ
         cld                                ; smàr p©enosu nahoru
         cli                                ; z†kaz p©eru®en°
         mov       cx,2*4                   ; poáet bajtñ k p©enosu
         mov       si,8*4                   ; adresa vektoru 03h
         mov       ax,0
         mov       ds,ax                    ; segment tabulky p©eru®en°
         mov       di,offset intbuf         ; adresa bufferu tabulky p©eru®en°
         rep       movsb                    ; p©enos vektorñ 03h az 27h
         mov       cx,1*4
         mov       si,16*4
         rep       movsb
         mov       cx,1*4
         mov       si,22*4
         rep       movsb
         mov       cx,3*4
         mov       si,26*4
         rep       movsb
         mov       cx,8*4
         mov       si,32*4
         rep       movsb
         mov       cx,1*4
         mov       si,298*4
         rep       movsb                    ; ukazatel na parametry EGA
         popf                               ; n†vrat registru p©°znakñ
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

interp:                                   ;* p©eru®en° programu
         pushf                              ; £schova registru p©°znakñ
         cli                                ; z†kaz p©eru®en°
         cld                                ; smàr posunu ukazatele nahoru
         mov       ax,cs                    ; programovò segment
         mov       ds,ax                    ; segment bufferu vektoru
         mov       si,offset intbuf         ; adresa bufferu tabulky p©eru®en°
         mov       ax,0                     ; AX <- 0000
         mov       es,ax                    ; segment tabulky p©eru®en°
         mov       cx,2*4                   ; poáet bajtñ k p©enosu
         mov       di,8*4                   ; adresa vektoru 09h
         rep       movsb                    ; p©enos tabulky vektorñ
         mov       cx,1*4
         mov       di,16*4
         rep       movsb
         mov       cx,1*4
         mov       di,22*4
         rep       movsb
         mov       cx,3*4
         mov       di,26*4
         rep       movsb
         mov       cx,8*4
         mov       di,32*4
         rep       movsb
         mov       cx,1*4
         mov       di,298*4
         rep       movsb                    ; ukazatel na parametry EGA
         popf                               ; n†vrat registru p©°znakñ
         mov       ax,0003                  ; textovò reëim
         int       10h                      ; nastaven° displeje
         mov       ax,4c01h                 ; funkce ukonáen° programu s chybou
         int       21h                      ; p©eru®en° aktivn°ho programu


; *****************************************************************************
;
;                             Monitorov†n° p©eru®en°
;
; *****************************************************************************

old10    dd        0                        ; pñvodn° obsluha INT 10h

int10:                                      ; obsluha p©eru®en° INT 10h
         or        byte ptr cs:[parint],1   ; nastaven° p©°znaku obsluhy INT 10h
         pushf
         call      dword ptr cs:[old10]     ; vol†n° pñvodn° obsluhy INT 10h
         pushf                              ; £schova registru p©°znakñ
         and       byte ptr cs:[parint],0feh; nulov†n° p©°znaku obsluhy INT 10h

intret:  popf                               ; n†vrat registru p©°znakñ
retfar   proc      far
         sti                                ; povolen° p©eru®en°
         ret       2                        ; n†vrat bez obnoven° registru
retfar   endp


old16    dd        0                        ; pñvodn° obsluha INT 16h

int16:                                      ; obsluha p©eru®en° INT 16h
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


old21    dd        0                        ; pñvodn° obsluha INT 21h

int21:                                      ; obsluha p©eru®en° INT 21h
         or        byte ptr cs:[parint],8   ; nastaven° p©°znaku obsluhy INT 21h
         pushf
         call      dword ptr cs:[old21]     ; vol†n° pñvodn° obsluhy INT 21h
         pushf                              ; £schova registru p©°znakñ
         and       byte ptr cs:[parint],0f7h; nulov†n° p©°znaku obsluhy INT 21h
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
         and       al,0f7h                  ; nastaven° p©°znaku vypnut° disp.
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
adrtab1  dw        offset tab1              ; 0:tabulka po prefixu - Kamenickòch
         dw        0                        ; 1:pñvodn° kl†vesnice IBM
         dw        offset tab3              ; 2:program.kl†vesnice mal† - Kamen.
         dw        offset tab7              ; 3:p°sa©. kl†vesnice mal† - Kamen.
         dw        offset tab11             ; 4:grafick† kl†vesnice 4 - Kamen.
         dw        offset tab13             ; 5:grafick† kl†vesnice 5 - Kamen.
         dw        0                        ; 6
         dw        0                        ; 7
         dw        offset tab2              ; 8:tabulka po prefixu - Latin2
         dw        0                        ; 8+1:pñvodn° kl†vesnice IBM
         dw        offset tab4              ; 8+2:progr.kl†vesnice mal† - Latin2
         dw        offset tab8              ; 8+3:p°sa©.kl†vesnice mal† - Latin2
         dw        offset tab12             ; 8+4:grafick† kl†vesnice 4 - Latin2
         dw        offset tab14             ; 8+5:grafick† kl†vesnice 5 - Latin2
         dw        0                        ; 8+6
         dw        0                        ; 8+7

                                           ;* <Caps Lock> je zapnut
adrtab2  dw        offset tab1              ; 0:tabulka po prefixu - Kamenickòch
         dw        0                        ; 1:pñvodn° kl†vesnice IBM
         dw        offset tab5              ; 2:program.kl†vesnice velk†-Kamen.
         dw        offset tab9              ; 3:p°sa©. kl†vesnice velk† - Kamen.
         dw        offset tab11             ; 4:grafick† kl†vesnice 4 - Kamen.
         dw        offset tab13             ; 5:grafick† kl†vesnice 5 - Kamen.
         dw        0                        ; 6
         dw        0                        ; 7
         dw        offset tab2              ; 8:tabulka po prefixu - Latin2
         dw        0                        ; 8+1:pñvodn° kl†vesnice IBM
         dw        offset tab6              ; 8+2:progr.kl†vesnice velk†-Latin2
         dw        offset tab10             ; 8+3:p°sa©.kl†vesnice velk†-Latin2
         dw        offset tab12             ; 8+4:grafick† kl†vesnice 4 - Latin2
         dw        offset tab14             ; 8+5:grafick† kl†vesnice 5 - Latin2
         dw        0                        ; 8+6
         dw        0                        ; 8+7


                                            ; tabulka po prefixu - Kamenickòch
tab1     db        50
         db        "="
         db        "qÑ"
         db        "Qé"
         db        "wà"
         db        "Wâ"
         db        "eÇ"
         db        "Eê"
         db        "r©"
         db        "Rû"
         db        "tü"
         db        "TÜ"
         db        "yò"
         db        "Yù"
         db        "u£"
         db        "Uó"
         db        "i°"
         db        "Iã"
         db        "o¢"
         db        "Oï"
         db        "pî"
         db        "Pô"
         db        "a†"
         db        "Aè"
         db        "s®"
         db        "Sõ"
         db        "dÉ"
         db        "DÖ"
         db        "f™"
         db        "F´"
         db        "hÅ"
         db        "Hö"
         db        "jñ"
         db        "J¶"
         db        "kì"
         db        "Kß"
         db        "lç"
         db        "Lä"
         db        "zë"
         db        "Zí"
         db        "cá"
         db        "CÄ"
         db        "n§"
         db        "N•"
         db        "må"
         db        "Mú"
         db        ",Æ"
         db        "<Û"
         db        ".Ø"
         db        ">Ú"
         db        "\≠"
         db        0

                                            ; tabulka po prefixu - Latin2
tab2     db        48
         db        "="
         db        "q",132
         db        "Q",142
         db        "w",216
         db        "W",183
         db        "e",130
         db        "E",144
         db        "r",253
         db        "R",252
         db        "t",156
         db        "T",155
         db        "y",236
         db        "Y",237
         db        "u",163
         db        "U",233
         db        "i",161
         db        "I",214
         db        "o",162
         db        "O",224
         db        "p",148
         db        "P",153
         db        "a",160
         db        "A",181
         db        "s",231
         db        "S",230
         db        "d",212
         db        "D",210
         db        "f",234
         db        "F",232
         db        "h",129
         db        "H",154
         db        "j",133
         db        "J",222
         db        "k",147
         db        "K",226
         db        "l",146
         db        "L",145
         db        "z",167
         db        "Z",166
         db        "c",159
         db        "C",172
         db        "n",229
         db        "N",213
         db        "m",150
         db        "M",149
         db        ",",174
         db        ".",175
         db        "\",245
         db        0

                                            ; program. kl†vesnice mal† - Kamen.
tab3     db        10+128
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

                                            ; program. kl†vesnice mal† - Latin2
tab4     db        10+128
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

                                            ; program. kl†vesnice velk† - Kamen.
tab5     db        10+128
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

                                            ; program. kl†vesnice velk† - Latin2
tab6     db        10+128
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


                                            ; p°sa©sk† kl†vesnice mal† - Kamen.
tab7     db        18+128
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
         db        "Y",15h,"Z"              ; "Z"
         db        "y",15h,"z"              ; "z"
         db        "Z",2ch,"Y"              ; "Y"
         db        "z",2ch,"y"              ; "y"

         db        25
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
         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

                                            ; p°sa©sk† kl†vesnice mal† - Latin2
tab8     db        18+128
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
         db        "Y",15h,"Z"              ; "Z"
         db        "y",15h,"z"              ; "z"
         db        "Z",2ch,"Y"              ; "Y"
         db        "z",2ch,"y"              ; "y"

         db        25
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
         db        ";Ö"
         db        ":",34
         db        "'ı"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

                                            ; p°sa©sk† kl†vesnice velk† - Kamen.
tab9     db        18+128
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
         db        "Y",15h,"Z"              ; "Z"
         db        "y",15h,"z"              ; "z"
         db        "Z",2ch,"Y"              ; "Y"
         db        "z",2ch,"y"              ; "y"

         db        25
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
         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

                                            ; p°sa©sk† kl†vesnice velk† - Latin2
tab10    db        18+128
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
         db        "Y",15h,"Z"              ; "Z"
         db        "y",15h,"z"              ; "z"
         db        "Z",2ch,"Y"              ; "Y"
         db        "z",2ch,"y"              ; "y"

         db        25
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
         db        "[È"
         db        "{/"
         db        "])"
         db        "}("
         db        ";ﬁ"
         db        ":",34
         db        "'ı"
         db        34,"!"
         db        "<?"
         db        ">:"
         db        "/-"
         db        "?_"
         db        "|;"
         db        "~¯"
         db        0

                                            ; grafick† kl†vesnice 4 - Kamen.
tab11    db        27+128                   ; p©°znak - k¢dy jsou 2-bajtovÇ
         dw        5230h                    ; [0]
         db        205
         dw        4f31h                    ; [1]
         db        200
         dw        5032h                    ; [2]
         db        202
         dw        5133h                    ; [3]
         db        188
         dw        4b34h                    ; [4]
         db        204
         dw        4c35h                    ; [5]
         db        206
         dw        4d36h                    ; [6]
         db        185
         dw        4737h                    ; [7]
         db        201
         dw        4838h                    ; [8]
         db        203
         dw        4939h                    ; [9]
         db        187
         dw        532eh                    ; [.]
         db        186
         dw        5200h                    ; <Shift>-[0]
         db        205
         dw        4f00h                    ; <Shift>-[1]
         db        212
         dw        5000h                    ; <Shift>-[2]
         db        207
         dw        5100h                    ; <Shift>-[3]
         db        190
         dw        4b00h                    ; <Shift>-[4]
         db        198
         dw        4c00h                    ; <Shift>-[5]
         db        216
         dw        4cf0h                    ; <Shift>-[5]
         db        216
         dw        4d00h                    ; <Shift>-[6]
         db        181
         dw        4700h                    ; <Shift>-[7]
         db        213
         dw        4800h                    ; <Shift>-[8]
         db        209
         dw        4900h                    ; <Shift>-[9]
         db        184
         dw        5300h                    ; <Shift>-[.]
         db        179
         dw        0e02fh                   ; [/]
         db        176
         dw        372ah                    ; [*]
         db        177
         dw        4a2dh                    ; [-]
         db        178
         dw        4e2bh                    ; [+]
         db        219
         db        0


                                            ; grafick† kl†vesnice 4 - Latin2
tab12    db        27+128                   ; p©°znak - k¢dy jsou 2-bajtovÇ
         dw        5230h                    ; [0]
         db        205
         dw        4f31h                    ; [1]
         db        200
         dw        5032h                    ; [2]
         db        202
         dw        5133h                    ; [3]
         db        188
         dw        4b34h                    ; [4]
         db        204
         dw        4c35h                    ; [5]
         db        206
         dw        4d36h                    ; [6]
         db        185
         dw        4737h                    ; [7]
         db        201
         dw        4838h                    ; [8]
         db        203
         dw        4939h                    ; [9]
         db        187
         dw        532eh                    ; [.]
         db        186
         dw        5200h                    ; <Shift>-[0]
         db        205
         dw        4f00h                    ; <Shift>-[1]
         db        200
         dw        5000h                    ; <Shift>-[2]
         db        202
         dw        5100h                    ; <Shift>-[3]
         db        188
         dw        4b00h                    ; <Shift>-[4]
         db        204
         dw        4c00h                    ; <Shift>-[5]
         db        206
         dw        4cf0h                    ; <Shift>-[5]
         db        206
         dw        4d00h                    ; <Shift>-[6]
         db        185
         dw        4700h                    ; <Shift>-[7]
         db        201
         dw        4800h                    ; <Shift>-[8]
         db        203
         dw        4900h                    ; <Shift>-[9]
         db        187
         dw        5300h                    ; <Shift>-[.]
         db        186
         dw        0e02fh                   ; [/]
         db        176
         dw        372ah                    ; [*]
         db        177
         dw        4a2dh                    ; [-]
         db        178
         dw        4e2bh                    ; [+]
         db        219
         db        0

                                            ; grafick† kl†vesnice 5 - Kamen.
tab13    db        27+128                   ; p©°znak - k¢dy jsou 2-bajtovÇ
         dw        5230h                    ; [0]
         db        196
         dw        4f31h                    ; [1]
         db        192
         dw        5032h                    ; [2]
         db        193
         dw        5133h                    ; [3]
         db        217
         dw        4b34h                    ; [4]
         db        195
         dw        4c35h                    ; [5]
         db        197
         dw        4d36h                    ; [6]
         db        180
         dw        4737h                    ; [7]
         db        218
         dw        4838h                    ; [8]
         db        194
         dw        4939h                    ; [9]
         db        191
         dw        532eh                    ; [.]
         db        179
         dw        5200h                    ; <Shift>-[0]
         db        196
         dw        4f00h                    ; <Shift>-[1]
         db        211
         dw        5000h                    ; <Shift>-[2]
         db        208
         dw        5100h                    ; <Shift>-[3]
         db        189
         dw        4b00h                    ; <Shift>-[4]
         db        199
         dw        4c00h                    ; <Shift>-[5]
         db        215
         dw        4cf0h                    ; <Shift>-[5]
         db        215
         dw        4d00h                    ; <Shift>-[6]
         db        182
         dw        4700h                    ; <Shift>-[7]
         db        214
         dw        4800h                    ; <Shift>-[8]
         db        210
         dw        4900h                    ; <Shift>-[9]
         db        183
         dw        5300h                    ; <Shift>-[.]
         db        186
         dw        0e02fh                   ; [/]
         db        176
         dw        372ah                    ; [*]
         db        177
         dw        4a2dh                    ; [-]
         db        178
         dw        4e2bh                    ; [+]
         db        219
         db        0

                                            ; grafick† kl†vesnice 5 - Latin2
tab14    db        27+128                   ; p©°znak - k¢dy jsou 2-bajtovÇ
         dw        5230h                    ; [0]
         db        196
         dw        4f31h                    ; [1]
         db        192
         dw        5032h                    ; [2]
         db        193
         dw        5133h                    ; [3]
         db        217
         dw        4b34h                    ; [4]
         db        195
         dw        4c35h                    ; [5]
         db        197
         dw        4d36h                    ; [6]
         db        180
         dw        4737h                    ; [7]
         db        218
         dw        4838h                    ; [8]
         db        194
         dw        4939h                    ; [9]
         db        191
         dw        532eh                    ; [.]
         db        179
         dw        5200h                    ; <Shift>-[0]
         db        196
         dw        4f00h                    ; <Shift>-[1]
         db        192
         dw        5000h                    ; <Shift>-[2]
         db        193
         dw        5100h                    ; <Shift>-[3]
         db        217
         dw        4b00h                    ; <Shift>-[4]
         db        195
         dw        4c00h                    ; <Shift>-[5]
         db        197
         dw        4cf0h                    ; <Shift>-[5]
         db        197
         dw        4d00h                    ; <Shift>-[6]
         db        180
         dw        4700h                    ; <Shift>-[7]
         db        218
         dw        4800h                    ; <Shift>-[8]
         db        194
         dw        4900h                    ; <Shift>-[9]
         db        191
         dw        5300h                    ; <Shift>-[.]
         db        179
         dw        0e02fh                   ; [/]
         db        176
         dw        372ah                    ; [*]
         db        177
         dw        4a2dh                    ; [-]
         db        178
         dw        4e2bh                    ; [+]
         db        219
         db        0




; zde je konec rezidentn° á†sti programu

; ===========================================================================

                                            ; instalace rezid. á†sti programu

init:
                                          ;* nastaven° k¢du áe®tiny
         mov       ax,3800h
         mov       dx,offset country        ; buffer
         int       21h                      ; poskytnut° k¢du zemà
         cmp       bx,852                   ; je áe®tina Latin 2 ?
         je        init03                   ; je áe®tina Latin 2
         mov       ax,6601h                 ; funkce poskytnut° n†rod. informac°
         int       21h                      ; poskytnut° k¢du zemà
         cmp       bx,852                   ; je áe®tina Latin 2 ?
         jne       init02                   ; nen° áe®tina Latin 2
init03:  or        byte ptr ds:[switch],8   ; nastaven° k¢du Latin 2
                                          ;* kontrola instalace programu
init02:
         mov       ax,100h-1                ; poá†teán° segment ke kontrole
init01:  inc       ax                       ; zvò®en° á°sla segmentu
         mov       es,ax                    ; ukazatel segmentu
         mov       si,offset ident          ; identifikace programu
         mov       di,si
         mov       cx,ident0-ident          ; dÇlka identifikaán° á†sti
         repe      cmpsb                    ; porovn†n° ©etàzcñ
         mov       ax,es                    ; adresa segmentu
         jne       init01                   ; ©etàzec nenalezen - dal®° adresa
         mov       bx,cs                    ; segment tohoto programu
         cmp       ax,bx                    ; je program nainstalov†n ?
         je        init10                   ; program nen° nainstalov†n
         mov       bx,word ptr es:[old09]   ; pñvodn° adresa INT 09h
         or        bx,word ptr es:[old09+2] ; je nastavena nàjak† adresa ?
         jz        init01                   ; je to naátenò program v bufferu
                                          ;* nastaven° parametrñ z p©°kaz. ©†dku
init10:  mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; poáet znakñ p©°kazovÇho ©†dku
         push      es                       ; uschova ES
         push      cs
         pop       es                       ; ES <- CS
init11:  jcxz      init12                   ; nen° jië dal®° znak - konec
         call      dekpar                   ; dek¢dov†n° parametru
         mov       dx,offset texthlp        ; text n†povàdy
         jnc       init11                   ; dekodovani dalsiho parametru
         pop       es                       ; navrat ES
         jmp       short init21             ; chyba - n†vrat s n†povàdou

init12:  pop       es                       ; navrat ES
         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[80h]              ; poáet znakñ p©°kazovÇho ©†dku
init13:  jcxz      init20                   ; nen° jië dal®° znak - konec
         call      dekpar                   ; dek¢dov†n° parametru
         mov       dx,offset texthlp        ; text n†povàdy
         jc        init21                   ; chyba - n†vrat s n†povàdou
         jmp       short init13             ; dek¢dov†n° dal®°ho parametru


                                          ;* instalace nebo ukonáen° programu
init20:  call      loadint                  ; aktualizace bufferu pro p©eru®en°
         mov       bx,cs                    ; segment tohoto programu
         mov       ax,es                    ; segment nainstalovanÇho programu
         cmp       ax,bx                    ; je program nainstalov†n ?
         je        init3                    ; program nen° nainstalov†n
         mov       dx,offset textset        ; hl†®en° o nastaven° parametrñ
init21:  mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn°ho textu
         mov       ax,4c00h                 ; funkce n†vratu z programu
         int       21h                      ; ukonáen° programu

init3:                                      ; instalace programu do pamàti
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
         mov       ax,3521h                 ; p©eáten° vektoru p©eru®en° 21h
         int       21h
         mov       word ptr [old21],bx      ; uloëen° pñvodn°ho vekt. p©eru®en°
         mov       word ptr [old21+2],es    ; segment nad©azenÇ instalace
                                          ;* nastaven° vektorñ p©eru®en°
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
         mov       dx,offset int21          ; adresa vlastn° obsluhy INT 21h
         mov       ax,2521h
         int       21h                      ; nastaven° novÇ adresy INT 21H
                                          ;* instalace programu do pamàti
         push      cs
         pop       es                       ; ES <- CS
         call      loadint                  ; aktualizace bufferu pro p©eru®en°
         mov       dx,offset textins        ; hl†®en° o instalaci programu
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk £vodn°ho textu
         mov       dx,offset init           ; konec rezidentn° á†sti
         int       27h                      ; instalace do pamàti

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
testdis2:mov       byte ptr [typdisp],1     ; je grafick† karta CGA
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
         cmp       al,"0"                   ; vypnut° funkce ztmavov†n° ?
         jne       dekpar3                  ; nen° vypnut° ztmavov†n°
         and       byte ptr es:[switch],0cfh; reset p©°znaku stm°v†n°
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
         ret
dekpar3: cmp       al,"9"                   ; je zapnut° ztmavov†n°
         jne       dekpar4                  ; nen° zapnut° ztmavov†n°
         or        byte ptr es:[switch],10h ; zapnut° funkce sm°v†n°
         ret
dekpar4: cmp       al,"8"                   ; je nucenÇ ztmaven° displeje ?
         jne       dekpar5                  ; nen° nucenÇ ztmaven° displeje
         and       byte ptr cs:[parint],0efh; poëadavek na obsluhu displeje
         or        byte ptr es:[switch],30h ; ztmaven° displeje
         mov       word ptr es:[count],4    ; citac ztmaveni displeje
         ret

dekpar5: cmp       al,"7"                   ; je nastaven° LATIN 2 ?
         jne       dekpar6                  ; nen° nastaven° LATIN 2
         or        byte ptr es:[switch],8   ; nastaven° p©°znaku LATIN 2
         or        byte ptr es:[pozc],1     ; poëadavek nastaven° prost©ed°
         ret
dekpar6: cmp       al,"6"                   ; je nastaven° k¢du Kamenickòch ?
         jne       dekpar7                  ; nen° nastaven° k¢du Kamenickòch
         and       byte ptr es:[switch],0f7h; nastaven° k¢du Kamenickòch
         or        byte ptr es:[pozc],1     ; poëadavek nastaven° prost©ed°
         ret
dekpar7: cmp       al,"5"                   ; je k¢d p©ep°naáe kl†vesnice ?
         ja        dekpar8                  ; nen° k¢d p©ep°naáe kl†vesnice
         cmp       al,"1"                   ; je k¢d p©ep°naáe kl†vesnice ?
         jb        dekpar8                  ; nen° k¢d p©ep°naáe kl†vesnice
         sub       al,"0"                   ; korekce na á°slo kl†vesnice
         and       byte ptr es:[switch],0f8h; nulov†n° á°sla kl†vesnice
         or        byte ptr es:[switch],al  ; nastaven° novÇho á°sla kl†vesnice
         ret
dekpar8: cmp       al,"+"                   ; je zapnut° zvukovÇ signalizace ?
         jne       dekpar9                  ; nen° zapnut° zvukovÇ signalizace
         or        byte ptr es:[switch],40h ; zapnut° zvukovÇ signalizace
         ret
dekpar9: cmp       al,"-"                   ; je vypnut° zvukovÇ signalizace ?
         jne       dekpara                  ; nen° vypnut° zvukovÇ signalizace
         and       byte ptr es:[switch],0bfh; vypnut° zvukovÇ signalizace
         ret
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
dekparb: cmp       al,"S"                   ; je definice hlasitosti zvuku ?
         jne       dekparc                  ; nen° definice hlasitosti
         call      readb                    ; naáten° á°slice definice
         jbe       dekparx                  ; chyba
         sub       al,"0"                   ; je á°slice ?
         jc        dekparx                  ; nen° á°slice
         cmp       al,9                     ; je platn† á°slice ?
         ja        dekparx                  ; nen° platn† á°slice
         mov       es:[levs],al             ; nastaven° hlasitosti zvuku
         clc
         ret

dekparc: cmp       al,"R"                   ; je definice hlasitosti zvuku ?
         jne       dekpard                  ; nen° definice hlasitosti
         call      readb                    ; naáten° á°slice definice
         jbe       dekparx                  ; chyba
         sub       al,"0"                   ; je á°slice ?
         jc        dekparx                  ; nen° á°slice
         cmp       al,9                     ; je platn† á°slice ?
         ja        dekparx                  ; nen° platn† á°slice
         mov       es:[levr],al             ; nastaven° hlasitosti opakov†n°
         clc
         ret

dekparx: stc                                ; p©°znak - nepovolenò parametr
         ret

dekpary: clc
         ret

dekpard: cmp       al,"T"                   ; je definice vò®ky t¢nu ?
         jne       dekpare                  ; nen° definice hlasitosti
         call      readb                    ; naáten° á°slice definice
         jbe       dekparx                  ; chyba
         sub       al,"0"                   ; je á°slice ?
         jc        dekparx                  ; nen° á°slice
         cmp       al,9                     ; je platn† á°slice ?
         ja        dekparx                  ; nen° platn† á°slice
         mov       es:[ton],al              ; nastaven° vò®ky t¢nu
         clc
         ret

dekpare: cmp       al,"&"                   ; je nastaven° prost©ed° IBM ?
         jne       dekparf                  ; nen° nastaven° prost©ed° IBM
         or        byte ptr es:[pozc],2     ; poëadavek nastaven° prost©ed° IBM
         clc
         ret
dekparf: cmp       al,"D"                   ; je nastaven° doby ztmaven° ?
         jne       dekparg                  ; nen° nastaven° doby ztmaven°
         call      readb                    ; naáten° á°slice definice
         jbe       dekparx                  ; chyba
         sub       al,"0"                   ; je á°slice ?
         jc        dekparx                  ; nen° á°slice
         cmp       al,9                     ; je platn† á°slice ?
         ja        dekparx                  ; nen° platn† á°slice
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
dekparg:
         stc
         ret

textins  db        'Ovladac ceske klavesnice CSKEY V 2.01 nainstalovan (?=informace).'
         db        13,10,'$'

textset  db        'Parametry CSKEY nastaveny podle pozadavku (?=informace).'
         db        13,10,'$'

texthlp: db        'Nastaveni parametru: CSKEY.COM /1/6/9/D5/+/S3/R1/T4/P`''`=',13,10
         db        '…ÕÕÕÕÕ TYP KLAVESNICE ÕÕÕÕÕÕÀÕÕÕÕÕÕ KOD CESTINY ÕÕÕÕÕÕÕÕª',13,10
         db        '∫ /1 standardni             ∫ /6 kod bratri Kamenickych ∫',13,10
         db        '∫ /2 programatorska         ∫    (†áÉÇà°§¢©®ü£ñòë)      ∫',13,10
         db        '∫ /3 pisarska               ∫ /7 kod Latin 2            ∫',13,10
         db        '∫ /4 semigraf. - jedn. cara ∫    (†ü‘Çÿ°Â¢˝Áú£ÖÏß)      ∫',13,10
         db        '∫ /5 semigraf. - dvoj. cara ∫ /& vypnuti cestiny        ∫',13,10
         db        'ÃÕÕÕ SIGNALIZACE KLAVESY ÕÕÕŒÕÕÕ ZTMAVOVANI DISPLEJE ÕÕÕπ',13,10
         db        '∫ /+  signalizace zapnuta   ∫ /8  okamzite ztmaveni     ∫',13,10
         db        '∫ /-  signalizace vypnuta   ∫ /9  zapnuti ztmavovani    ∫',13,10
         db        '∫ /Sn hlasitost n=0-9       ∫ /0  vypnuti ztmavovani    ∫',13,10
         db        '∫ /Rn hlas. opakovani n=0-9 ∫ /Dn doba pro ztmaveni     ∫',13,10
         db        '∫ /Tn vyska tonu n=0;1-9    ∫   n=1-9 [min]; 0=10 [min] ∫',13,10
         db        'ÃÕÕÕÕÕ NASTAVENI PREPINACICH (PREFIXOVYCH) KLAVES ÕÕÕÕÕÕπ',13,10
         db        '∫ /P.... 1-4 znaky (dva pro kl./1,/2,/4,/5; dva pro /3) ∫',13,10
         db        '»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',13,10
         db        'Tento program je mozne  neomezene volne sirit a pouzivat.',13,10
         db        'Pokud  se  Vam bude libit, zaslete  drobnou  sumu na nize',13,10
         db        'uvedenou adresu. Pokud ne, zaslete pripominky. Zaslete-li',13,10
         db        'alespon 45,- Kcs, budou Vam zasilany nove verze programu.',13,10
         db        10
         db        'ing. Nemecek Miroslav, Kulturni 1753, 756 61 Roznov p. R.',13,10
         db        '$'

country  label     byte                     ; buffer pro naáten° n†r. informac°


code     ENDS

         END       start                    ; startovac° adresa

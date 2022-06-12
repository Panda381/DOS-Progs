
; *****************************************************************************
;
;                                COMLINK
;                  program pro lok†ln° poá°taáovou s°ü
;
; *****************************************************************************

; Znaky pouëitÇ p©i komunikaci:
;
; 00h NUL    - oddàlovac° mezera (ignoruje se)
; 01h BEGIN  - zaá†tek zpr†vy (n†sleduje p©°jemce a odes°latel)
; 02h ENDS   - konec zpr†vy (p©edch†z° kontroln° souáet 2 bajty)
; 03h SHF    - p©echodn† zmàna p©esmykaáe (zmàna inverze znaku - provede se NOT)
; 04h SHI    - trval† zmàna p©esmykaáe (trval† inverze dat - NOT)
; 05h REP    - opakov†n° (n†sleduje poáet NOT a opakovanò znak)
; 06h BRK    - p©eru®en° vys°l†n°
; 07h          (zat°m rezerva)
; 08h aë 0ffh - platnÇ znaky


; Komunikaán° protokol:
;
;  BEGIN      - identifikace zaá†tku zpr†vy
;  c°l        - p©°jemce zpr†vy A - Z
;  zdroj      - zdroj zpr†vy A - Z
;    povel    - povel pro p©°jemce
;    text     - text (text obsahu zpr†vy)
;  souáet     - kontroln° souáet celÇ zpr†vy 2 bajty CRC (i c°l a zdroj)
;  ENDS       - identifik†tor konce zpr†vy

; Povely:
;  C          - kontrola mÇdia 01h - poëadavek
;  c          - kontrola mÇdia 01h - odpovàÉ
;  B          - vystavàn° bloku parametrñ BPB 02h - poëadavek
;  b          - vystavàn° bloku parametrñ BPB 02h - odpovàÉ
;  R          - áten° ze za©°zen° 04h - poëadavek
;  r          - áten° ze za©°zen° 04h - odpovàÉ
;  W          - z†pis na za©°zen° 08h - poëadavek
;  w          - z†pis na za©°zen° 08h - odpovàÉ
;  V          - z†pis na za©°zen° s verifikac° 09h - poëadavek
;  v          - z†pis na za©°zen° s verifikac° 09h - odpovàÉ


TimeOutP equ       4                        ; á°taá TIME-OUT p©i p©°jmu
TimeOutV equ       4                        ; á°taá TIME-OUT p©i vys°l†n°
TimeOutZ equ       2*18                     ; max. doba pro p©°jem odpovàdi

NUL      equ       0 ; oddàlovac° mezera
BEGIN    equ       1 ; zaá†tek zpr†vy (n†sleduje p©°jemce a odes°latel)
ENDS     equ       2 ; konec zpr†vy (p©edch†z° kontroln° souáet 2 bajty)
SHF      equ       3 ; p©echodnò p©esmykaá (zmàna inverze 1 znaku)
SHI      equ       4 ; trvalò p©esmykaá (trval† inverze dat)
REP      equ       5 ; opakov†n° (n†sleduje poáet + 8 a opakovanò znak)
BRK      equ       6 ; p©eru®en°
                     ; 07h (rezerva)


code     segment
         assume    cs:code,ds:code
         org       100h

start:
         jmp       instal                   ; instalace programu


; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
public   int28
int28:                                    ;* obsluha p©eru®en° INT 28h
;         call      intcom0                  ; obsluha portu COM
         call      extrna
         jmp       dword ptr cs:[old28]


public   int13
int13:                                    ;* obsluha p©eru®en° INT 13h
         jmp       dword ptr cs:[old13]


public   int15
int15:                                    ;* obsluha p©eru®en° INT 15h
         jmp       dword ptr cs:[old15]


public   int16
int16:                                    ;* obsluha p©eru®en° INT 15h
;         call      intcom0                  ; obsluha portu COM
         jmp       dword ptr cs:[old16]


public   int21
int21:                                    ;* obsluha p©eru®en° INT 21h
         jmp       dword ptr cs:[old21]


public   int1c
int1c:                                    ;* obsluha p©eru®en° INT 1ch
;         call      intcom0                  ; obsluha portu COM
         jmp       dword ptr cs:[old1c]


public   int08
int08:                                    ;* obsluha p©eru®en° INT 08h

; ------ obsluha á°taáñ Time-Out

         inc       byte ptr cs:[pritout]
         jnz       int082
         dec       byte ptr cs:[pritout]
int082:  inc       byte ptr cs:[vystout]
         jnz       int083
         dec       byte ptr cs:[vystout]
int083:  inc       byte ptr cs:[zprtout]
         jnz       int081
         dec       byte ptr cs:[zprtout]
int081:

; ------ obsluha á°taáe Time-Out p©i p©°jmu

         cmp       byte ptr cs:[pritout],TimeOutP ; je Time-Out p©i p©°jmu ?
         jb        int084                   ; nebyl Time-Out p©i p©°jmu
         mov       byte ptr cs:[parprij],0  ; nulov†n° p©°znaku p©°jmu
int084:

; ------ obsluha á°taáe Time-Out p©i vys°l†n°

         cmp       byte ptr cs:[vystout],TimeOutV ; je Time-Out p©i vys°l†n° ?
         jb        int085                   ; nebyl Time-Out p©i vys°l†n°
         mov       byte ptr cs:[parvys],0   ; nulov†n° p©°znaku vys°l†n°
int085:

;         call      intcom0                  ; obsluha portu COM

         call      extrna
         jmp       dword ptr cs:[old08]


public   int09
int09:                                    ;* obsluha p©eru®en° INT 09h

         jmp       dword ptr cs:[old09]


public   int5c
int5c:                                    ;* obsluha p©eru®en° INT 5ch
         jmp       dword ptr cs:[old5c]


; -----------------------------------------------------------------------------
public   extrna
extrna:                                   ;* p©°stup na disk z vnàj®ku

         push      ax

         mov       al,cs:[rinbuf]           ; átec° adresa z bufferu
         cmp       al,cs:[winbuf]           ; je nàjakò znak v bufferu ?
         jne       extrna1
         pop       ax
         ret

extrna1:
         pushf
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         push      cs
         pop       es
         push      cs
         pop       ds

;         mov       al,"4"
;         call      debch

         mov       dx,offset buffer
         call      readtxt
         jc        extrna8

;         mov       al,"A"
;         call      debch

         cmp       bl,"H"
         jne       extrna8
         mov       ds:[komnum],bh

;         mov       al,"5"
;         call      debch

         push      cs
         pop       es
         mov       bx,offset buffer
         call      dword ptr ds:[tabdisk+1+5*11]
         call      dword ptr ds:[tabdisk+5+5*11]

;         mov       al,"6"
;         call      debch

         xor       cx,cx
         mov       cl,ds:[bx]
         mov       dx,offset buffer
         mov       bh,cs:[komnum]
         mov       bl,"R"
         call      vystxt

;         mov       al,"7"
;         call      debch

extrna8:
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         popf
         pop       ax
         ret

; -----------------------------------------------------------------------------

public   debch
debch:   pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------

adrdev   dd        0                        ; adresa z†hlav° za©°zen°

; -----------------------------------------------------------------------------

public   Strateg
strateg  proc      far                    ;* obsluha rutiny strategie

         mov       word ptr cs:[adrdev],bx  ; offset adresy z†hlav° za©°zen°
         mov       word ptr cs:[adrdev+2],es ; segment adresy z†hlav° za©°zen°
;         jmp       dword ptr cs:[tabdisk+1+5*11]

;         push      bx
;         push      dx
;         push      ds
;         mov       bh,cs:[ownnum]
;         xor       bh,1
;         mov       bl,"S"
;         push      cs
;         pop       ds
;         mov       dx,offset adrdev
;         mov       cx,5
;         call      vystxt
;         pop       ds
;         pop       dx
;         pop       bx
         ret


Strateg  endp
; -----------------------------------------------------------------------------
public   Prerus
Prerus   proc      far                    ;* obsluha rutiny p©eru®en°

;         push      bx
;         push      es
;         les       bx,cs:[adrdev]
;         mov       byte ptr es:[bx+1],
;         pop       es
;         pop       bx
;
;         jmp       dword ptr cs:[tabdisk+5+5*11]

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es                       ; £schova ES

         mov       bp,2
prerus1: ;dec       bp
         ;jz        prerus4

;         mov       al,"0"
;         call      debch

         mov       di,offset buffer
         push      cs
         pop       es
         lds       si,cs:[adrdev]
         xor       cx,cx
         mov       cl,ds:[si]
         cld
         rep       movsb
         push      cs
         pop       ds
         les       di,ds:[adrdev]           ; adresa z†hlav° za©°zen°

         mov       al,es:[di+2]
         add       al,"0"
         call      debch

         mov       dx,offset buffer
         mov       bh,cs:[ownnum]
         xor       bh,1
         mov       bl,"H"
         mov       cl,es:[di]
         mov       word ptr es:[di+3],100h   ; za©°zen° OK

         cmp       byte ptr es:[di+2],1
         je        prerus6
         cmp       byte ptr es:[di+2],2
         je        prerus6
         cmp       byte ptr es:[di+2],3
         je        prerus6
         cmp       byte ptr es:[di+2],4
         je        prerus6
         cmp       byte ptr es:[di+2],8
         je        prerus6
         cmp       byte ptr es:[di+2],9
         je        prerus6
         cmp       byte ptr es:[di+2],0ch
         je        prerus6

         call      vystxt

;         mov       al,"1"
;         call      debch

         mov       word ptr es:[di+3],8102h ; za©°zen° nen° p©ipraveno

prerus2: push      cs
         pop       ds
         mov       dx,offset buffer
         call      readtxt
         jc        prerus4

;         mov       al,"2"
;         call      debch

         mov       ah,cs:[ownnum]
         xor       ah,1
         cmp       bh,ah
         jne       prerus2
         cmp       bl,"R"
         jne       prerus2
         cmp       cl,es:[di]
         jne       prerus2

;         mov       al,"3"
;         call      debch

         push      di
         mov       si,offset buffer
         cld
         rep       movsb
         pop       di

prerus6: cmp       byte ptr es:[di+2],2
         jne       prerus5
         mov       es:[di+12h],offset tabbpb
         mov       es:[di+14h],cs
prerus5: cmp       byte ptr es:[di+2],1
         jne       prerus7
         mov       byte ptr es:[di+0dh],0fdh
         mov       byte ptr es:[di+0eh],0
prerus7:

prerus4:

;                                          ;* kontrola á°sla povelu

;         cmp       byte ptr es:[bx+2],11    ; kontrola max. á°sla povelu
;         ja        prerus3                  ; chyba - nezn†mò povel
;
;         mov       word ptr es:[bx+3],8002h

;;                                          ;* kontrola, zda je inicializace
;;         mov       byte ptr es:[bx+3],7     ; chyba - nezn†mò form†t mÇdia
;;         cmp       byte ptr es:[bx+2],4     ; je inicializace ?
;;         jne       prerus3                  ; nen° inicializace
;;
;
;
;;                                          ;* funkce inicializace za©°zen°
;         mov       word ptr es:[bx+3],100h  ; n†vratovò k¢d - OK
;         mov       word ptr es:[bx+16h],offset ident
;         mov       word ptr es:[bx+18h],cs
;         mov       word ptr es:[bx+12h],1
;
;         push      ax
;         push      cx
;         push      di
;         mov       cx,512
;         les       di,es:[bx+0eh]
;         cld
;         xor       ax,ax
;         rep       stosb
;         pop       di
;         pop       cx
;         pop       ax
;
;;         mov       byte ptr es:[bx+0dh],1   ; poáet instalovanòch diskñ = 1
;;         mov       word ptr es:[bx+0eh],offset konec ; offset konce ovladaáe
;;         mov       word ptr es:[bx+10h],cs  ; segment konce ovladaáe
;;         mov       word ptr es:[bx+12h],offset tabbpb ; tabulka BPB
;;         mov       word ptr es:[bx+14h],cs  ; segment adresy tabulky BPB
;;
prerus3:
         pop       es                       ; n†vrat ES
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx                       ; n†vrat BX
         pop       ax
         ret

Prerus   endp
; -----------------------------------------------------------------------------
;        Test p©°znaku aktivity DOS
; -----------------------------------------------------------------------------
public   testakt
testakt:                                  ;* test p©°znaku aktivity DOS
                                            ; VùSTUP: ZY=DOS nen° aktivn°
         push      ds
         push      bx
         lds       bx,cs:[aktdos]           ; adresa p©°znaku aktivity DOS
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn° ?
         pop       bx
         pop       ds
         ret

; -----------------------------------------------------------------------------
;        Obsluha p©eru®en° od sÇriovÇho portu COM
; -----------------------------------------------------------------------------

public   intcom
intcom:                                   ;* obsluha p©eru®en° od portu COM

         call      intcom0                  ; obsluha portu COM

         push      ax
         mov       al,20h
         out       [20h],al                 ; uvolnàn° ©adiáe p©eru®en°
         pop       ax                       ; n†vrat AX

intcomi: iret                               ; pokud se poëaduje pokraáov†n°
                                            ; obsluhy, p©ep°®e se tato instrukce
                                            ; instrukc° NOP (90h)

         jmp       dword ptr cs:[oldcom]    ; pokraáov†n° v dal®° obsluze COM

; -----------------------------------------------------------------------------

public   intcom0
intcom0:                                  ;* obsluha portu COM

; ------ £schova registrñ

         pushf
         cli                                ; z†kaz p©eru®en°
         push      ax                       ; £schova AX
         push      si
         push      dx

; ------ áten° stavovÇho registru linky

intcom1: mov       dx,cs:[adrport]          ; adresa komunikaán°ho portu COM
         add       dx,5                     ; stavovò registr linky
         in        al,dx                    ; áten° stavovÇho registru linky
         sub       dx,5                     ; p©ij°mac° a vys°lac° registr

; ------ p©°jem znaku

         test      al,1                     ; je p©ijat znak ?
         jz        intcom6                  ; nebyl p©ijat znak
         in        al,dx                    ; p©°jem znaku
         or        al,al                    ; je znak NUL ?
         jz        intcom1                  ; je znak NUL - ignorov†n°
         mov       byte ptr cs:[pritout],0  ; inicializace á°taáe Time-Out

; ------ rozpozn†n° znaku BEGIN

         cmp       al,BEGIN                 ; je p©ijato z†hlav° zpr†vy ?
         jne       intcom3                  ; nen° to znak BEGIN
         mov       byte ptr cs:[parprij],1  ; p©°znak znaku BEGIN
         jmp       short intcom42           ; n†vrat z p©eru®en°

; ------ rozpozn†n° p©°jemce zpr†vy

intcom3: cmp       byte ptr cs:[parprij],1  ; áek† se na c°l zpr†vy ?
         jne       intcom4                  ; neáek† se na c°l zpr†vy
         cmp       al,cs:[ownnum]           ; je to vlastn° zpr†va ?
         je        intcom31                 ; je to vlastn° zpr†va
         push      ax                       ; £schova adres†ta zpr†vy
         mov       al,BEGIN                 ; identifikace zaá†tku zpr†vy
         mov       si,offset rtrbuf         ; p©enosovò buffer
         call      storebuf                 ; uloëen° znaku BEGIN do bufferu
         pop       ax
         call      storebuf                 ; uloëen° adres†ta zpr†vy do bufferu
         mov       byte ptr cs:[parprij],3  ; p©°znak ciz° zpr†vy
intcom32:jmp       short intcom1            ; opakov†n° obsluhy portñ
                                          ;* je vlastn° zpr†va
intcom31:mov       byte ptr cs:[parprij],2  ; p©°znak vlastn° zpr†vy
         jmp       short intcom42           ; n†vrat z p©eru®en°

; ------ rozpozn†n° konce zpr†vy

intcom4: mov       ah,cs:[parprij]
         cmp       al,ENDS                  ; je konec zpr†vy ?
         jne       intcom41                 ; nen° konec zpr†vy
         mov       byte ptr cs:[parprij],0  ; p©°znak ukonáen° zpr†vy

; ------ p©°jem vlastn° zpr†vy

intcom41:cmp       ah,2                     ; p©ij°m† se vlastn° zpr†va ?
         jne       intcom5                  ; nep©ij°m† se vlastn° zpr†va
         mov       si,offset rinbuf         ; p©ij°mac° buffer
         call      storebuf                 ; uloëen° znaku do bufferu
intcom42:jmp       short intcom1

; ------ p©enos bajtu pro ciz° poá°taá

intcom5: mov       si,offset rtrbuf         ; p©enosovò buffer
         call      storebuf                 ; uloëen° znaku do bufferu
intcom51:jmp       short intcom1            ; opakov†n° obsluhy portñ


; ------ vys°l†n° znaku

intcom6: test      al,20h                   ; je vys°laá p©ipraven ?
         jz        intcom9                  ; vys°laá nen° p©ipraven

; ------ pokraáov†n° ve vlastn° zpr†và

         cmp       byte ptr cs:[parvys],2   ; je ciz° zpr†va ?
         je        intcom81                 ; je ciz° zpr†va
         mov       si,offset routbuf        ; vys°lac° buffer
         call      readbuf                  ; áten° znaku z bufferu
         jc        intcom8                  ; nen° znak vlastn° zpr†vy
         cmp       al,BEGIN                 ; je zaá†tek vlastn° zpr†vy ?
         jne       intcom82                 ; nen° zaá†tek vlastn° zpr†vy
         mov       byte ptr cs:[parvys],1   ; oznaáen° vlastn° zpr†vy
         jmp       short intcom82           ; vysl†n° znaku

; ------ pokraáov†n° v ciz° zpr†và

intcom8: cmp       byte ptr cs:[parvys],1   ; je vlastn° zpr†va ?
         je        intcom84                 ; je vlastn° zpr†va
intcom81:mov       si,offset rtrbuf         ; p©enosovò buffer
         call      readbuf                  ; áten° znaku z bufferu
         jc        intcom84                 ; nen° znak ciz° zpr†vy
         cmp       al,BEGIN                 ; je zaá†tek ciz° zpr†vy ?
         jne       intcom82                 ; nen° zaá†tek ciz° zpr†vy
         mov       byte ptr cs:[parvys],2   ; oznaáen° ciz° zpr†vy
intcom82:cmp       al,ENDS                  ; je konec zpr†vy ?
         jne       intcom83                 ; nen° konec zpr†vy
         mov       byte ptr cs:[parvys],0   ; konec zpr†vy
intcom83:mov       byte ptr cs:[vystout],0  ; inicializace á°taáe Time-Out vys.
intcom84:out       dx,al                    ; vysl†n° bajtu zpr†vy

; ------ zru®en° registru p©eru®en°, áten° stavu linky

intcom9: add       dx,2                     ; stavovò registr p©eru®en°
         in        al,dx                    ; áten° stavovÇho registru p©eru®.
         test      al,1                     ; je poëadov†no dal®° p©eru®en° ?
         jz        intcom51                 ; obsluha dal®°ho p©eru®en°

; ------ n†vrat registrñ

         pop       dx
         pop       si
         pop       ax
         popf                               ; n†vrat registru p©°znakñ
         ret

; -----------------------------------------------------------------------------
;        Äten° textu z bufferu
; -----------------------------------------------------------------------------

public   readtxt
readtxt:                                  ;* áten° textu z bufferu
                                            ; VSTUP: DS:DX=buffer
                                            ; VùSTUP:BH=odes°latel
                                            ;        BL=prvn° znak (povel)
                                            ;        CX=poáet bajtñ
                                            ;        CY=nen° ë†dn† zpr†va

         push      ax
         push      dx
         push      si
         push      di
         mov       di,dx
         mov       si,offset rinbuf
         xor       cx,cx

         call      readznak
         jc        readtxt9
         mov       bh,al                    ; odes°latel
         call      readznak
         jc        readtxt9
         mov       bl,al                    ; povel

         push      bx
readtxt2:call      readpri
         jc        readtxt8
         cmp       al,ENDS
         je        readtxt3
         mov       ds:[di],al
         inc       di
         inc       cl
         jnz       readtxt2

         dec       cl
         stc
         jmp       short readtxt8

readtxt3:
readtxt8:pop       bx
readtxt9:pop       di
         pop       si
         pop       dx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Äten° k¢dovanÇho znaku z bufferu
; -----------------------------------------------------------------------------

public   readpri
readpri:                                  ;* áten° k¢dovanÇho znaku z bufferu
                                            ; VSTUP: SI=buffer
                                            ;        DX=kontroln° souáet
                                            ;        BL=p©esmykaá
                                            ; VùSTUP: AL=znak

         call      readznak
         jc        readpri2
         cmp       al,SHF
         clc
         jne       readpri2
         call      readznak
         jc        readpri2
         not       al
         or        al,al
readpri2:ret

; -----------------------------------------------------------------------------
;        Äten° bajtu z bufferu SI s áek†n°m
; -----------------------------------------------------------------------------

public   readznak
readznak:                                 ;* áten° bajtu s áek†n°m

         mov       byte ptr cs:[zprtout],0
         sti
readznk1:cmp       byte ptr cs:[zprtout],TimeOutZ
         cmc
         jb        readznk2
         call      readbuf
         jc        readznk1

readznk2:ret

; -----------------------------------------------------------------------------
;        Äten° bajtu z bufferu SI
; -----------------------------------------------------------------------------

public   readbuf
readbuf:                                  ;* áten° znaku z bufferu SI

         push      bx

         xor       al,al                    ; AL <- 0
         xor       bx,bx                    ; BX <- 0
         mov       bl,cs:[si]               ; átec° adresa z bufferu
         cmp       bl,cs:[si+1]             ; je nàjakò znak v bufferu ?
         stc                                ; p©°znak - nen° ë†dnò znak
         je        readbuf2                 ; nen° ë†dnò znak
         mov       al,cs:[si+bx+2]          ; áten° znaku z bufferu
         inc       byte ptr cs:[si]         ; zvò®en° ukazatele v bufferu
         clc                                ; p©°znak - operace OK
readbuf2:
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Test bufferu SI pro z†pis
; -----------------------------------------------------------------------------

public   storetst
storetst:                                 ;* test bufferu SI pro z†pis

         push      bx
         mov       bl,cs:[si+1]             ; z†pisov† adresa do bufferu
         cmp       bl,cs:[si]               ; je p©eteáen° bufferu ?
         stc                                ; p©°znak p©eteáen° bufferu
         je        storets2                 ; je p©eteáen° bufferu
         clc                                ; p©°znak - vys°lac° buffer OK
storets2:pop       bx
         ret

; -----------------------------------------------------------------------------
;        Vysl†n° textu
; -----------------------------------------------------------------------------

public   vystxt
vystxt:                                   ;* vysl†n° textu zpr†vy
                                            ; VSTUP: BH=p©°jemce
                                            ;        BL=prvn° znak (povel)
                                            ;        DS:DX=text
                                            ;        CX=poáet bajtñ

         push      ax
         push      bx
         push      dx
         push      si
         push      di
         mov       si,offset routbuf
         mov       al,BEGIN
         call      storebuf
         mov       al,bh
         call      storebuf
         mov       al,cs:[ownnum]
         call      storebuf
         mov       al,bl
         call      storebuf
         mov       di,dx
         xor       dx,dx
         xor       bx,bx
         jcxz      vystxt2
vystxt1: mov       al,ds:[di]
         inc       di
         call      storevys
         loop      vystxt1
vystxt2: mov       al,ENDS
         call      storebuf
;         call      intcom0
         pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Uloëen° k¢dovanÇho znaku do vys°lac°ho bufferu
; -----------------------------------------------------------------------------

public   storevys
storevys:                                 ;* uloëen° k¢dovanÇho znaku do vys.
                                            ; VSTUP: AL=znak
                                            ;        SI=buffer
                                            ;        DX=kontroln° souáet
                                            ;        BL=p©esmykaá


         cmp       al,8
         jae       storev2
         push      ax
         mov       al,SHF                   ; p©echodnò p©esmykaá
         call      storebuf
         pop       ax
         not       al
storev2:

; -----------------------------------------------------------------------------
;        Uloëen° znaku do bufferu SI
; -----------------------------------------------------------------------------

public   storebuf
storebuf:                                 ;* uloëen° znaku do bufferu SI

         push      bx
         push      ds
         push      cs
         pop       ds                       ; DS <- CS

         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[si+1]             ; z†pisov† adresa do bufferu
         mov       ds:[si+bx+2],al          ; uloëen° znaku do bufferu
         inc       byte ptr ds:[si+1]       ; zvò®en° ukazatele v bufferu
         inc       bl
         cmp       bl,ds:[si]               ; je p©eteáen° bufferu ?
         jne       storebf2                 ; nen° p©eteáen° bufferu
         inc       byte ptr ds:[si]         ; zvò®en° átec° adresy z bufferu
storebf2:
         pop       ds
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        Inicializace sÇriovÇho portu
; -----------------------------------------------------------------------------

public   initcom
initcom:                                  ;* inicializace sÇriovÇho portu COM

         pushf                              ; £schova registru p©°znakñ
         cli                                ; z†kaz p©eru®en°
         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      dx                       ; £schova DX
         push      ds                       ; £schova DS
                                          ;* nastaven° p©enosovÇ rychlosti
         mov       dx,cs:[adrport]          ; adresa portu COM
         add       dx,3                     ; ©°dic° registr linky
         mov       al,80h                   ; p©°znak bitu DLAB
         out       dx,al                    ; zapnut° sign†lu DLAB
         sub       dx,3                     ; nië®° bajt dàliáky
         mov       ax,cs:[konport]          ; dàlic° konstanta portu
         out       dx,al                    ; nastaven° nië®°ho bajtu dàliáky
         inc       dx                       ; vy®®° bajt dàliáky
         mov       al,ah                    ; vy®®° bajt dàliáky
         out       dx,al                    ; nastaven° vy®®°ho bajtu dàliáky
                                          ;* nastaven° ©°dic°ho registru linky
         add       dx,2                     ; ©°dic° registr linky
         mov       al,7
;         mov       al,3                     ; m¢d 8 bitñ bez parity, 1 stop-bit
         out       dx,al                    ; nastaven° m¢du portu
                                          ;* nastaven° ©°dic°ho registru modemu
         inc       dx                       ; ©°dic° registr modemu
         in        al,dx                    ; souáasnò stav registru modemu
         and       al,3                     ; ponech† bity ©°zen° modemu
         or        al,8                     ; nastaven° sign†lu OUT2
         out       dx,al                    ; nastaven° ©°dic°ho registru modemu
                                          ;* nulov†n° stavovÇho registru linky
         inc       dx                       ; stavovò registr linky
         in        al,dx                    ; zru®en° poëadavku od reg. linky
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; resetov†n° stavovÇho registru
                                          ;* nulov†n° stavovÇho registru modemu
         inc       dx                       ; stavovò registr modemu
         in        al,dx                    ; zru®en° poëadavku od reg. modemu
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; resetov†n° stavovÇho registru
                                          ;* nastaven° ©°dic°ho reg. p©eru®en°
         sub       dx,5                     ; registr masky p©eru®en°
         mov       al,0fh                   ; povolena v®echna p©eru®en°
         out       dx,al                    ; nastaven° ©°dic°ho reg. p©eru®en°
                                          ;* uvolnàn° vys°laáe a p©ij°maáe
         dec       dx                       ; datovò registr
         in        al,dx                    ; zru®en° dat v p©ij°mac°m bufferu
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; aktivace vys°laáe
                                          ;* nastaven° vektoru p©eru®en°
         xor       bx,bx                    ; BX <- 0
         mov       ds,bx                    ; DS <- 0
         mov       bl,cs:[intport]          ; á°slo p©eru®en° INT od COM
         add       bx,bx                    ; BX * 2
         add       bx,bx                    ; BX * 4
         mov       word ptr ds:[bx],offset intcom ; offset adresy obsluhy COM
         mov       ds:[bx+2],cs             ; segment adresy obsluhy COM
                                          ;* nastaven° registru p©eru®en°
         xor       dx,dx                    ; DX <- 0
         mov       dl,cs:[portint]          ; adresa registru p©eru®en°
         inc       dx                       ; adresa masky p©eru®en°
         mov       bl,cs:[maskint]          ; poëadovan† maska registru p©eru®.
         not       bl                       ; polarita - povolen° p©eru®en°
         in        al,dx                    ; registr p©eru®en°
         and       al,bl                    ; povolen° p©eru®en° od portu COM
         out       dx,al                    ; novÇ nastaven° registru p©eru®en°

         pop       ds
         pop       dx
         pop       bx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------
;        Data rezidentn° á†sti programu
; -----------------------------------------------------------------------------

ownnum   db        "A"                      ; vlastn° oznaáen° poá°taáe
komnum   db        "B"                      ; á°slo protistanice

; ------ data pro inicializaci portu COM

port     dw        0                        ; á°slo portu COM
adrport  dw        3f8h                     ; adresa portu COM
konport  dw        4                        ; konstanta dàliáky portu
intport  db        0ch                      ; á°slo p©eru®en° INT od COM
portint  db        20h                      ; adresa ©adiáe p©eru®en°
maskint  db        10h                      ; maska registru p©eru®en°

; ------ data pro vys°l†n° a p©°jem zpr†v

parprij  db        0                      ;* p©°znaky p©ij°maáe
                                            ; 0=p©ij°maá v klidu, nedefin. stav
                                            ; 1=byl p©ijat znak BEGIN
                                            ; 2=prob°h† p©°jem vlastn° zpr†vy
                                            ; 3=prob°h† p©°jem ciz° zpr†vy

parvys   db        0                      ;* p©°znaky vys°laáe
                                            ; 0=vys°laá je volnò
                                            ; 1=vys°l† se vlastn° zpr†va
                                            ; 2=vys°l† se ciz° zpr†va

pritout  db        0                        ; á°taá pro TIME-OUT p©i p©°jmu
vystout  db        0                        ; á°taá pro TIME-OUT p©i vys°l†n°
zprtout  db        0                        ; á°taá pro TIME-OUT odpovàdi

; ------ p©enosovÇ buffery (nemànit po©ad° poloëek !)

rinbuf   db        0                        ; átec° adresa z p©ij°mac°ho bufferu
winbuf   db        0                        ; z†pisov† adresa do p©ij°m. bufferu
inbuf    db        256 dup(0)               ; p©ij°mac° buffer

routbuf  db        0                        ; átec° adresa z vys°lac°ho bufferu
woutbuf  db        0                        ; z†pisov† adresa do vys°l. bufferu
outbuf   db        256 dup(0)               ; vys°lac° buffer

rtrbuf   db        0                        ; átec° adresa z p©enosovÇho bufferu
wtrbuf   db        0                        ; z†pisov† adresa do p©enos. bufferu
trbuf    db        256 dup(0)               ; p©enosovò buffer

buffer   db        256 dup(0)               ; pracovn° p©enosovò buffer



tabbpb   dw        offset bpb             ;* tabulka adres parametrñ BIOS disku

bpb      label     byte                   ;* blok parametrñ BIOS BPB disku

         dw        512                      ; 00h: poáet bajtñ na sektor
         db        2                        ; 02h: poáet sektorñ na alok. blok
         dw        1                        ; 03h: zav†dàc° a rezerv. sektory
         db        2                        ; 05h: poáet alokaán°ch tabulek FAT
         dw        70h                      ; 06h: max. poáet pol. z†kl. adres.
         dw        720                      ; 08h: celk. poáet sektorñ na mÇdiu
         db        0fdh                     ; 0ah: popisovaá mÇdia
         dw        2                        ; 0bh: poáet sektorñ v jednÇ FAT
                                          ;* od DOS 3.00
         dw        9                        ; 0dh: poáet sektorñ na stopu
         dw        2                        ; 0fh: poáet hlav
         dd        0                        ; 11h: poáet skrytòch sektorñ
                                          ;* od DOS 4.00
         dd        0                        ; 15h: celkovò poáet sektorñ
         db        7 dup(0)                 ; 19h: 7 bajtñ rezervov†no

; -----------------------------------------------------------------------------

tabread  db        26 dup(0)                ; tabulka diskñ pro áten° (=1)
tabwrite db        26 dup(0)                ; tabulka diskñ pro z†pis (=1)

tabext   db        26*2 dup(0)              ; tabulka extern°ch diskñ
                                            ; (1.bajt - poá°taá, 2.bajt - disk)

extdisk  db        0                        ; poáet extern°ch diskñ

pocdisk  db        0                        ; poáet diskñ v systÇmu
pocdev   db        0                        ; poáet blokovòch za©°zen°

topdev   dd        0                        ; adresa prvn°ho za©°zen° DOS

aktdos   dd        0                        ; adresa p©°znaku aktivity DOS

verzeos  dw        0                        ; verze operaán°ho systÇmu

adrint   label     word                     ; tabulka adres vektorñ p©eru®en°
old28    dw        offset int28
         dw        0
old13    dw        offset int13
         dw        0
old15    dw        offset int15
         dw        0
old16    dw        offset int16
         dw        0
old21    dw        offset int21
         dw        0
old1c    dw        offset int1c
         dw        0
old08    dw        offset int08
         dw        0
old09    dw        offset int09
         dw        0
old5c    dw        offset int5c
         dw        0
oldcom   dw        offset intcom
         dw        0

tabdisk  db        26 dup(11 dup(0))        ; tabulka diskñ
                                            ; STRUKTURA: 0: poáet diskñ
                                            ;            1: adresa strategie
                                            ;            5: adresa p©eru®en°
                                            ;            9: offset adr. ovladaáe
tabdisk0 label     byte                     ; konec tabulky diskñ

; *****************************************************************************
;
;                          Instalace programu
;
; *****************************************************************************

public   instal
instal:
                                          ;* £vodn° hl†®en° o programu
         mov       si,offset uvtxt          ; £vodn° text
         call      DispTxt                  ; zobrazen° £vodn°ho textu

                                          ;* zji®tàn° verze operaán°ho systÇmu
         mov       ah,30h
         int       21h                      ; zji®tàn° verze operaán°ho systÇmu
         xchg      ah,al
         mov       ds:[verzeos],ax          ; £schova verze operaán°ho systÇmu

                                          ;* dek¢dov†n° zadanòch parametrñ
         call      DekodPar                 ; dek¢dov†n° zadanòch parametrñ
         jnc       instal3                  ; parametry zad†ny OK

                                          ;* chyba zad†n° parametrñ
instal1: mov       si,offset hlptxt         ; n†povàda
instal2: call      DispTxt                  ; zobrazen° textu n†povàdy
         mov       ax,4c01h
         int       21h                      ; n†vrat s chybou

                                          ;* zji®tàn° adresy portu COM
instal3: mov       bx,ds:[port]             ; á°slo portu COM
         add       bx,bx                    ; á°slo portu COM * 2
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[bx+400h]          ; adresa portu COM
         pop       ds
         mov       si,offset errtxt1        ; chyba - nenainstalov†n
         or        ax,ax                    ; je port nainstalov†n ?
         jz        instal2                  ; chyba - port nenainstalov†n
         mov       ds:[adrport],ax          ; £schova adresy portu COM

                                          ;* nastaven° á°sla a masky p©eru®en°
         test      byte ptr ds:[port],1     ; je port COM1,COM3 nebo COM2,COM4 ?
         mov       byte ptr ds:[intport],0ch ; p©eru®en° INT pro COM1 a COM3
         mov       byte ptr ds:[portint],20h ; adresa ©adiáe p©eru®. COM1, COM3
         mov       byte ptr ds:[maskint],10h ; maska registru p©er. COM1, COM3
         jz        instal4                  ; je port COM1 nebo COM3
         mov       byte ptr ds:[intport],0bh ; p©eru®en° INT pro COM2 a COM4
         mov       byte ptr ds:[maskint],8  ; maska registru p©er. COM2, COM4

                                          ;* nalezen° prvn°ho za©°zen°
instal4: call      srcdev                   ; adresa prvn°ho za©°zen°
         mov       si,offset errtxt2        ; chybovÇ hl†®en°
         jc        instal2                  ; nenalezeno-chybnò operaán° systÇm

                                          ;* nalezen° ovladaáe COMLINK
         cmp       byte ptr ds:[extdisk],0  ; jsou nàjakÇ extern° disky ?
         je        instal6                  ; nen° ë†dnò extern° disk
         call      srccom                   ; nalezen° volnÇho ovladaáe COMLINK
         mov       si,offset errtxt3        ; chyba - nenalezen COMLINK.SYS
         jc        instal2                  ; zobrazen° chyby
         mov       al,es:[bx+0ah]           ; poáet instalovanòch diskñ
         mov       si,offset errtxt4        ; chyba - malò poáet diskñ
         cmp       al,ds:[extdisk]          ; je dostateánò poáet diskñ ?
         jb        instal2                  ; nen° dostateánò poáet diskñ

; -----------                             ;* z tohoto m°sta jië nen° n†vrat

                                          ;* instalace obsluhy COMLINK.SYS
instal5: call      instcom                  ; instalace obsluhy COMLINK.SYS

                                          ;* inicializace tabulky diskñ
instal6: call      initdisk                 ; inicializace tabulky diskñ


;
;         jnc       instal3                  ; ovladaá nalezen OK

;         mov       dx,offset errtxt3        ; chybovÇ hl†®en°
;         mov       ah,9
;         int       21h                      ; zobrazen° chybovÇho hl†®en°
;         mov       ax,4c02h
;         int       21h                      ; n†vrat s chybou 2

;instal3:

         cli                                ; z†kaz p©eru®en°

;
;         push      cs
;         pop       ds

;         call      instint                  ; instalace obsluh p©eru®en°


;         mov       ax,350ch
;         int       21h
;         mov       word ptr ds:[oldcom],bx
;         mov       word ptr ds:[oldcom+2],es
;         mov       dx,offset intcom
;         mov       ax,250ch
;         int       21h
;         mov       dx,offset intcom
;         mov       ax,250bh
;         int       21h


;         call      initcom                  ; inicializace sÇriovÇho portu COM

comx0:

comx1:

;         mov       si,offset rinbuf         ; p©ij°mac° buffer
;         call      readbuf                  ; p©ipraven znak ?
;         jc        comx3
;
;comx2:   int       29h
;
;comx3:
;         mov       ah,1
;         int       16h
;         jz        comx1
;
;
;         mov       dx,offset textbuf
;         mov       si,dx
;         add       si,2
;         mov       ah,10
;         int       21h
;
;
;         xor       cx,cx
;         mov       cl,ds:[textbuf+1]
;         or        cx,cx
;         jne       comx4
;
;         lds       dx,dword ptr ds:[oldcom]
;         mov       ax,250ch
;         int       21h
;         int       20h
;
;comx4:
;         push      si
;         mov       al,BEGIN
;         mov       si,offset routbuf
;         call      storebuf
;         pop       si
;
;         lodsb
;         and       al,not 20h
;         push      si
;         mov       si,offset routbuf
;         call      storebuf
;         pop       si
;
;         push      si
;         mov       al,ds:[ownnum]
;         mov       si,offset routbuf
;         call      storebuf
;         pop       si
;
;         dec       cx
;         jz        comx6
;
;comx5:   lodsb
;         push      si
;         mov       si,offset routbuf
;         call      storebuf
;         pop       si
;         loop      comx5
;comx6:
;         mov       al,ENDS
;         mov       si,offset routbuf
;         call      storebuf
;
;         call      intcom0
;
;         jmp       short comx1
;
;
;         mov       dx,offset instal         ; konec rezidentn° á†sti
;         int       27h


         mov       ax,4c00h
         int       21h



; -----------------------------------------------------------------------------
;        Nalezen° adresy prvn°ho za©°zen°
; -----------------------------------------------------------------------------

PUBLIC   srcdev
SrcDev   PROC      NEAR                   ;* nalezen° adresy prvn°ho za©°zen°
                                            ; VSTUP: DS=CS
                                            ; VùSTUP: ES:BX=adresa za©°zen°
                                            ;         CY=nekompatibiln° systÇm

         push      ax
         push      cx
         push      si
         push      di

                                          ;* zji®tàn° segmentu modulu DOS.SYS
         mov       ah,52h
         int       21h                      ; poskytnut° tabulky informac°
         lea       di,[bx+18h]              ; zaá†tek pro hled†n°
         mov       cx,20h                   ; poáet pokusñ o nalezen° NUL:

                                          ;* test, zda je za©°zen° NUL
SrcDev1: mov       si,offset devnul         ; text nulovÇho za©°zen°
         cld
         push      di
         push      cx
         mov       cl,8                     ; poáet znakñ k porovn†n°
         repe      cmpsb                    ; porovn†n° jmÇna NUL
         pop       cx
         pop       di
         je        SrcDev8                  ; za©°zen° nalezeno
         inc       di
         loop      SrcDev1                  ; dal®° test
         stc
         jmp       short SrcDev9            ; chyba - nenalezen

SrcDev8: les       bx,es:[di-10]            ; adresa prvn°ho za©°zen°
         mov       word ptr ds:[topdev],bx  ; £schova offsetu prvn°ho za©°zen°
         mov       word ptr ds:[topdev+2],es ; £schova segmentu prvn°ho za©°zen°

SrcDev9: pop       di
         pop       si
         pop       cx
         pop       ax
         ret

SrcDev   ENDP

; -----------------------------------------------------------------------------
;        Nalezen° prvn°ho volnÇho ovladaáe COMLINK
; -----------------------------------------------------------------------------
public   srccom
srccom:                                   ;* nalezen° ovladaáe COMLINK.SYS
                                            ; VùSTUP: ES:BX=ovladaá COMLINK.SYS
                                            ;         CY=nenalezen

                                          ;* £schova registrñ
         push      cx
         push      dx
         push      si
         push      di

                                          ;* inicializace registrñ
         xor       dx,dx                    ; DX <- 0 segment COMLINK.SYS
         les       bx,cs:[topdev]           ; adresa prvn°ho za©°zen°
         cld

                                          ;* test, zda je blokovÇ za©°zen°
srccom1: test      byte ptr es:[bx+5],80h   ; je to blokovÇ za©°zen° ?
         jnz       srccom2                  ; nen° to blokovÇ za©°zen° - dal®°

                                          ;* kontrola, zda je COMLINK.SYS
         push      cx
         lea       di,[bx+12h]              ; offset identifikace COMLINK.SYS
         mov       si,offset comlink        ; identifikace z†hlav°
         mov       cx,offset(comlink0-comlink) ; dÇlka identifikace
         repe      cmpsb                    ; porovn†n° identifik†toru
         pop       cx
         jne       srccom2                  ; nen° to volnò ovladaá COMLINK.SYS
         mov       dx,es                    ; £schova segmentu
         mov       cx,bx                    ; £schova offsetu

                                          ;* nastaven° na dal®° ovladaá za©°zen°
srccom2: les       bx,es:[bx]               ; adresa n†sleduj°c°ho ovladaáe
         cmp       bx,-1
         je        srccom3                  ; je konec
         mov       si,es                    ; segment dal®°ho ovladaáe
         inc       si                       ; je = -1 ?
         jne       srccom1                  ; nen° konec - dal®° ovladaá

                                          ;* test, zda je poëadovanò ovladaá
srccom3: mov       bx,cx                    ; offset ovladaáe COMLINK.SYS
         mov       es,dx                    ; segment ovladaáe COMLINK.SYS
         or        dx,dx                    ; byl ovladaá nalezen ?
         jnz       srccom4                  ; ovladaá COMLINK.SYS nalezen
         stc                                ; p©°znak - ovladaá nenalezen

srccom4: pop       di
         pop       si
         pop       dx
         pop       cx
         ret

; -----------------------------------------------------------------------------
;        Instalace obsluhy za©°zen° COMLINK (ES:BX)
; -----------------------------------------------------------------------------
public   Instcom
Instcom:                                  ;* instalace obsluhy COMLINK (ES:BX)

                                          ;* instalace obsluhy strategie
         mov       si,es:[bx+6]             ; offset rutiny strategie
         mov       byte ptr es:[bx+si],0eah ; instrukce JMP FAR
         mov       word ptr es:[bx+si+1],offset Strateg
         mov       word ptr es:[bx+si+3],cs

                                          ;* instalace obsluhy p©eru®en°
         mov       si,es:[bx+8]             ; offset rutiny p©eru®en°
         mov       byte ptr es:[bx+si],0eah ; instrukce JMP FAR
         mov       word ptr es:[bx+si+1],offset Prerus
         mov       word ptr es:[bx+si+3],cs

         mov       byte ptr es:[bx+1ah],"0" ; p©°znak, ëe ovladaá je jië pouëit

         ret

; -----------------------------------------------------------------------------
;        Inicializace tabulky diskñ
; -----------------------------------------------------------------------------
PUBLIC   InitDisk
InitDisk:                                 ;* inicializace tabulky diskñ

         push      es
         mov       di,offset tabdisk        ; tabulka diskñ
         les       bx,ds:[topdev]           ; adresa prvn°ho za©°zen° DOS
         xor       cx,cx                    ; á°taá diskñ a ovladaáñ
                                          ;* adresa n†sleduj°c°ho za©°zen°
initdsk1:les       bx,es:[bx]               ; adresa n†sleduj°c°ho za©°zen°
         mov       ax,es                    ; segment adresy za©°zen°
         inc       ax                       ; je to posledn° za©°zen° (-1) ?
         jz        initdsk5                 ; je to posledn° za©°zen°
         cmp       bx,-1                    ; je to posledn° za©°zen° ?
         je        initdsk5                 ; je to posledn° za©°zen°
                                          ;* test, zda jsou nàjakÇ disky
         test      byte ptr es:[bx+5],80h   ; je to diskovÇ za©°zen° ?
         jnz       initdsk1                 ; nen° to diskovÇ za©°zen° - dal®°
         mov       al,es:[bx+0ah]           ; poáet instalovanòch diskñ
         or        al,al                    ; je nàjakò disk ?
         jz        initdsk1                 ; nen° ë†dnò disk
                                          ;* uloëen° informac° o za©°zen°
         add       cl,al                    ; zvò®en° á°taáe diskñ
         inc       ch                       ; zvò®en° á°taáe ovladaáñ
         mov       ds:[di],al               ; uloëen° poátu obsluhovanòch diskñ
         mov       ax,es:[bx+6]             ; offset rutiny strategie
         mov       ds:[di+1],ax             ; offset rutiny strategie
         mov       ds:[di+3],es             ; segment rutiny strategie
         mov       ax,es:[bx+8]             ; offset rutiny p©eru®en°
         mov       ds:[di+5],ax             ; offset rutiny p©eru®en°
         mov       ds:[di+7],es             ; segment rutiny p©eru®en°
         mov       ds:[di+9],bx             ; offset z†hlav° za©°zen°
         add       di,11                    ; adresa dal®°ho za©°zen°
         cmp       di,offset tabdisk0       ; je tabulka jië pln† ?
         jb        initdsk1                 ; tabulka nen° je®tà pln†

initdsk5:mov       ds:[pocdisk],cl          ; uloëen° poátu instalovanòch diskñ
         mov       ds:[pocdev],ch           ; poáet blokovòch za©°zen°
         pop       es
         ret

; -----------------------------------------------------------------------------
;        Instalace obsluh p©eru®en°
; -----------------------------------------------------------------------------
public   instint
instint:                                  ;* instalace obsluh p©eru®en°

         push      es
         mov       cx,offset(tabint0-tabint); poáet instalovanòch p©eru®en°
         mov       di,offset adrint         ; tabulka adres obsluh p©eru®en°
         mov       si,offset tabint         ; tabulka instalovanòch p©eru®en°
instint1:mov       al,ds:[si]               ; á°slo p©eru®en°
         mov       ah,35h
         int       21h                      ; poskytnut° adresy p©eru®en°
         mov       dx,ds:[di]               ; nov† adresa p©eru®en°
         mov       ds:[di],bx               ; uloëen° pñvodn° adresy p©eru®en°
         mov       ds:[di+2],es             ; uloëen° pñvodn°ho segmentu
         add       di,4                     ; zvò®en° ukl†dac° adresy
         lodsb                              ; á°slo p©eru®en°
         mov       ah,25h
         int       21h                      ; instalace novÇ obsluhy p©eru®en°
         loop      instint1                 ; instalace dal®°ho p©eru®en°
                                          ;* zji®tàn° p©°znaku aktivity DOS
         mov       ah,34h
         int       21h                      ; poskytnut° p©°znaku aktivity DOS
         mov       word ptr ds:[aktdos],bx  ; offset p©°znaku aktivity
         mov       word ptr ds:[aktdos+2],es; segment p©°znaku aktivity

         pop       es
         ret

; -----------------------------------------------------------------------------
;        Dek¢dov†n° zadanòch parametrñ
; -----------------------------------------------------------------------------

PUBLIC   DekodPar
DekodPar PROC      NEAR                     ; dek¢dov†n° zadanòch parametrñ

                                          ;* p©°prava textu parametrñ
         cld                                ; smàr nahoru
         mov       si,81h                   ; zaá†tek parametrñ
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[80h]              ; poáet znakñ
         mov       byte ptr ds:[si+bx],0    ; oznaáen° konce textu

                                          ;* vypustàn° mezer
DekodPr1:call      DekodCh                  ; áten° znaku z textu parametrñ
         cmc
         jnc       DekodPr9                 ; nen° dal®° znak
         cmp       al," "                   ; je oddàlovac° mezera ?
         jbe       DekodPr1                 ; oddàlovac° mezera - ignorov†n°

                                          ;* parametr "=x" - oznaáen° poá°taáe
         cmp       al,"="                   ; je parametr "=x" ?
         jne       DekodPr2                 ; nen° parametr "=x"
         call      DekodDsk                 ; naáten° oznaáen° disku
         jc        DekodPr8                 ; chybnÇ zad†n° oznaáen° poá°taáe
         mov       ds:[ownnum],al           ; oznaáen° vlastn°ho poá°taáe
         jmp       short DekodPr1           ; dal®° parametr

                                          ;* parametr "#c" - á°slo portu COM
DekodPr2:cmp       al,"#"                   ; je parametr "#c" ?
         jne       DekodPr3                 ; nen° parametr "#c"
         call      DekodNm                  ; áten° á°sla portu COMc
         jc        DekodPr8                 ; chybnÇ zad†n° á°sla portu COM
         or        al,al                    ; je á°slo = 0 ?
         jz        DekodPr8                 ; chybnÇ zad†n°
         cmp       al,4
         ja        DekodPr8                 ; chybnÇ zad†n° á°sla portu
         dec       al
         mov       byte ptr ds:[port],al    ; á°slo portu COM
         add       al,"1"                   ; p©evod zpàt na znak ASCII
         mov       ds:[errtxt10],al         ; á°slo portu COM
DekodP11:jmp       short DekodPr1           ; dal®° parametr


                                          ;* chybnÇ zad†n° parametrñ
DekodPr8:stc
DekodPr9:ret

                                          ;* parametr "!n" - p©enosov† rychlost
DekodPr3:cmp       al,"!"                   ; je parametr "!n" ?
         jne       DekodPr4                 ; nen° parametr "!n"
         call      DekodNum                 ; áten° á°sla koeficientu
         jc        DekodPr8                 ; chyba zad†n° á°sla
         or        ax,ax                    ; je á°slo = 0 ?
         jz        DekodPr8                 ; je = 0 - chyba
         mov       ds:[konport],ax          ; konstanta pro nastaven° dàliáky
         jmp       short DekodP11           ; dal®° parametr

                                          ;* parametr "$ABC..." - ext. disky
DekodPr4:cmp       al,"$"                   ; je parametr "$ABC.." ?
         jne       DekodPr5                 ; nen° parametr "$ABC..."
DekodP42:call      DekodDsk                 ; naáten° oznaáen° disku
         jc        DekodP11                 ; nen° dal®° disk
         sub       al,"A"                   ; á°slo disku v tabulce
         xor       bx,bx
         mov       bl,al                    ; á°slo disku
         mov       byte ptr ds:[tabread+bx],1 ; moënÇ áten° z disku
         mov       byte ptr ds:[tabwrite+bx],1; moënò z†pis na disk
         jmp       short DekodP42           ; dal®° disk

                                          ;* parametr "&DEF..." - áten° z disku
DekodPr5:cmp       al,"&"                   ; je parametr "&DEF..." ?
         jne       DekodPr6                 ; nen° parametr "&DEF..."
DekodP52:call      DekodDsk                 ; naáten° oznaáen° disku
         jc        DekodP11                 ; nen° dal®° disk
         sub       al,"A"                   ; á°slo disku v tabulce
         xor       bx,bx
         mov       bl,al                    ; á°slo disku
         mov       byte ptr ds:[tabread+bx],1 ; moënÇ áten° z disku
         jmp       short DekodP52           ; dal®° disk

                                          ;* parametr "@MNOP..." - ext. disky
DekodPr6:cmp       al,"@"                   ; je parametr "@MNOP..." ?
         jne       DekodPr8                 ; nen° parametr "@MNOP..." - chyba
DekodP62:call      DekodDsk                 ; naáten° oznaáen° stanice
         jc        DekodP11                 ; nen° dal®° disk
         mov       ah,al                    ; £schova oznaáen° stanice
         call      DekodDsk                 ; naáten° oznaáen° disku
         jc        DekodPr8                 ; chybnÇ zad†n° disku
         xchg      ah,al                    ; z†màna oznaáen° stanice a disku
         xor       bx,bx
         mov       bl,ds:[extdisk]          ; poáet extern°ch diskñ
         add       bx,bx                    ; poáet ext. diskñ * 2
         mov       word ptr ds:[bx+tabext],ax ; extern° stanice a disk
         inc       byte ptr ds:[extdisk]    ; zvò®en° á°taáe diskñ
         jmp       short DekodP62           ; dal®° disk

DekodPar ENDP

; -----------------------------------------------------------------------------
;        Äten° oznaáen° disku
; -----------------------------------------------------------------------------

PUBLIC   DekodDsk
DekodDsk PROC      NEAR

         call      DekodCh                  ; naáten° oznaáen° disku
         jc        DekodDs2                 ; nen° dal®° znak
         cmp       al,"A"
         jb        DekodDs1                 ; nen° platnÇ oznaáen° disku
         cmp       al,"Z"+1
         cmc
         jnc       DekodDs2                 ; je platnÇ oznaáen° disku
DekodDs1:dec       si                       ; n†vrat posledn°ho znaku
DekodDs2:ret

DekodDsk ENDP

; -----------------------------------------------------------------------------
;        Äten° á°selnÇho parametru (AX)
; -----------------------------------------------------------------------------

PUBLIC   DekodNum
DekodNum PROC      NEAR

         push      cx
         push      dx
         xor       cx,cx                    ; st©adaá á°sla
         call      DekodNm                  ; áten° prvn° á°slice
         jc        DekodNm6                 ; nen° á°slice
DekodNm1:push      ax
         mov       ax,10
         mul       cx                       ; st©adaá á°sla * 10
         mov       cx,ax
         pop       ax
         xor       ah,ah
         add       cx,ax                    ; p©iáten° naátenÇ á°slice
         call      DekodNm                  ; naáten° dal®° á°slice
         jnc       DekodNm1                 ; p©iáten° á°slice
         clc                                ; p©°znak operace OK
DekodNm6:mov       ax,cx                    ; naátenÇ á°slo
         pop       dx
         pop       cx
         ret

DekodNum ENDP

; -----------------------------------------------------------------------------
;        Äten° á°slice
; -----------------------------------------------------------------------------

PUBLIC   DekodNm
DekodNm  PROC      NEAR

         call      DekodCh                  ; áten° znaku z textu
         jc        DekodNm3                 ; nen° dal®° znak
         cmp       al,"9"+1
         cmc
         jb        DekodNm2                 ; nen° á°slice
         sub       al,"0"                   ; korekce na bin†rn° á°slo
         jnc       DekodNm3                 ; je á°slice
DekodNm2:dec       si                       ; n†vrat chybnÇho znaku
DekodNm3:ret

DekodNm   ENDP

; -----------------------------------------------------------------------------
;        Äten° znaku z textu parametrñ
; -----------------------------------------------------------------------------

PUBLIC   DekodCh
DekodCh  PROC      NEAR

         lodsb                              ; naáten° znak z parametrñ

                                          ;* p©evod na velkÇ p°smeno
         cmp       al,"a"
         jb        DekodCh1                 ; nen° malÇ p°smeno
         cmp       al,"z"
         ja        DekodCh1                 ; nen° malÇ p°smeno
         sub       al,32                    ; p©evod na velkÇ p°smeno

                                          ;* n†hrada tabel†toru mezerou
DekodCh1:cmp       al,9                     ; je tabel†tor ?
         jne       DekodCh2                 ; nen° tabel†tor
         mov       al," "                   ; n†hrada tabel†toru mezerou

                                          ;* test konce textu
DekodCh2:cmp       al," "                   ; je konec textu ?
         jae       DekodCh3                 ; nen° konec textu
         dec       si                       ; n†vrat posledn°ho znaku

DekodCh3:ret

DekodCh  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° textu CS:SI
; -----------------------------------------------------------------------------

PUBLIC   DispTxt
DispTxt  PROC      NEAR

         push      ax
         push      si
DispTxt1:mov       al,cs:[si]               ; znak k zobrazen°
         inc       si                       ; zvò®en° ukazatele textu
         or        al,al                    ; je jië konec textu ?
         jz        DispTxt2                 ; je konec textu
         call      DispChar                 ; zobrazen° znaku
         jmp       short DispTxt1           ; dal®° znak
DispTxt2:pop       si
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° znaku
; -----------------------------------------------------------------------------

PUBLIC   DispChar
DispChar PROC      NEAR

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen°
         mov       ah,2
         int       21h                      ; zobrazen° znaku
         pop       dx
         pop       ax
         ret

DispChar ENDP

; -----------------------------------------------------------------------------
;        Data pro inicializaci programu
; -----------------------------------------------------------------------------

tabint   db        28h,13h,15h,16h,21h,1ch,8,9,5ch ; tabulka instal. p©eru®en°
         db        0ch                      ; vektor p©eru®en° INT portu COM
tabint0  label     byte

devnul   db        'NUL     '               ; nulovÇ za©°zen°

comlink  db        '$$COML$$1'              ; identifikace COMLINK.SYS
comlink0 label     byte

uvtxt    db        'COMLINK verze 1.0; (c) Miroslav Nemecek',13,10,0

hlptxt   db        'Parametry: =x     - tato stanice bude v siti',13,10
         db        '                    oznacena pismenem x (x=A az Z)',13,10
         db        '           #c     - spojeni pres port COMc (c=1 az 4)',13,10
         db        '           !n     - koeficient prenosove rychlosti',13,10
         db        '                    n = 115200/prenosova rychlost',13,10
         db        '           $ABC...- k vlastnim diskum A,B,C, ... je',13,10
         db        '                    mozny pristup pro cteni i zapis',13,10
         db        '           &DEF...- k vlastnim diskum D,E,F, ... je',13,10
         db        '                    mozny pristup pro cteni',13,10
         db        '           @MNOP..- disk N stanice M bude pristupny',13,10
         db        '                    jako disk 1 (1. rezervovany disk)',13,10
         db        '                  - disk P stanice O bude pristupny',13,10
         db        '                    jako disk 2 (2. rezervovany disk)',13,10
         db        ' - disky a stanice se oznacuji pismeny A az Z',13,10
         db        0

errtxt1  db        'Port COM'
errtxt10 db        '1 neni nainstalovan !',13,10,0

errtxt2  db        'Nekompatibilni operacni system !',13,10,0

errtxt3  db        'Nenalezen COMLINK.SYS !',13,10,0
errtxt4  db        'Maly pocet disku COMLINK.SYS !',13,10,0

code     ends
         end       start

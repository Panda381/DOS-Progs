
; *****************************************************************************
;
;                  AutomatickÇ parkov†n° pevnòch diskñ
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h                     ; p©eklad k¢du jako program .COM

IDENTDL  EQU       9bh                      ; identifikace programu v DL
IDENTBX  EQU       8a36h                    ; identifikace programu v BX
IDENTRBX EQU       5794h                    ; navr†cen† identifikace v BX

Autopark:jmp       Instal                   ; skok na instalaci programu

Doba     dw        182                      ; doba pro parkov†n° (0=vypnuto)
Citac    dw        182                      ; á°taá doby pro autoparkov†n°
Old13    dd        0                        ; adresa pñvodn° obsluhy INT 13h
Old08    dd        0                        ; adresa pñvodn° obsluhy INT 08h
Param    db        80h                      ;   bit 0: prob°h† obsluha INT 13h
                                            ;   bit 1: prob°h† obsluha parkov†n°
                                            ;   bit 3: 1=jsou 2 disky
                                            ;   bit 4: 1=zad†na parkovac° doba
                                            ;   bit 7: nen° poëadov†no parkov†n°

Parkc0   dw        0                        ; parkovac° stopa disku 0
Parkc1   dw        0                        ; parkovac° stopa disku 1

; -----------------------------------------------------------------------------
;        obsluha INT 13h
; -----------------------------------------------------------------------------

int13    proc      far                    ;* obsluha p©eru®en° INT 13h

; ------ obsluha rezidentn°ho modulu

         cmp       ah,0
         jne       Int130                   ; funkce resetu disku
         cmp       dl,IDENTDL               ; je identifikace v DL ?
         jne       Int130                   ; nen° identifikace v DL
         cmp       bx,IDENTBX               ; je identifikace v BX ?
         jne       Int130                   ; nen° idnetifikace v BX
         mov       bx,IDENTRBX              ; n†vratovò identifik†tor BX
         and       byte ptr cs:[Param],not 80h ; zru®en° poëadavku parkov†n°
         mov       cs:[Citac],cx            ; inicializace á°taáe
         xchg      cs:[Doba],cx             ; uloëen° parkovac° doby
         ret       +2

; ------ zah†jen° mà©en° doby pro parkov†n°

Int130:  or        byte ptr cs:[Param],1    ; nastaven° p©°znaku obsluhy INT 13h
         or        dl,dl                    ; je p©°stup na pevnò disk ?
         jns       int131                   ; nen° p©°stup na pevnò disk
         test      byte ptr cs:[Param],4    ; je funkce vypnuta ?
         jnz       Int131                   ; funkce je vypnuta
         push      ax
         mov       ax,cs:[Doba]             ; doba k parkov†n°
         mov       cs:[citac],ax            ; inicializace á°taáe pro parkov†n°
         pop       ax

; ------ pñvodn° obsluha INT 13h

int131:  call      int13x                   ; vol†n° pñvodn° obsluhy INT 13h
         pushf                              ; £schova navr†cenòch p©°znakñ
         and       byte ptr cs:[Param],not 1; zru®en° p©°znaku obsluhy INT 13h
         popf                               ; n†vrat navr†cenòch p©°znakñ
         ret       +2                       ; n†vrat bez obnoven° p©°znakñ

int13    endp

; --------------------- vol†n° pñvodn° obsluhy INT 13h ------------------------
int13x:  pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vol†n° pñvodn° obsluhy INT 13h
         ret

; -----------------------------------------------------------------------------
;        áasov†n° pro automatickÇ parkov†n°
; -----------------------------------------------------------------------------

int08    PROC      FAR
                                         ;* obsluha p©eru®en° INT 08h

         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old08]     ; vol†n° pñvodn° obsluhy INT 08h
         cmp       word ptr cs:[citac],0    ; je á°taá doby parkov†n° jië 0 ?
         je        int081                   ; je jië dosaëeno 0 á°taáe doby
         dec       word ptr cs:[citac]      ; sn°ëen° á°taáe doby parkov†n°
         jnz       int083                   ; nen° je®tà dosaëeno 0 á°taáe doby
         and       byte ptr cs:[Param],7fh  ; p©°znak poëadavku parkov†n°
int081:  test      byte ptr cs:[Param],83h  ; je moënÇ provÇst parkov†n° ?
         jnz       int083                   ; nen° moënÇ provÇst parkov†n°
         cmp       word ptr cs:[Doba],0     ; je funkce vypnuta ?
         je        Int083                   ; funkce je vypnuta

; ------ provede se zaparkov†n° diskñ

         or        byte ptr cs:[Param],82h  ; zru®en° poëadavku parkov†n°
         sti                                ; povolen° p©eru®en°
         push      ax                       ; £schova registru AX
         push      bx                       ; £schova registru BX
         push      cx                       ; £schova registru CX
         push      dx                       ; £schova registru DX
         push      si
         push      di                       ; £schova registru DI
         push      bp
         push      ds
         push      es                       ; £schova registru ES

; ------ parkov†n° pevnÇho disku 1

         test      byte ptr cs:[Param],8    ; jsou 2 disky ?
         jz        Int0811                  ; nejsou 2 disky - je jen jeden
         mov       dl,81h                   ; á°slo pevnÇho disku 1
         mov       bx,cs:[parkc1]           ; parkovac° stopa disku 1
         call      park                     ; zaparkov†n° pevnÇho disku 1

; ------ parkov†n° pevnÇho disku 0

Int0811: mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,cs:[parkc0]           ; parkovac° stopa disku 0
         call      park                     ; zaparkov†n° pevnÇho disku 0

; ------ n†vrat registrñ

         pop       es                       ; n†vrat registru ES
         pop       ds
         pop       bp
         pop       di                       ; n†vrat registru DI
         pop       si
         pop       dx                       ; n†vrat registru DX
         pop       cx                       ; n†vrat registru CX
         pop       bx                       ; n†vrat registru BX
         pop       ax                       ; n†vrat registru AX
         and       byte ptr cs:[Param],not 2; zru®en° p©°znaku obsluhy parkov†n°

int083:  iret                               ; n†vrat z obsluhy p©eru®en° INT 08h

INT08    ENDP

; -----------------------------------------------------------------------------
;        zaparkov†n° jednoho pevnÇho disku
; -----------------------------------------------------------------------------
; VSTUP: DL=á°slo disku
;        BX=á°slo stopy
; -----------------------------------------------------------------------------

Park     PROC      NEAR

         push      dx
         xor       ax,ax
         call      Int13x                   ; reset disku
         pop       dx
         mov       cx,68                    ; poáet pokusñ o parkov†n°

park1:   push      bx
         push      cx
         push      dx

         mov       ch,bl                    ; nië®° bajt á°sla v†lce
         mov       cl,bh                    ; vy®®° bajt á°sla v†lce
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bitñ 6 a 7
         and       cl,0c0h                  ; ponech† bity 6 a 7 (= 8 a 9)
         inc       cx                       ; -> sektor 1
         mov       dh,bh                    ; vy®®° bajt á°sla v†lce
         shl       dh,1
         shl       dh,1
         shl       dh,1
         shl       dh,1                     ; bity 10 a 11 do bitñ 6 a 7
         and       dh,0c0h                  ; ponech† bity 6 a 7 (= 10 a 11)
         mov       ah,0ch                   ; funkce vystaven° hlav
         call      Int13x                   ; vystaven° na parkovac° stopu

         pop       dx
         pop       cx
         pop       bx
         loop      park1                    ; novÇ zaparkov†n° disku
park2:   ret

Park     ENDP

; -----------------------------------------------------------------------------
;        instalace a obsluha programu
; -----------------------------------------------------------------------------

; -------------------------  instalace programu -------------------------------

instal:

; ------ zobrazen° £vodn°ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ p©°prava p©°kazovÇho ©†dku

         mov       si,81h
         mov       bl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       byte ptr ds:[bx+si],0    ; oznaáen° konce p©°kazovÇho ©†dku

; ------ dek¢dov†n° zadanÇho á°sla

         call      InpNum                   ; dek¢dov†n° á°sla
         jc        Instal1                  ; á°slo asi nebylo zad†no
         mov       dx,18                    ; poáet taktñ na sekundu
         mul       dx                       ;
         mov       ds:[Doba],ax             ; zadan† parkovac° doba
         mov       ds:[Citac],ax            ; á°taá áasu
         or        byte ptr ds:[Param],10h  ; p©°znak zad†n° parkovac° doby

; ------ test spr†vnosti syntace

Instal1: call      InpSpc                   ; je je®tà nàco zad†no ?
         jc        Instal2                  ; zad†n° OK

; ------ chyba zad†n° - zobrazen° n†povàdy

         mov       dx,offset HelpTxt
         mov       ah,9
         int       21h                      ; zobrazen° n†povàdy
         int       20h                      ; konec

; ------ test instalace programu

Instal2: mov       cx,ds:[Doba]             ; zadan† doba
         mov       bx,IDENTBX               ; identifik†tor v BX
         mov       dl,IDENTDL               ; identifik†tor v DL
         mov       ah,0
         int       13h                      ; test instalace
         cmp       bx,IDENTRBX              ; je program nainstalov†n ?
         jne       Instal4                  ; program nen° nainstalov†n

; ------ program je jië nainstalov†n - p©°padnÇ navr†cen° doby

         test      byte ptr ds:[Param],10h  ; byla zad†na parkovac° doba ?
         jnz       Instal3                  ; parkovac° doba byla zad†na OK
         mov       ds:[Doba],cx             ; £schova aktu†ln° nastavenÇ doby
         mov       bx,IDENTBX               ; identifik†tor v BX
         mov       dl,IDENTDL               ; identifik†tor v DL
         mov       ah,0
         int       13h                      ; n†vrat nastavenÇ doby
Instal3: call      Hlas                     ; hl†®en° o stavu programu
         int       20h                      ; konec programu

; ------ nov† instalace - zji®tàn° poátu diskñ

Instal4: mov       ah,8
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         int       13h                      ; poskytnut° poátu diskñ
         jc        NoDisk                   ; chyba - nen° ë†dnò pevnò disk
         and       dx,3                     ; poáet pevnòch diskñ
         jz        NoDisk                   ; nen° ani 1 pevnò disk
         dec       dx                       ; je 1 pevnò disk ?
         jz        Instal5                  ; je 1 pevnò disk

; ------ parkovac° stopa disku 1

         or        byte ptr ds:[Param],8    ; p©°znak 2 diskñ
         mov       dl,81h                   ; á°slo pevnÇho disku 1
         mov       bx,118h                  ; offset adresy INT 46h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 1
         mov       ds:[parkc1],dx           ; parkovac° stopa disku 1

; ------ parkovac° stopa disku 2

Instal5: mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,104h                  ; offset adresy INT 41h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 0
         mov       ds:[parkc0],dx           ; parkovac° stopa disku 0

; ------ test, zda je nàjakò disk

         or        dx,ds:[parkc1]           ; je alespo§ 1 pevnò disk ?
         jnz       Instal6                  ; je nàjakò disk

; ------ chyba - nen° ë†dnò pevnò disk

NoDisk:  mov       dx,offset NDiskTxt
         mov       ah,9
         int       21h                      ; chyba - nen° pevnò disk
         int       20h

; ------ instalace obsluhy p©eru®en° INT 13h

Instal6: mov       ax,3513h                 ; funkce poskytnut° adresy INT 13h
         int       21h                      ; poskytnut° adresy INT 13h
         mov       word ptr ds:[old13],bx   ; £schova offsetu adresy INT 13h
         mov       word ptr ds:[old13+2],es ; £schova segmentu adresy INT 13h
         mov       ax,2513h                 ; funkce nastaven° adresy INT 13h
         mov       dx,offset int13          ; adresa vlastn° obsluhy INT 13h
         int       21h                      ; nastaven° adresy obsluhy INT 13h

; ------ instalace obsluhy p©eru®en° INT 08h

         mov       ax,3508h                 ; funkce poskytnut° adresy INT 08h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       word ptr ds:[old08],bx   ; £schova offsetu adresy INT 08h
         mov       word ptr ds:[old08+2],es ; £schova segmentu adresy INT 08h
         mov       ax,2508h                 ; funkce nastaven° adresy INT 08h
         mov       dx,offset int08          ; adresa vlastn° obsluhy INT 08h
         int       21h                      ; nastaven° adresy obsluhy INT 08h

; ------ instalace programu

         call      Hlas                     ; zobrazen° hl†®en°
         mov       dx,offset instal         ; konec rezidentn° á†sti programu
         int       27h                      ; instalace programu jako rezidentn°

; -----------------------------------------------------------------------------
;        hl†®en° o nastavenÇ parkovac° dobà
; -----------------------------------------------------------------------------

Hlas     PROC      NEAR

; ------ test, zda je funkce vypnuta

         mov       dx,offset VypTxt
         mov       cx,ds:[Doba]
         jcxz      Hlas2                    ; vypnuto

; ------ zobrazen° doby pro parkov†n°

         mov       dx,offset Parktxt
         mov       ah,9
         int       21h
         xor       dx,dx
         mov       ax,cx
         mov       bx,18
         div       bx                       ; doba v sekund†ch
         call      DispNum
         mov       dx,offset Park2Txt
Hlas2:   mov       ah,9
         int       21h                      ; funkce vypnuta
         ret

Hlas     ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,10
         xor       cx,cx
DispNum1:xor       dx,dx
         div       bx                       ; vòpoáet á°slice
         add       dl,"0"                   ; korekce na ASCII
         push      dx                       ; £schova á°slice
         inc       cx                       ; á°taá á°slic
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       dx
         mov       ah,2
         int       21h
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zji®tàn° parkovac° stopy
; -----------------------------------------------------------------------------

getdisk:                                  ;* zji®tàn° parkovac° stopy
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=offset ukazatele tabulky
                                            ; VùSTUP: DX=parkovac° stopa disku
         push      es
         xor       ax,ax
         mov       es,ax                    ; segment 0
         mov       al,dl                    ; £schova á°sla disku
         les       bx,es:[bx]               ; adresa tabulky popisovaáe
         mov       dx,es:[bx]               ; poáet v†lcñ disku
         dec       dx                       ; á°slo posledn° stopy
         call      testat                   ; je poá°taá AT ?
         jc        getdisk2                 ; nen° poá°taá AT
         mov       dx,es:[bx+0ch]           ; parkovac° z¢na pevnÇho disku
getdisk2:or        dx,dx                    ; je platn† stopa ?
         jnz       getdisk4                 ; je platn† stopa

         mov       dl,al                    ; á°slo disku
         mov       ah,8
         int       13h                      ; poskytnut° posledn° stopy
         jc        getdisk4                 ; nen° platnò disk
         xchg      ch,cl                    ; CL <- nië®° bajt á°sla stopy
         rol       ch,1
         rol       ch,1                     ; bity 8 a 9 á°sla stopy
         and       ch,3                     ; bity 8 a 9 á°sla stopy
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; bity 10 a 11 á°sla stopy
         and       dh,0ch                   ; bity 10 a 11 á°sla stopy
         xor       dl,dl
         or        dx,cx                    ; DX = á°slo posledn° stopy
         inc       dx                       ; DX = á°slo parkovac° stopy

getdisk4:pop       es
         ret


; -----------------------------------------------------------------------------
;        vstup á°sla z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

InpNum   PROC      NEAR

         push      dx
         xor       dx,dx
         call      InpSpc
         call      InpNm
         jc        InpNum9

InpNum1: push      ax
         mov       ax,10
         mul       dx
         mov       dx,ax
         pop       ax
         mov       ah,0
         add       dx,ax
         call      InpNm
         jnc       InpNum1
         clc

InpNum9: mov       ax,dx
         pop       dx
         ret

InpNum   ENDP

; -----------------------------------------------------------------------------
;        vstup á°slice z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

InpNm    PROC      NEAR

         call      inpChr
         jc        InpNm2

         cmp       al,"0"
         jb        InpNm1
         cmp       al,"9"+1
         cmc
         jc        InpNm1
         sub       al,"0"
         ret

InpNm1:  dec       si
InpNm2:  ret

InpNm    ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

InpSpc   PROC      NEAR

         call      InpChr
         jc        InpSpc2
         je        InpSpc
         dec       si

InpSpc2:
         ret

inpSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

         cld
         lodsb

         cmp       al,9
         jne       InpChr2
         mov       al," "

InpChr2: cmp       al," "
         jae       InpChr3
         dec       si

inpChr3: ret

inpChr   ENDP

; -----------------------------------------------------------------------------
testat:                                   ;* je poá°taá AT ?
                                            ; VùSTUP: CY=nen° AT
         push      ax
         push      ds
         mov       ax,0f000h                ; segment modulu BIOS
         mov       ds,ax                    ; segment modulu BIOS
         cmp       byte ptr ds:[0fffeh],0fch; je AT nebo XT-286 ?
         je        testat2                  ; je AT nebo XT-286
         stc                                ; p©°znak, ëe nen° AT
testat2: pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        texty
; -----------------------------------------------------------------------------

UvTxt    db        'AUTOPARK V1.02 - autoparkovani pevneho disku; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte dobu v [s]; 0=vypnuto.',13,10,'$'

VypTxt   db        'Funkce vypnuta.',13,10,'$'
ParkTxt  db        'Interval autoparkovani: $'
Park2Txt db        ' sekund.',13,10,'$'

NDiskTxt db        'Neni zadny pevny disk !',13,10,'$'

code     ends
         end       autopark

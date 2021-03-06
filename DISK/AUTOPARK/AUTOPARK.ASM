
; *****************************************************************************
;
;                  Automatick� parkov�n� pevn�ch disk�
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h                     ; p�eklad k�du jako program .COM

IDENTDL  EQU       9bh                      ; identifikace programu v DL
IDENTBX  EQU       8a36h                    ; identifikace programu v BX
IDENTRBX EQU       5794h                    ; navr�cen� identifikace v BX

Autopark:jmp       Instal                   ; skok na instalaci programu

Doba     dw        182                      ; doba pro parkov�n� (0=vypnuto)
Citac    dw        182                      ; ��ta� doby pro autoparkov�n�
Old13    dd        0                        ; adresa p�vodn� obsluhy INT 13h
Old08    dd        0                        ; adresa p�vodn� obsluhy INT 08h
Param    db        80h                      ;   bit 0: prob�h� obsluha INT 13h
                                            ;   bit 1: prob�h� obsluha parkov�n�
                                            ;   bit 3: 1=jsou 2 disky
                                            ;   bit 4: 1=zad�na parkovac� doba
                                            ;   bit 7: nen� po�adov�no parkov�n�

Parkc0   dw        0                        ; parkovac� stopa disku 0
Parkc1   dw        0                        ; parkovac� stopa disku 1

; -----------------------------------------------------------------------------
;        obsluha INT 13h
; -----------------------------------------------------------------------------

int13    proc      far                    ;* obsluha p�eru�en� INT 13h

; ------ obsluha rezidentn�ho modulu

         cmp       ah,0
         jne       Int130                   ; funkce resetu disku
         cmp       dl,IDENTDL               ; je identifikace v DL ?
         jne       Int130                   ; nen� identifikace v DL
         cmp       bx,IDENTBX               ; je identifikace v BX ?
         jne       Int130                   ; nen� idnetifikace v BX
         mov       bx,IDENTRBX              ; n�vratov� identifik�tor BX
         and       byte ptr cs:[Param],not 80h ; zru�en� po�adavku parkov�n�
         mov       cs:[Citac],cx            ; inicializace ��ta�e
         xchg      cs:[Doba],cx             ; ulo�en� parkovac� doby
         ret       +2

; ------ zah�jen� m��en� doby pro parkov�n�

Int130:  or        byte ptr cs:[Param],1    ; nastaven� p��znaku obsluhy INT 13h
         or        dl,dl                    ; je p��stup na pevn� disk ?
         jns       int131                   ; nen� p��stup na pevn� disk
         test      byte ptr cs:[Param],4    ; je funkce vypnuta ?
         jnz       Int131                   ; funkce je vypnuta
         push      ax
         mov       ax,cs:[Doba]             ; doba k parkov�n�
         mov       cs:[citac],ax            ; inicializace ��ta�e pro parkov�n�
         pop       ax

; ------ p�vodn� obsluha INT 13h

int131:  call      int13x                   ; vol�n� p�vodn� obsluhy INT 13h
         pushf                              ; �schova navr�cen�ch p��znak�
         and       byte ptr cs:[Param],not 1; zru�en� p��znaku obsluhy INT 13h
         popf                               ; n�vrat navr�cen�ch p��znak�
         ret       +2                       ; n�vrat bez obnoven� p��znak�

int13    endp

; --------------------- vol�n� p�vodn� obsluhy INT 13h ------------------------
int13x:  pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vol�n� p�vodn� obsluhy INT 13h
         ret

; -----------------------------------------------------------------------------
;        �asov�n� pro automatick� parkov�n�
; -----------------------------------------------------------------------------

int08    PROC      FAR
                                         ;* obsluha p�eru�en� INT 08h

         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old08]     ; vol�n� p�vodn� obsluhy INT 08h
         cmp       word ptr cs:[citac],0    ; je ��ta� doby parkov�n� ji� 0 ?
         je        int081                   ; je ji� dosa�eno 0 ��ta�e doby
         dec       word ptr cs:[citac]      ; sn��en� ��ta�e doby parkov�n�
         jnz       int083                   ; nen� je�t� dosa�eno 0 ��ta�e doby
         and       byte ptr cs:[Param],7fh  ; p��znak po�adavku parkov�n�
int081:  test      byte ptr cs:[Param],83h  ; je mo�n� prov�st parkov�n� ?
         jnz       int083                   ; nen� mo�n� prov�st parkov�n�
         cmp       word ptr cs:[Doba],0     ; je funkce vypnuta ?
         je        Int083                   ; funkce je vypnuta

; ------ provede se zaparkov�n� disk�

         or        byte ptr cs:[Param],82h  ; zru�en� po�adavku parkov�n�
         sti                                ; povolen� p�eru�en�
         push      ax                       ; �schova registru AX
         push      bx                       ; �schova registru BX
         push      cx                       ; �schova registru CX
         push      dx                       ; �schova registru DX
         push      si
         push      di                       ; �schova registru DI
         push      bp
         push      ds
         push      es                       ; �schova registru ES

; ------ parkov�n� pevn�ho disku 1

         test      byte ptr cs:[Param],8    ; jsou 2 disky ?
         jz        Int0811                  ; nejsou 2 disky - je jen jeden
         mov       dl,81h                   ; ��slo pevn�ho disku 1
         mov       bx,cs:[parkc1]           ; parkovac� stopa disku 1
         call      park                     ; zaparkov�n� pevn�ho disku 1

; ------ parkov�n� pevn�ho disku 0

Int0811: mov       dl,80h                   ; ��slo pevn�ho disku 0
         mov       bx,cs:[parkc0]           ; parkovac� stopa disku 0
         call      park                     ; zaparkov�n� pevn�ho disku 0

; ------ n�vrat registr�

         pop       es                       ; n�vrat registru ES
         pop       ds
         pop       bp
         pop       di                       ; n�vrat registru DI
         pop       si
         pop       dx                       ; n�vrat registru DX
         pop       cx                       ; n�vrat registru CX
         pop       bx                       ; n�vrat registru BX
         pop       ax                       ; n�vrat registru AX
         and       byte ptr cs:[Param],not 2; zru�en� p��znaku obsluhy parkov�n�

int083:  iret                               ; n�vrat z obsluhy p�eru�en� INT 08h

INT08    ENDP

; -----------------------------------------------------------------------------
;        zaparkov�n� jednoho pevn�ho disku
; -----------------------------------------------------------------------------
; VSTUP: DL=��slo disku
;        BX=��slo stopy
; -----------------------------------------------------------------------------

Park     PROC      NEAR

         push      dx
         xor       ax,ax
         call      Int13x                   ; reset disku
         pop       dx
         mov       cx,68                    ; po�et pokus� o parkov�n�

park1:   push      bx
         push      cx
         push      dx

         mov       ch,bl                    ; ni��� bajt ��sla v�lce
         mov       cl,bh                    ; vy��� bajt ��sla v�lce
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bit� 6 a 7
         and       cl,0c0h                  ; ponech� bity 6 a 7 (= 8 a 9)
         inc       cx                       ; -> sektor 1
         mov       dh,bh                    ; vy��� bajt ��sla v�lce
         shl       dh,1
         shl       dh,1
         shl       dh,1
         shl       dh,1                     ; bity 10 a 11 do bit� 6 a 7
         and       dh,0c0h                  ; ponech� bity 6 a 7 (= 10 a 11)
         mov       ah,0ch                   ; funkce vystaven� hlav
         call      Int13x                   ; vystaven� na parkovac� stopu

         pop       dx
         pop       cx
         pop       bx
         loop      park1                    ; nov� zaparkov�n� disku
park2:   ret

Park     ENDP

; -----------------------------------------------------------------------------
;        instalace a obsluha programu
; -----------------------------------------------------------------------------

; -------------------------  instalace programu -------------------------------

instal:

; ------ zobrazen� �vodn�ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen� �vodn�ho textu

; ------ p��prava p��kazov�ho ��dku

         mov       si,81h
         mov       bl,ds:[si-1]             ; d�lka p��kazov�ho ��dku
         mov       byte ptr ds:[bx+si],0    ; ozna�en� konce p��kazov�ho ��dku

; ------ dek�dov�n� zadan�ho ��sla

         call      InpNum                   ; dek�dov�n� ��sla
         jc        Instal1                  ; ��slo asi nebylo zad�no
         mov       dx,18                    ; po�et takt� na sekundu
         mul       dx                       ;
         mov       ds:[Doba],ax             ; zadan� parkovac� doba
         mov       ds:[Citac],ax            ; ��ta� �asu
         or        byte ptr ds:[Param],10h  ; p��znak zad�n� parkovac� doby

; ------ test spr�vnosti syntace

Instal1: call      InpSpc                   ; je je�t� n�co zad�no ?
         jc        Instal2                  ; zad�n� OK

; ------ chyba zad�n� - zobrazen� n�pov�dy

         mov       dx,offset HelpTxt
         mov       ah,9
         int       21h                      ; zobrazen� n�pov�dy
         int       20h                      ; konec

; ------ test instalace programu

Instal2: mov       cx,ds:[Doba]             ; zadan� doba
         mov       bx,IDENTBX               ; identifik�tor v BX
         mov       dl,IDENTDL               ; identifik�tor v DL
         mov       ah,0
         int       13h                      ; test instalace
         cmp       bx,IDENTRBX              ; je program nainstalov�n ?
         jne       Instal4                  ; program nen� nainstalov�n

; ------ program je ji� nainstalov�n - p��padn� navr�cen� doby

         test      byte ptr ds:[Param],10h  ; byla zad�na parkovac� doba ?
         jnz       Instal3                  ; parkovac� doba byla zad�na OK
         mov       ds:[Doba],cx             ; �schova aktu�ln� nastaven� doby
         mov       bx,IDENTBX               ; identifik�tor v BX
         mov       dl,IDENTDL               ; identifik�tor v DL
         mov       ah,0
         int       13h                      ; n�vrat nastaven� doby
Instal3: call      Hlas                     ; hl��en� o stavu programu
         int       20h                      ; konec programu

; ------ nov� instalace - zji�t�n� po�tu disk�

Instal4: mov       ah,8
         mov       dl,80h                   ; ��slo pevn�ho disku 0
         int       13h                      ; poskytnut� po�tu disk�
         jc        NoDisk                   ; chyba - nen� ��dn� pevn� disk
         and       dx,3                     ; po�et pevn�ch disk�
         jz        NoDisk                   ; nen� ani 1 pevn� disk
         dec       dx                       ; je 1 pevn� disk ?
         jz        Instal5                  ; je 1 pevn� disk

; ------ parkovac� stopa disku 1

         or        byte ptr ds:[Param],8    ; p��znak 2 disk�
         mov       dl,81h                   ; ��slo pevn�ho disku 1
         mov       bx,118h                  ; offset adresy INT 46h
         call      getdisk                  ; zji�t�n� parkovac� stopy disku 1
         mov       ds:[parkc1],dx           ; parkovac� stopa disku 1

; ------ parkovac� stopa disku 2

Instal5: mov       dl,80h                   ; ��slo pevn�ho disku 0
         mov       bx,104h                  ; offset adresy INT 41h
         call      getdisk                  ; zji�t�n� parkovac� stopy disku 0
         mov       ds:[parkc0],dx           ; parkovac� stopa disku 0

; ------ test, zda je n�jak� disk

         or        dx,ds:[parkc1]           ; je alespo� 1 pevn� disk ?
         jnz       Instal6                  ; je n�jak� disk

; ------ chyba - nen� ��dn� pevn� disk

NoDisk:  mov       dx,offset NDiskTxt
         mov       ah,9
         int       21h                      ; chyba - nen� pevn� disk
         int       20h

; ------ instalace obsluhy p�eru�en� INT 13h

Instal6: mov       ax,3513h                 ; funkce poskytnut� adresy INT 13h
         int       21h                      ; poskytnut� adresy INT 13h
         mov       word ptr ds:[old13],bx   ; �schova offsetu adresy INT 13h
         mov       word ptr ds:[old13+2],es ; �schova segmentu adresy INT 13h
         mov       ax,2513h                 ; funkce nastaven� adresy INT 13h
         mov       dx,offset int13          ; adresa vlastn� obsluhy INT 13h
         int       21h                      ; nastaven� adresy obsluhy INT 13h

; ------ instalace obsluhy p�eru�en� INT 08h

         mov       ax,3508h                 ; funkce poskytnut� adresy INT 08h
         int       21h                      ; poskytnut� adresy INT 08h
         mov       word ptr ds:[old08],bx   ; �schova offsetu adresy INT 08h
         mov       word ptr ds:[old08+2],es ; �schova segmentu adresy INT 08h
         mov       ax,2508h                 ; funkce nastaven� adresy INT 08h
         mov       dx,offset int08          ; adresa vlastn� obsluhy INT 08h
         int       21h                      ; nastaven� adresy obsluhy INT 08h

; ------ instalace programu

         call      Hlas                     ; zobrazen� hl��en�
         mov       dx,offset instal         ; konec rezidentn� ��sti programu
         int       27h                      ; instalace programu jako rezidentn�

; -----------------------------------------------------------------------------
;        hl��en� o nastaven� parkovac� dob�
; -----------------------------------------------------------------------------

Hlas     PROC      NEAR

; ------ test, zda je funkce vypnuta

         mov       dx,offset VypTxt
         mov       cx,ds:[Doba]
         jcxz      Hlas2                    ; vypnuto

; ------ zobrazen� doby pro parkov�n�

         mov       dx,offset Parktxt
         mov       ah,9
         int       21h
         xor       dx,dx
         mov       ax,cx
         mov       bx,18
         div       bx                       ; doba v sekund�ch
         call      DispNum
         mov       dx,offset Park2Txt
Hlas2:   mov       ah,9
         int       21h                      ; funkce vypnuta
         ret

Hlas     ENDP

; -----------------------------------------------------------------------------
;        zobrazen� ��sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,10
         xor       cx,cx
DispNum1:xor       dx,dx
         div       bx                       ; v�po�et ��slice
         add       dl,"0"                   ; korekce na ASCII
         push      dx                       ; �schova ��slice
         inc       cx                       ; ��ta� ��slic
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
;        zji�t�n� parkovac� stopy
; -----------------------------------------------------------------------------

getdisk:                                  ;* zji�t�n� parkovac� stopy
                                            ; VSTUP: DL=��slo disku
                                            ;        BX=offset ukazatele tabulky
                                            ; V�STUP: DX=parkovac� stopa disku
         push      es
         xor       ax,ax
         mov       es,ax                    ; segment 0
         mov       al,dl                    ; �schova ��sla disku
         les       bx,es:[bx]               ; adresa tabulky popisova�e
         mov       dx,es:[bx]               ; po�et v�lc� disku
         dec       dx                       ; ��slo posledn� stopy
         call      testat                   ; je po��ta� AT ?
         jc        getdisk2                 ; nen� po��ta� AT
         mov       dx,es:[bx+0ch]           ; parkovac� z�na pevn�ho disku
getdisk2:or        dx,dx                    ; je platn� stopa ?
         jnz       getdisk4                 ; je platn� stopa

         mov       dl,al                    ; ��slo disku
         mov       ah,8
         int       13h                      ; poskytnut� posledn� stopy
         jc        getdisk4                 ; nen� platn� disk
         xchg      ch,cl                    ; CL <- ni��� bajt ��sla stopy
         rol       ch,1
         rol       ch,1                     ; bity 8 a 9 ��sla stopy
         and       ch,3                     ; bity 8 a 9 ��sla stopy
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; bity 10 a 11 ��sla stopy
         and       dh,0ch                   ; bity 10 a 11 ��sla stopy
         xor       dl,dl
         or        dx,cx                    ; DX = ��slo posledn� stopy
         inc       dx                       ; DX = ��slo parkovac� stopy

getdisk4:pop       es
         ret


; -----------------------------------------------------------------------------
;        vstup ��sla z p��kazov�ho ��dku
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
;        vstup ��slice z p��kazov�ho ��dku
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
;        vypu�t�n� mezer z p��kazov�ho ��dku
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
;        vstup znaku z p��kazov�ho ��dku
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
testat:                                   ;* je po��ta� AT ?
                                            ; V�STUP: CY=nen� AT
         push      ax
         push      ds
         mov       ax,0f000h                ; segment modulu BIOS
         mov       ds,ax                    ; segment modulu BIOS
         cmp       byte ptr ds:[0fffeh],0fch; je AT nebo XT-286 ?
         je        testat2                  ; je AT nebo XT-286
         stc                                ; p��znak, �e nen� AT
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
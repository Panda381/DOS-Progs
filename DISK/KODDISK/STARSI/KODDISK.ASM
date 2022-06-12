
; *****************************************************************************
;
;                   K¢dov n¡ soubor– na logick‚m disku
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

UvTxt    db        'KodDisk V1.0 '
UvTxtVar db        'A - kodovani disku; (c) Miroslav Nemecek',13,10,'$'
UvTxt0   label     byte

SegRez   dw        0                        ; segment rezidentn¡ ‡ sti
Old20    dd        0                        ; p–vodn¡ adresa INT 20h
Old21    dd        0                        ; p–vodn¡ adresa INT 21h
Old27    dd        0                        ; p–vodn¡ adresa INT 27h
Disk     db        0                        ; k¢dovan˜ disk (0=A, ...)
Param    db        0                        ; parametry:
                                            ;   bit 0: 1=funkce zapnuta
                                            ;   bit 1: 1=nekompatibiln¡ syst‚m

KlicN    EQU       257                      ; d‚lka kl¡‡e
Klic     db        KlicN dup(0)             ; k¢dovac¡ kl¡‡

MaxIdent EQU       128                      ; maxim ln¡ po‡et identifik tor–
Ident    dw        MaxIdent dup(-1)         ; tabulka identifik tor–

FCB      db        37 dup(0)                ; uschovan˜ vzor FCB
DTA      dd        0                        ; uschovan  adresa DTA

PushRet  dw        0                        ; £schova n vratov‚ adresy

; -----------------------------------------------------------------------------
;        obsluha INT 20h
; -----------------------------------------------------------------------------

Int20    PROC      FAR

         call      NulId
         jmp       dword ptr cs:[Old20]

Int20    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 27h
; -----------------------------------------------------------------------------

Int27    PROC      FAR

         call      NulId
         jmp       dword ptr cs:[Old27]

Int27    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 21h
; -----------------------------------------------------------------------------

Int21x:  pushf
         call      dword ptr cs:[Old21]
         ret


Int21    PROC      FAR

         cmp       ah,9                     ; zobrazen¡ textu ?
         jne       Int211                   ; nen¡ zobrazen¡ textu
         cmp       dx,offset UvTxt          ; £vodn¡ text ?
         jne       Int210                   ; nen¡ £vodn¡ text

         pushf
         push      si
         push      di
         push      cx
         push      es
         push      cs
         pop       es
         mov       si,dx
         mov       di,dx
         mov       cx,offset(UvTxt0-UvTxt)  ; d‚lka £vodn¡ho textu
         cld
         repe      cmpsb                    ; porovn n¡ text–
         pop       es
         pop       cx
         pop       di
         pop       si
         jne       Int2100                  ; nen¡ £vodn¡ text
         mov       ds:[SegRez],cs           ; segment rezidentn¡ ‡ sti
Int2100: popf

Int210:  jmp       dword ptr cs:[Old21]

; ------ sekven‡n¡ ‡ten¡ ze souboru FCB

Int211:  cmp       ah,14h
         jne       Int212

         call      UlozFCB                  ; £schova FCB
         call      TestFCB                  ; kontrola, zda je platn˜ disk
         jne       Int210                   ; nen¡ platn˜ disk

         call      PushFCB                  ; £schova FCB
         call      Int21x                   ; sekven‡n¡ ‡ten¡ dat
         call      PopFCB                   ; n vrat FCB

         cmp       al,1                     ; p©e‡teno nˆco ?
         je        Int2127                  ; nic nep©e‡teno
         cmp       al,2                     ; chyba DTA ?
         je        Int2127                  ; chyba DTA
         call      DekRFCB                  ; dek¢dov n¡ dat po ‡ten¡ FCB
Int2127: iret

; ------ sekven‡n¡ z pis do souboru FCB

Int212:  cmp       ah,15h
         jne       Int213

         call      UlozFCB                  ; £schova FCB
         call      TestFCB                  ; kontrola, zda je platn˜ disk
         jne       Int210                   ; nen¡ platn˜ disk

         call      DekWFCB                  ; zak¢dov n¡ dat p©ed z pisem
         jc        Int210                   ; chyba - p©ete‡en¡ d‚lky dat

         call      PushFCB                  ; £schova FCB
         call      Int21x                   ; sekven‡n¡ z pis dat
         call      PopFCB                   ; n vrat FCB

         call      DekRFCB                  ; dek¢dov n¡ dat po z pisu
         iret

Int2126: jmp       Int21y

; ------ ‡ten¡ s p©¡m˜m p©¡stupem FCB

Int213:  cmp       ah,21h
         jne       Int214

         call      UlozFCB                  ; £schova FCB
         call      TestFCB                  ; kontrola, zda je platn˜ disk
         jne       Int2126                  ; nen¡ platn˜ disk

         call      PushFCB                  ; £schova FCB
         call      Int21x                   ; sekven‡n¡ ‡ten¡ dat
         call      PopFCB                   ; n vrat FCB

         cmp       al,1                     ; p©e‡teno nˆco ?
         je        Int2137                  ; nic nep©e‡teno
         cmp       al,2                     ; chyba DTA ?
         je        Int2137                  ; chyba DTA
         push      cx
         mov       cx,1                     ; 1 z znam
         call      DekRFCR                  ; dek¢dov n¡ dat po ‡ten¡ FCB
         pop       cx
Int2137: iret

; ------ z pis s p©¡m˜m p©¡stupem FCB

Int214:  cmp       ah,22h
         jne       Int215

         call      UlozFCB                  ; £schova FCB
         call      TestFCB                  ; kontrola, zda je platn˜ disk
         jne       Int2126                  ; nen¡ platn˜ disk

         push      cx
         mov       cx,1                     ; 1 z znam
         call      DekWFCR                  ; zak¢dov n¡ dat p©ed z pisem
         pop       cx
         jc        Int2126                  ; chyba - p©ete‡en¡ d‚lky dat

         call      PushFCB                  ; £schova FCB
         call      Int21x                   ; zak¢dov n¡ dat p©ed z pisem
         call      PopFCB                   ; n vrat FCB

         push      cx
         mov       cx,1                     ; 1 z znam
         call      DekRFCR                  ; n vrat dat po z pisu
         pop       cx
         iret

; ------ dlouh‚ ‡ten¡ s p©¡m˜m p©¡stupem FCB

Int215:  cmp       ah,27h
         jne       Int216

         call      UlozFCB                  ; £schova FCB
         call      TestFCB                  ; kontrola, zda je platn˜ disk
         jne       Int2126                  ; nen¡ platn˜ disk

         call      PushFCB                  ; £schova FCB
         call      Int21x                   ; sekven‡n¡ ‡ten¡ dat
         call      PopFCB                   ; n vrat FCB

         cmp       al,1                     ; p©e‡teno nˆco ?
         je        Int2157                  ; nic nep©e‡teno
         cmp       al,2                     ; chyba DTA ?
         je        Int2157                  ; chyba DTA
         call      DekRFCR                  ; dek¢dov n¡ dat po ‡ten¡ FCB
Int2157: iret

; ------ dlouh˜ z pis s p©¡m˜m p©¡stupem FCB

Int216:  cmp       ah,28h
         jne       Int217

         call      UlozFCB                  ; £schova FCB
         call      TestFCB                  ; kontrola, zda je platn˜ disk
         jne       Int2177                  ; nen¡ platn˜ disk

         call      DekWFCR                  ; zak¢dov n¡ dat p©ed z pisem
         jc        Int2177                  ; chyba - p©ete‡en¡ d‚lky dat

         call      PushFCB                  ; £schova FCB
         call      Int21x                   ; zak¢dov n¡ dat p©ed z pisem
         call      PopFCB                   ; n vrat FCB

         call      DekRFCR                  ; n vrat dat po z pisu
         iret

; ------ vytvo©en¡, otev©en¡ souboru identifik torem

Int217:  cmp       ah,3dh
         je        Int2171                  ; otev©en¡ souboru
         cmp       ah,5ah
         je        Int2171                  ; vytvo©en¡ jedine‡n‚ho souboru
         cmp       ah,5bh
         je        Int2171                  ; vytvo©en¡ souboru
         cmp       ah,3ch                   ; vytvo©en¡ souboru
         jne       Int218
Int2171: call      TestFil                  ; test jm‚na souboru
         jne       Int2177                  ; nen¡ platn˜ disk
Int2172: call      Int21x                   ; vytvo©en¡ po‘adovan‚ho souboru
         jc        Int217R                  ; soubor nebyl vytvo©en
         push      ax
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      StorId                   ; ulo‘en¡ identifik toru do seznamu
         pop       ax
Int217R:
                                            ; SS:[BP+8]=Flag
                                            ; SS:[BP+6]=CS
                                            ; SS:[BP+4]=IP
         push      bp                       ; SS:[BP+2]=BP
         push      ax                       ; SS:[BP+0]=AX
         mov       bp,sp                    ; ukazatel dat v z sobn¡ku
         pushf
         pop       ax                       ; AX <- Flag
         mov       ss:[bp+8],al             ; navr cen‚ p©¡znaky
         pop       ax
         pop       bp
         iret

Int2177: jmp       Int21y

; ------ uzav©en¡ souboru

Int218:  cmp       ah,3eh
         jne       Int21a
         push      ax
         mov       ax,bx                    ; identifik tor
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      DelId                    ; zru¨en¡ identifik toru ze seznamu
         pop       ax
         jmp       short Int2177

; ------ ‡ten¡ ze souboru pomoc¡ identifik toru

Int21A:  cmp       ah,3fh
         jne       Int21B

         push      ax
         mov       ax,bx                    ; identifik tor
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      TestId                   ; test identifik toru
         pop       ax
         jne       Int2177                  ; nen¡ k¢dovan˜ soubor

         push      bx
         call      AdrId                    ; adresa (f ze) v souboru
         mov       cs:[PushRet],bx          ; £schova BX
         pop       bx

         push      word ptr cs:[PushRet]
         call      Int21x
         pop       word ptr cs:[PushRet]
         jc        Int217R                  ; chyba ‡ten¡

         pushf
         push      bx
         push      cx
         push      di
         push      es

         push      ds
         pop       es                       ; segment adresy bufferu
         mov       di,dx                    ; offset adresy bufferu
         mov       cx,ax                    ; d‚lka na‡ten˜ch dat
         mov       bx,cs:[PushRet]          ; f ze po‡ tku dat v souboru
         call      Dekod                    ; dek¢dov n¡ dat po ‡ten¡

         pop       es
         pop       di
         pop       cx
         pop       bx
         popf
         jmp       short Int217R

; ------ z pis do souboru pomoc¡ identifik toru

Int21B:  cmp       ah,40h
         jne       Int21C

         push      ax
         mov       ax,bx                    ; identifik tor souboru
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      TestId                   ; test identifik toru
         pop       ax
Int21777:jne       Int2177                  ; nen¡ k¢dovan˜ soubor

         push      bx
         push      di
         push      es

         push      ds
         pop       es                       ; segment adresy bufferu
         mov       di,dx                    ; offset adresy bufferu
         call      AdrId                    ; adresa (f ze) v souboru
         mov       cs:[PushRet],bx          ; £schova BX
         call      Kod                      ; k¢dov n¡ dat p©ed z pisem

         pop       es
         pop       di
         pop       bx

         push      word ptr cs:[PushRet]
         call      Int21x
         pop       word ptr cs:[PushRet]

         pushf
         push      bx
         push      di
         push      es

         push      ds
         pop       es                       ; segment adresy bufferu
         mov       di,dx                    ; offset adresy bufferu
         mov       bx,cs:[PushRet]          ; f ze po‡ tku dat v souboru
         call      Dekod                    ; dek¢dov n¡ dat po z pisu

         pop       es
         pop       di
         pop       bx
         popf
         jmp       short Int217R2

; ------ zdvojen¡ identifik toru souboru

Int21C:  cmp       ah,45h
         jne       Int21D

         push      ax
         mov       ax,bx                    ; identifik tor souboru
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      TestId                   ; test identifik toru
         pop       ax
         jne       Int21777                 ; nen¡ k¢dovan˜ soubor
         jmp       Int2172                  ; ulo‘en¡ identifik toru

; ------ nucen‚ zdvojen¡ identifik toru

Int21D:  cmp       ah,46h
         jne       Int21E

         call      Int21x                   ; obsluha funkce
         jc        Int217R2                 ; ne£spˆ¨n  operace
         pushf
         push      ax
         mov       ax,cx                    ; vy©azovan˜ soubor
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      DelId                    ; vy©azen¡ souboru
         mov       ax,bx                    ; vzorov˜ soubor
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      TestId
         jne       Int21D4                  ; nen¡ obsluhovan˜
         mov       ax,cx
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      StorId                   ; ulo‘en¡ zdvojen‚ho souboru
Int21D4: pop       ax
         popf
Int217R2:jmp       Int217R

; ------ ukon‡en¡ programu - automatick‚ uzav©en¡ soubor–

Int21E:  cmp       ah,0
         je        Int21E2
         cmp       ah,4ch
         je        Int21E2
         cmp       ah,31h
         jne       Int21F
Int21E2: call      NulId                    ; nulov n¡ tabulky identifik tor–
Int21E7: jmp       short Int21y

; ------ roz¨¡©en‚ otev©en¡ souboru

Int21F:  cmp       ax,6c00h
         jne       Int21G

         push      dx
         mov       dx,si                    ; jm‚no souboru
         call      TestFil                  ; test jm‚na souboru
         pop       dx
         jne       Int21E7                  ; nen¡ platn˜ disk
         call      Int21x                   ; vytvo©en¡ po‘adovan‚ho souboru
         jc        Int217R2                 ; soubor nebyl vytvo©en
         push      ax
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      StorId                   ; ulo‘en¡ identifik toru do seznamu
         pop       ax
         jmp       short Int217R2

Int21G:

Int219:
Int21y:
         jmp       dword ptr cs:[Old21]

Int21    ENDP

; -----------------------------------------------------------------------------
;        £schova FCB do z sobn¡ku
; -----------------------------------------------------------------------------

PushFCB  PROC      NEAR

         pop       word ptr cs:[PushRet]

         push      word ptr cs:[FCB+0]      ; disk
         push      word ptr cs:[FCB+0ch]    ; aktu ln¡ blok
         push      word ptr cs:[FCB+0eh]    ; d‚lka jednoho z znamu
         push      word ptr cs:[FCB+20H]    ; aktu ln¡ z znam a relativn¡ z znam

         push      word ptr cs:[DTA]        ; £schova DTA - LOW
         push      word ptr cs:[DTA+2]      ; £schova DTA - HIGH

         jmp       word ptr cs:[PushRet]

PushFCB  ENDP

; -----------------------------------------------------------------------------
;        n vrat FCB ze z sobn¡ku
; -----------------------------------------------------------------------------

PopFCB   PROC      NEAR

         pop       word ptr cs:[PushRet]

         pop       word ptr cs:[DTA+2]      ; £schova DTA - HIGH
         pop       word ptr cs:[DTA]        ; £schova DTA - LOW

         pop       word ptr cs:[FCB+20H]    ; aktu ln¡ z znam a relativn¡ z znam
         pop       word ptr cs:[FCB+0eh]    ; d‚lka jednoho z znamu
         pop       word ptr cs:[FCB+0ch]    ; aktu ln¡ blok
         pop       word ptr cs:[FCB+0]      ; disk

         jmp       word ptr cs:[PushRet]

PopFCB   ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ tabulky identifik tor–
; -----------------------------------------------------------------------------

NulId    PROC      NEAR

         pushf
         push      ax
;         push      cx
;         push      di
;         push      es

         mov       ax,5                     ; prvn¡ identifik tor
NulId2:  push      ax
         call      KodId                    ; p©ek¢dov n¡ identifik toru
         call      DelId                    ; vy©azen¡ souboru
         pop       ax
         inc       ax
         cmp       ax,20
         jb        NulId2

;         cld
;         push      cs
;         pop       es
;         mov       di,offset Ident
;         mov       ax,-1
;         mov       cx,MaxIdent              ; maxim. po‡et identifik tor–
;         rep       stosw

;         pop       es
;         pop       di
;         pop       cx
         pop       ax
         popf
         ret

NulId    ENDP

; -----------------------------------------------------------------------------
;        p©ek¢dov n¡ lok ln¡ho identifik toru AX na ve©ejn˜
; -----------------------------------------------------------------------------

KodId    PROC      NEAR

; ------ £schova registr–

         pushf
         push      bx
         push      si
         push      es

; ------ kontrola kompatibility syst‚mu

         test      byte ptr cs:[Param],2    ; je kompatibiln¡ syst‚m ?
         jnz       KodId9                   ; nekompatibiln¡ syst‚m

; ------ kontrola maxim ln¡ho ‡¡sla identifik toru

         cmp       ax,20
         jae       KodId9                   ; p©ekro‡eno max. ‡¡slo identifik.
         mov       si,ax                    ; identifik tor

; ------ poskytnut¡ aktivn¡ho PSP

         mov       ah,51h
         call      Int21x                   ; poskytnut¡ adresy aktivn¡ho PSP
         mov       es,bx                    ; adresa aktivn¡ho PSP

; ------ transformace identifik toru podle tabulky

         xor       ax,ax
         mov       al,es:[si+18h]           ; transformace identifik toru
         cmp       al,0ffh                  ; je platn˜ identifik tor ?
         jne       KodId9                   ; je platn˜ identifik tor
         mov       ax,si                    ; n vrat p–vodn¡ho identifik toru

; ------ n vrat registr–

KodId9:  pop       es
         pop       si
         pop       bx
         popf
         ret

KodId    ENDP


; -----------------------------------------------------------------------------
;        Ulo‘en¡ identifik toru AX souboru do seznamu soubor–
; -----------------------------------------------------------------------------

StorId   PROC      NEAR

         pushf
         push      si
         push      cx

; ------ test, zda identifik tor ji‘ je v tabulce

         mov       cx,MaxIdent              ; max. po‡et identifik tor–
         mov       si,offset Ident          ; tabulka identifik tor–
StorId1: cmp       word ptr cs:[si],ax      ; je ji‘ takov˜ identifik tor ?
         je        StorId9                  ; je ji‘ takov˜ identifik tor
         inc       si
         inc       si
         loop      StorId1                  ; dal¨¡ identifik tor

; ------ nalezen¡ voln‚ polo‘ky v tabulce

         mov       cx,MaxIdent              ; max. po‡et identifik tor–
         mov       si,offset Ident-2        ; tabulka identifik tor–
StorId2: inc       si
         inc       si
         cmp       word ptr cs:[si],-1      ; je voln  polo‘ka ?
         loopne    StorId2                  ; nalezen¡ voln‚ polo‘ky
         jne       StorId9                  ; polo‘ka nenalezena

         mov       cs:[si],ax               ; £schova identifik toru souboru

StorId9: pop       cx
         pop       si
         popf
         ret

StorId   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ identifik toru AX ze seznamu soubor–
; -----------------------------------------------------------------------------

DelId    PROC      NEAR

         pushf
         push      si
         push      cx

; ------ nalezen¡ identifik toru v tabulce

         mov       cx,MaxIdent              ; max. po‡et identifik tor–
         mov       si,offset Ident-2        ; tabulka identifik tor–
DelId1:  inc       si
         inc       si
         cmp       word ptr cs:[si],ax      ; nalezen identifik tor ?
         loopne    DelId1                   ; nenalezen - dal¨¡ identifik tor
         jne       DelId9                   ; identifik tor nenalezen

         mov       word ptr cs:[si],-1      ; zru¨en¡ identifik toru

DelId9:  pop       cx
         pop       si
         popf
         ret

DelId    ENDP

; -----------------------------------------------------------------------------
;        test, zda je identifik tor AX v seznamu soubor–
; -----------------------------------------------------------------------------

TestId   PROC      NEAR

         push      di
         push      cx
         push      es

; ------ nalezen¡ identifik toru v tabulce

         push      cs
         pop       es
         cld
         mov       cx,MaxIdent              ; max. po‡et identifik tor–
         mov       di,offset Ident          ; tabulka identifik tor–
         repne     scasw                    ; nalezen¡ identifik toru v tabulce

         pop       es
         pop       cx
         pop       di
         ret

TestId   ENDP



; -----------------------------------------------------------------------------
;        —schova vzoru FCB DS:DX (a DTA)
; -----------------------------------------------------------------------------

UlozFCB  PROC      NEAR

         pushf
         push      ax
         push      bx
         push      si
         push      di
         push      cx
         push      es

         cld
         push      cs
         pop       es
         mov       di,offset FCB
         mov       cx,37                    ; d‚lka FCB
         mov       si,dx
         cmp       byte ptr ds:[si],0ffh
         jne       UlozFCB1                 ; nen¡ roz¨¡©en˜ FCB
         add       si,7
UlozFCB1:rep       movsb                    ; £schova FCB

         mov       ah,2fh
         call      Int21x                   ; poskytnut¡ adresy DTA
         mov       word ptr cs:[DTA],bx
         mov       word ptr cs:[DTA+2],es

         pop       es
         pop       cx
         pop       di
         pop       si
         pop       bx
         pop       ax
         popf
         ret

UlozFCB  ENDP

; -----------------------------------------------------------------------------
;        Test jm‚na souboru, zda je po‘adovan˜ disk
; -----------------------------------------------------------------------------

TestFil  PROC      NEAR

         push      ax
         push      si
         mov       si,dx

; ------ nalezen¡ ozna‡en¡ disku

         cld                                ; smˆr nahoru
TestFil1:lodsb                              ; na‡ten¡ znaku
         cmp       al," "                   ; je mezera ?
         je        TestFil1                 ; je mezera - ignorov n¡
         cmp       al,9                     ; je tabel tor ?
         je        TestFil1                 ; je tabel tor - ignorov n¡

; ------ p©evod ozna‡en¡ disku na velk‚ p¡smeno

         cmp       al,"a"
         jb        TestFil2
         cmp       al,"z"
         ja        TestFil2
         sub       al,32                    ; korekce na velk‚ p¡smeno
TestFil2:sub       al,"A"                   ; ‡¡slo disku

; ------ stanoven¡ implicitn¡ho disku

         cmp       byte ptr ds:[si],":"     ; je to ozna‡en¡ disku ?
         je        TestFil3                 ; je to ozna‡en¡ disku
         mov       ah,19h
         call      Int21x                   ; poskytnut¡ aktivn¡ho disku

; ------ test, zda je k¢dovan˜ disk

TestFil3:cmp       al,cs:[Disk]             ; je to k¢dovan˜ disk ?

         pop       si
         pop       ax
         ret

TestFil  ENDP

; -----------------------------------------------------------------------------
;        Test polo‘ky FCB, zda je po‘adovan˜ disk
; -----------------------------------------------------------------------------

TestFCB  PROC      NEAR

         push      ax

; ------ test ‡¡sla disku

         mov       al,cs:[FCB]
         or        al,al                    ; je aktu ln¡ disk ?
         jnz       TestFCB2                 ; nen¡ aktu ln¡ disk
         mov       ah,19h
         call      Int21x                   ; poskytnut¡ aktivn¡ho disku
         inc       al                       ; p©ednastaven¡ ‡¡sla disku
TestFCB2:dec       al                       ; ‡¡slo disku (0=A atd.)
         cmp       al,cs:[Disk]             ; je to k¢dovan˜ disk ?

         pop       ax
         ret

TestFCB  ENDP


; -----------------------------------------------------------------------------
;        dek¢dov n¡ dat p©ed z pisem FCB - rel. z znam
; -----------------------------------------------------------------------------

DekWFCR  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ f ze a d‚lka dat

         call      AdrRFCB                  ; poskytnut¡ adresy dat z FCB - rel.
         jmp       short DekWFCB0

DekWFCR  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ dat p©ed z pisem FCB (1 z znam) - blok
; -----------------------------------------------------------------------------

DekWFCB  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ f ze a d‚lka dat

         call      AdrBFCB                  ; poskytnut¡ adresy dat z FCB - blok
DekWFCB0:jc        DekWFCB2                 ; chyba - p©ete‡en¡ d‚lky dat

; ------ poskytnut¡ adresy dat - adresa DTA

DekWFCB1:les       di,cs:[DTA]              ; adresa DTA

; ------ dek¢dov n¡ dat p©ed z pisem FCB

         call      Kod                      ; zak¢dov n¡ dat FCB

DekWFCB2:pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DekWFCB  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ dat po ‡ten¡ FCB - rel. z znam
; -----------------------------------------------------------------------------

DekRFCR  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ f ze a d‚lka dat

         call      AdrRFCB                  ; poskytnut¡ adresy dat z FCB - rel.
         jmp       short DekRFCB1

DekRFCR  ENDP

; -----------------------------------------------------------------------------
;        rozk¢dov n¡ dat na‡ten˜ch p©i operaci FCB (1 z znam) - blok
; -----------------------------------------------------------------------------

DekRFCB  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      di
         push      es

; ------ f ze a d‚lka dat

         call      AdrBFCB                  ; poskytnut¡ adresy dat z FCB - blok

; ------ poskytnut¡ adresy dat - adresa DTA

DekRFCB1:les       di,cs:[DTA]              ; adresa DTA

; ------ dek¢dov n¡ dat na‡ten˜ch p©i operaci FCB

         call      Dekod                    ; dek¢dov n¡ dat FCB

         pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

DekRFCB  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ f ze BL identifik toru BX
; -----------------------------------------------------------------------------

AdrId    PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,4201h
         xor       cx,cx
         xor       dx,dx
         call      Int21x                   ; poskytnut¡ ukazatele souboru
         mov       bl,al                    ; f ze souboru

         pop       dx
         pop       cx
         pop       ax
         ret

AdrId    ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ f ze BL a d‚lky CX dat z FCB/CX z zn. (CY=p©ete‡en¡) - rel.
; -----------------------------------------------------------------------------

AdrRFCB  PROC      NEAR

         push      ax
         push      dx

         mov       al,cs:[FCB+21h]          ; rel. z znam - nejni‘¨¡ bajt
         jmp       short AdrFCB2

AdrRFCB  ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ f ze BL a d‚lky CX dat z FCB/1 z zn.  (CY=p©ete‡en¡) - blok
; -----------------------------------------------------------------------------

AdrBFCB  PROC      NEAR

         push      ax
         push      dx
         mov       cx,1                     ; 1 z znam

; ------ v˜po‡et relativn¡ho z znamu (posta‡¡ ni‘¨¡ slovo)

         xor       ax,ax                    ; AX <- 0
         mov       ah,cs:[FCB+0ch]          ; aktu ln¡ blok LOW
         shr       ax,1                     ; p©epo‡et bloku na z znam LOW
         mov       ah,cs:[FCB+20h]          ; aktu ln¡ z znam
         and       ah,7fh                   ; nulov n¡ bitu 7
         or        al,ah                    ; aktu ln¡ z znam relativnˆ (LOW)

; ------ v˜po‡et f ze v souboru

AdrFCB2: mul       byte ptr cs:[FCB+0eh]    ; p©epo‡et z znamu na bajty
         mov       bl,al                    ; f ze adresy v souboru (0 a‘ 255)

; ------ v˜po‡et d‚lky dat k na‡ten¡

         mov       ax,word ptr cs:[FCB+0eh] ; d‚lka jednoho z znamu
         mul       cx                       ; v˜po‡et d‚lky dat k na‡ten¡
         mov       cx,ax                    ; d‚lka dat k na‡ten¡
         or        dx,dx                    ; je p©ete‡en¡ segmentu ?
         jz        AdrBFCB9                 ; d‚lka dat je OK
         stc                                ; p©¡znak chyby p©ete‡en¡ dat

AdrBFCB9:pop       dx
         pop       ax
         ret

AdrBFCB  ENDP

; -----------------------------------------------------------------------------
;        zak¢dov n¡ dat ES:DI/CX p©ed z pisem, f ze BL
; -----------------------------------------------------------------------------
; zni‡en‚ registry: BX
; -----------------------------------------------------------------------------

Kod      PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         mov       si,offset Klic           ; k¢dovac¡ kl¡‡
         xor       bh,bh                    ; BH <- 0 vy¨¨¡ bajt f ze
         jcxz      Koda
         test      byte ptr cs:[Param],1    ; je funkce zapnuta ?
         jz        Koda                     ; funkce nen¡ zapnuta
         mov       dx,cx                    ; po‡et bajt–
         cld                                ; smˆr nahoru

; ------ zak¢dov n¡ dat

Kod1:    mov       cx,ds:[si+bx]            ; vzorek kl¡‡e
         mov       al,es:[di]               ; vzorek dat
         and       cl,7                     ; omezen¡ po‡tu rotac¡
         rol       al,cl                    ; rotace vlevo
         xor       al,ch                    ; maskov n¡ vzorkem dat
         stosb                              ; ulo‘en¡ zak¢dovan˜ch dat
         inc       bl                       ; zv˜¨en¡ f ze v tabulce kl¡‡e
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       Kod1                     ; zak¢dov n¡ dal¨¡ho bajtu

; ------ n vrat registr–

Koda:    pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

Kod      ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ dat ES:DI/CX po ‡ten¡ (nebo po z pisu), f ze BL
; -----------------------------------------------------------------------------

DeKod    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      ds
         push      cs
         pop       ds
         mov       si,offset Klic           ; k¢dovac¡ kl¡‡
         xor       bh,bh                    ; BH <- 0 vy¨¨¡ bajt f ze
         jcxz      Dekod2                   ; nejsou ‘ dn  data
         test      byte ptr cs:[Param],1    ; je funkce zapnuta ?
         jz        DeKod2                   ; funkce nen¡ zapnuta
         mov       dx,cx                    ; po‡et bajt–
         cld                                ; smˆr nahoru

; ------ dek¢dov n¡ dat

DeKod1:  mov       cx,ds:[si+bx]            ; vzorek kl¡‡e
         mov       al,es:[di]               ; vzorek dat
         and       cl,7                     ; omezen¡ po‡tu rotac¡
         xor       al,ch                    ; odmaskov n¡ vzorku dat
         ror       al,cl                    ; rotace vpravo
         stosb                              ; ulo‘en¡ dek¢dovan˜ch dat
         inc       bl                       ; zv˜¨en¡ f ze v tabulce kl¡‡e
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       DeKod1                   ; dek¢dov n¡ dal¨¡ho bajtu dat

; ------ n vrat registr–

DeKod2:  pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DeKod    ENDP


; *****************************************************************************
;
;                        Start a instalace programu
;
; *****************************************************************************

; ------ kontrola kompatibility syst‚mu

Instal:  mov       ds:[SegRez],ds           ; segment tohoto programu
         xor       bx,bx                    ; BX <- 0
         push      ds
         mov       ah,51h
         int       21h                      ; poskytnut¡ adresy sou‡asn‚ho PSP
         pop       ds
         cmp       bx,ds:[SegRez]           ; je to adresa PSP ?
         je        Instal00                 ; je kompatibiln¡ syst‚m
         or        byte ptr ds:[Param],2    ; p©¡znak nekompatibiln¡ho syst‚mu

; ------ nalezen¡ instala‡n¡ varianty

Instal00:mov       si,81h                   ; za‡ tek textu p©¡kazov‚ho © dku
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– p©¡kazov‚ho © dku
Instal01:call      ParmSpc                  ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
         call      ParmCh                   ; ‡ten¡ znaku
         jc        Instal04                 ; konec textu - nen¡ dal¨¡ znak
         cmp       al,"/"                   ; je parametr ?
         jne       Instal01                 ; nen¡ parametr
         call      ParmCh                   ; na‡ten¡ dal¨¡ho znaku
         jc        Instal04                 ; konec textu
         cmp       al,"A"
         jb        Instal01
         cmp       al,"Z"
         ja        Instal01
         mov       ds:[UvTxtVar],al         ; varianta instalace
         jmp       short Instal01

; ------ zobrazen¡ £vodn¡ho textu

Instal04:mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ dek¢dov n¡ znaku z p©¡kazov‚ho © dku

         mov       es,ds:[SegRez]           ; segment rezidentn¡ ‡ sti
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– p©¡kazov‚ho © dku
         cld                                ; smˆr nahoru

; ------ nalezen¡ prvn¡ho znaku

Instal1: call      ParmSpc                  ; vypu¨tˆn¡ mezer z textu
         jc        Inform0                  ; nic nezad no - informace
         call      ParmCh                   ; na‡ten¡ znaku
         jc        Inform0
         cmp       al,"/"
         jne       Instal11
         call      ParmCh
         jc        Chyba
         cmp       al,"A"
         jb        Chyba
         cmp       al,"Z"
         ja        Chyba
         jmp       short Instal1

; ------ rozli¨en¡ znaku

Instal11:cmp       al,"!"                   ; je odinstalov n¡ ?
         je        OdInst                   ; odinstalov n¡ programu
         cmp       al,"0"                   ; je vypnut¡ ?
         jne       Instal4                  ; nen¡ vypnut¡

; ------ vypnut¡ k¢dov n¡

Instal2: cld                                ; smˆr nahoru
         mov       di,offset Klic           ; k¢dovac¡ kl¡‡
         xor       al,al                    ; mazac¡ bajt
         mov       cx,KlicN                 ; d‚lka kl¡‡e
         rep       stosb                    ; vymaz n¡ kl¡‡e
         and       byte ptr es:[Param],not 1; p©¡znak vypnut¡ funkce
Instal3: mov       dx,offset VypTxt
         mov       ah,9
         int       21h
         jmp       ZadHes8                  ; instalace programu
;         jmp       short Chyba2

; ------ zad no ‡¡slo disku

Instal4: cmp       al,"Z"
         ja        Chyba                    ; chyba zad n¡
         sub       al,"A"
         jc        Chyba                    ; chyba zad n¡
         mov       ds:[Disk],al             ; £schova ‡¡sla disku

         jmp       ZadHesl                  ; zad n¡ hesla

; ------ nen¡ nic zad no - p©i prvn¡ instalaci chyba, jinak informace

Inform0: mov       ax,ds
         cmp       ax,ds:[SegRez]           ; byla ji‘ instalace ?
         je        Chyba                    ; nen¡ instalace - chyba

; ------ zobrazen¡ informace o k¢dovan‚m disku

Inform:  test      byte ptr es:[Param],1    ; je funkce vypnuta ?
         jz        Instal3                  ; funkce je vypnuta
         mov       al,es:[Disk]             ; k¢dovan˜ disk
         add       al,"A"                   ; korekce na znak ASCII
         mov       ds:[KodTxt0],al          ; k¢dovan˜ disk
         mov       dx,offset KodTxt         ; informa‡n¡ text
         jmp       short Chyba2

; ------ zobrazen¡ chybov‚ho textu, konec

Chyba:   mov       dx,offset ErrTxt         ; chybov˜ text
Chyba2:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu

KonecOK: int       20h                      ; n vrat z programu

; -----------------------------------------------------------------------------

; ------ odinstalov n¡ programu - kontrola, zda lze odinstalovat

OdInst:  mov       dx,offset DeInsTxt       ; chyba - nelze odinstalovat
         mov       ax,ds                    ; segment tohoto programu
         cmp       ax,ds:[SegRez]           ; je program nainstalov n ?
         je        Chyba2                   ; program nen¡ nainstalov n

; ------ kontrola INT 21h

         mov       ax,3521h
         int       21h                      ; poskytnut¡ adresy p©eru¨en¡ 21h
         cmp       bx,offset Int21          ; je to tento vektor ?
         jne       Chyba2                   ; chyba - nelze odinstalovat
         mov       ax,es                    ; segment INT 21h
         cmp       ax,ds:[SegRez]           ; je to rezidentn¡ program ?
         jne       Chyba2                   ; nelze odinstalovat

; ------ kontrola INT 20h

         mov       ax,3520h
         int       21h                      ; poskytnut¡ adresy p©eru¨en¡ 20h
         cmp       bx,offset Int20          ; je to tento vektor ?
         jne       Chyba2                   ; chyba - nelze odinstalovat
         mov       ax,es                    ; segment INT 20h
         cmp       ax,ds:[SegRez]           ; je to rezidentn¡ program ?
         jne       Chyba2                   ; nelze odinstalovat

; ------ kontrola INT 27h

         mov       ax,3527h
         int       21h                      ; poskytnut¡ adresy p©eru¨en¡ 27h
         cmp       bx,offset Int27          ; je to tento vektor ?
         jne       Chyba2                   ; chyba - nelze odinstalovat
         mov       ax,es                    ; segment INT 27h
         cmp       ax,ds:[SegRez]           ; je to rezidentn¡ program ?
         jne       Chyba2                   ; nelze odinstalovat

; ------ n vrat p–vodn¡ho vektoru p©eru¨en¡ INT 21h

         mov       es,ds:[SegRez]           ; rezidentn¡ instalace
         push      ds
         lds       dx,es:[Old21]            ; p–vodn¡ adresa INT 21h
         mov       ax,2521h
         int       21h                      ; n vrat p–vodn¡ho INT 21h
         pop       ds

; ------ n vrat p–vodn¡ho vektoru p©eru¨en¡ INT 20h

         push      ds
         lds       dx,es:[Old20]            ; p–vodn¡ adresa INT 20h
         mov       ax,2520h
         int       21h                      ; n vrat p–vodn¡ho INT 20h
         pop       ds

; ------ n vrat p–vodn¡ho vektoru p©eru¨en¡ INT 27h

         push      ds
         lds       dx,es:[Old27]            ; p–vodn¡ adresa INT 27h
         mov       ax,2527h
         int       21h                      ; n vrat p–vodn¡ho INT 27h
         pop       ds

; ------ vymaz n¡ k¢dovac¡ tabulky

         cld                                ; smˆr nahoru
         mov       di,offset Klic           ; k¢dovac¡ kl¡‡
         xor       al,al                    ; mazac¡ bajt
         mov       cx,KlicN                 ; d‚lka kl¡‡e
         rep       stosb                    ; vymaz n¡ kl¡‡e

; ------ uvolnˆn¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ rezidentn¡ ‡ sti

         mov       dx,offset DeIns
         jmp       Chyba2                   ; konec programu

; -----------------------------------------------------------------------------

ZadHesl0:call      Vymaz                    ; vymaz n¡ © dku
         int       20h

; ------ zad n¡ k¢dovac¡ho hesla

ZadHesl: mov       dx,offset HesloTxt       ; text v˜zvy
         mov       ah,9
         int       21h                      ; zad n¡ textu hesla

; ------ vstup jednoho znaku

         xor       cx,cx
         mov       si,offset Buffer         ; buffer k ulo‘en¡ textu hesla
ZadHesl2:mov       ah,7
         int       21h                      ; vstup znaku z kl vesnice
         or        al,al                    ; bude Scan k¢d ?
         jnz       ZadHesl3                 ; je platn˜ znak
         mov       ah,7
         int       21h                      ; ignorov n¡ kl vesy
         jmp       short ZadHesl2           ; vstup dal¨¡ho znaku

; ------ rozli¨en¡ p©eru¨en¡ zad v n¡ textu

ZadHesl3:cmp       al,27                    ; kl vesa Esc ?
         je        ZadHesl0                 ; p©eru¨en¡ zad v n¡ textu Esc
         cmp       al,3                     ; kl vesa Break ?
         je        ZadHesl0                 ; p©eru¨en¡ zad v n¡ textu Break

; ------ zru¨en¡ posledn¡ho znaku

         cmp       al,8                     ; krok zpˆt ?
         jne       ZadHesl4                 ; nen¡ krok zpˆt
         jcxz      ZadHesl2                 ; nen¡ ‘ dn˜ znak v bufferu
         dec       si                       ; sn¡‘en¡ ukazatele znak–
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         call      BackSP                   ; vymaz n¡ znaku
         jmp       short ZadHesl2           ; vstup dal¨¡ho znaku

; ------ ulo‘en¡ platn‚ho znaku

ZadHesl4:cmp       al,13                    ; je ukon‡en¡ volby Enter ?
         je        ZadHesl6                 ; ukon‡en¡ volby Enter
         cmp       al,"a"                   ; je mal‚ p¡smeno ?
         jb        ZadHesl5                 ; nen¡ mal‚ p¡smeno
         cmp       al,"z"
         ja        ZadHesl5
         sub       al,32                    ; korekce na velk‚ p¡smeno
ZadHesl5:mov       ds:[si],al               ; ulo‘en¡ znaku
         inc       si                       ; zv˜¨en¡ ukazatele textu
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         mov       al,"#"                   ; n hradn¡ znak
         call      DispCh                   ; zobrazen¡ znaku
         jmp       short ZadHesl2           ; vstup dal¨¡ho znaku

; ------ ukon‡en¡ volby

ZadHesl6:call      Vymaz                    ; vymaz n¡ zadan‚ho textu
         or        cx,cx                    ; je nˆco zad no ?
         jnz       ZadHesl7                 ; je nˆco zad no
         jmp       Instal2                  ; vypnut¡ programu

; ------ sestaven¡ k¢dovac¡ho kl¡‡e

ZadHesl7:or        byte ptr es:[Param],1    ; zapnut¡ programu
         mov       di,offset Klic           ; k¢dovac¡ kl¡‡
         mov       bx,KlicN                 ; d‚lka k¢dovac¡ho kl¡‡e
         mov       dx,-1                    ; v˜choz¡ hodnota k¢du

; ------ v˜po‡et k¢dovac¡ho kl¡‡e

ZadHes77:mov       si,offset Buffer         ; buffer s textem hesla
         call      CheckSum                 ; kontroln¡ sou‡et kl¡‡e
         mov       es:[di],dl               ; ni‘¨¡ bajt kontroln¡ho sou‡tu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy v kl¡‡i
         dec       bx                       ; ‡¡ta‡ d‚lky kl¡‡e
         jnz       ZadHes77                 ; dal¨¡ bajt kl¡‡e

; ------ ulo‘en¡ zadan‚ho disku

         mov       al,ds:[Disk]
         mov       es:[Disk],al             ; nastaven¡ nov‚ho disku

; ------ vymaz n¡ hesla

         push      es
         push      cs
         pop       es
         cld
         xor       al,al                    ; nulovac¡ bajt
         mov       di,offset Buffer         ; buffer s heslem
         rep       stosb                    ; vymaz n¡ hesla
         pop       es

; ------ instalace programu

ZadHes8: mov       ax,ds
         cmp       ax,ds:[SegRez]           ; je program ji‘ instalov n
         jne       ZadHesl9                 ; program je ji‘ instalov n

; ------ instalace INT 21h

         mov       ax,3521h
         int       21h                      ; poskytnut¡ adresy INT 21h
         mov       word ptr ds:[Old21],bx   ; £schova offsetu INT 21h
         mov       word ptr ds:[Old21+2],es ; £schova segmentu INT 21h
         mov       ax,2521h
         mov       dx,offset Int21          ; nov  adresa INT 21h
         int       21h                      ; instalace nov‚ obsluhy INT 21h

; ------ instalace INT 20h

         mov       ax,3520h
         int       21h                      ; poskytnut¡ adresy INT 20h
         mov       word ptr ds:[Old20],bx   ; £schova offsetu INT 20h
         mov       word ptr ds:[Old20+2],es ; £schova segmentu INT 20h
         mov       ax,2520h
         mov       dx,offset Int20          ; nov  adresa INT 20h
         int       21h                      ; instalace nov‚ obsluhy INT 20h

; ------ instalace INT 27h

         mov       ax,3527h
         int       21h                      ; poskytnut¡ adresy INT 27h
         mov       word ptr ds:[Old27],bx   ; £schova offsetu INT 27h
         mov       word ptr ds:[Old27+2],es ; £schova segmentu INT 27h
         mov       ax,2527h
         mov       dx,offset Int27          ; nov  adresa INT 27h
         int       21h                      ; instalace nov‚ obsluhy INT 27h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; zru¨en¡ segmentu prost©ed¡
         mov       dx,offset Instal         ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu


ZadHesl9:int       20h

; -----------------------------------------------------------------------------
;        vymaz n¡ © dku (CX znak–)
; -----------------------------------------------------------------------------

Vymaz    PROC      NEAR

         push      ax
         push      cx
         push      dx
         jcxz      Vymaz3
Vymaz1:  call      BackSP
         loop      Vymaz1
Vymaz3:  mov       dx,offset CrTxt
         mov       ah,9
         int       21h
         pop       dx
         pop       cx
         pop       ax
         ret

Vymaz    ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ znaku na displeji (krok zpˆt)
; -----------------------------------------------------------------------------

BackSP   PROC      NEAR

         push      ax
         mov       al,8                     ; znak k zobrazen¡ - krok zpˆt
         call      DispCh
         mov       al," "                   ; mazac¡ znak mezery
         call      DispCh
         mov       al,8                     ; znak k zobrazen¡ - krok zpˆt
         call      DispCh
         pop       ax
         ret

BackSP   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di
         push      ds
         push      es

         mov       ah,0eh
         mov       bx,7
         int       10h

;         mov       ds:[Buff],al
;         mov       bx,2
;         mov       ah,40h
;         mov       cx,1
;         mov       dx,offset Buff
;         int       21h                      ; z pis jednoho znaku na StdErr

;         mov       dl,al
;         mov       ah,2
;         int       21h

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z textu DS:SI/CX
; -----------------------------------------------------------------------------

ParmSpc  PROC      NEAR

ParmSpc1:call      ParmCh
         jc        ParmSpc9                 ; konec textu
         je        ParmSpc1                 ; je oddˆlova‡
         dec       si
         inc       cx
ParmSpc9:ret

ParmSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku DS:SI/CX
; -----------------------------------------------------------------------------

ParmCh   PROC      NEAR

; ------ test konce textu

         stc
         jcxz      ParmCh9
         cmp       byte ptr ds:[si],13
         stc
         je        ParmCh9

; ------ na‡ten¡ dal¨¡ho znaku

         cld
         lodsb
         dec       cx

; ------ p©evod mal˜ch p¡smen na velk 

         cmp       al,"a"
         jb        ParmCh2
         cmp       al,"z"
         ja        ParmCh2
         sub       al,32

; ------ n hrada tabel toru mezerou

ParmCh2: cmp       al,9
         jne       ParmCh3
         mov       al," "

; ------ p©¡znak, ‘e je oddˆlova‡

ParmCh3: cmp       al," "
         clc
ParmCh9: ret

ParmCh   ENDP

; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
;        DX=vstupn¡ hodnota kontroln¡ho sou‡tu
; VSTUP:DX=v˜stupn¡ hodnota kontroln¡ho sou‡tu
; -----------------------------------------------------------------------------

PUBLIC   CheckSum

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      di
         jcxz      CheckSm2                 ; nejsou ‘ dn  data
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt

CheckSm2:pop       di
         pop       cx
         pop       ax
         ret

CheckSum ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

VypTxt   db        'Kodovani vypnuto.'
CrTxt    db        13,10,'$'

Buff     db        0

Buffer   label     byte                     ; buffer k ulo‘en¡ textu hesla

KodTxt   db        'Aktivni kodovany disk '
KodTxt0  db        'A:',13,10,'$'

ErrTxt   db        'Parametry: A: az Z: = kodovaci heslo pro disk A az Z',13,10
         db        '           ...  nebo 0 = vypnuti, !=odinstalovani',13,10
         db        '          /A az /Z = instalacni varianta A az Z',13,10,'$'

DeInsTxt db        'Program nelze odinstalovat z pameti !',13,10,'$'

DeIns    db        'Program byl odinstalovan.',13,10,'$'

HesloTxt db        'Zadejte heslo a <Enter>: $'

Code     ENDS
         END       Start

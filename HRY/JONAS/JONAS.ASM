
; *****************************************************************************
;
;                                    JONAS
;
;                      P�edpov�� narozen� holky nebo kluka
;                        podle metody MUDr Eugena Jon��e
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

Start:

; ------ zad�n� data narozen� matky

Start1:  mov       dx,offset zad1txt
         call      DispTxt                  ; v�zva

         mov       ah,10
         mov       dx,offset Datum
         int       21h                      ; zad�n� textu

         mov       bh,0
         mov       bl,ds:[Datum+1]
         mov       byte ptr ds:[Datum+2+bx],13 ; konec textu CR
         call      DispCr                   ; od��dkov�n� textu

Start12: mov       si,offset Datum+2
         call      DekSpc
         jnc       Start13

         jmp       Konec

Start13:
         call      DekDate                  ; dek�dov�n� zadan�ho data
         jnc       Start3

Start2:  mov       dx,offset Err1Txt        ; chyba zad�n�
         call      DispTxt
         jmp       short Start1

Start3:  call      JulDat                   ; datum narozen� abolutn�
         mov       ds:[N1],ax               ; datum narozen� absolutn�

; ------ zad�n� �asu narozen� matky

Start4:  mov       dx,offset zad2txt
         call      DispTxt                  ; v�zva

         mov       ah,10
         mov       dx,offset Datum
         int       21h                      ; zad�n� textu

         mov       bh,0
         mov       bl,ds:[Datum+1]
         mov       byte ptr ds:[Datum+2+bx],13 ; konec textu CR

         call      DispCr                   ; od��dkov�n� textu

         mov       si,offset Datum+2
         call      DekSpc
         jnc       Start41

         mov       byte ptr ds:[Minuta],0
         mov       byte ptr ds:[Hodina],12
         jmp       short Start43

Start41:
         call      DekTime                  ; dek�dov�n� zadan�ho �asu
         jnc       Start43

Start42: mov       dx,offset Err2Txt        ; chyba zad�n�
         call      DispTxt
         jmp       short Start4

; ------ korekce �asu

Start43: mov       al,60                    ; po�et minut na hodinu
         mul       byte ptr ds:[Hodina]     ; p�epo�et hodin na minuty
         add       al,ds:[Minuta]
         adc       ah,0
         mov       ds:[T1],ax               ; �as narozen� matky absolutn�

; ------ v�po�et f�ze m�s�ce

         call      Moon                     ; v�po�et f�ze m�s�ce




;call      JulDat                   ; datum narozen� abolutn�
;         mov       ds:[N1],ax               ; datum narozen� absolutn�

Start44:




Konec:

         int       20h

; -----------------------------------------------------------------------------
;        absolutn� po�et dn� od 31.12.1899 (AX=po�et dn�)
; -----------------------------------------------------------------------------

JulDat   PROC      NEAR

         push      bx
         push      cx
         push      dx

         mov       cx,ds:[Rok]
         mov       bh,ds:[Mesic]
         mov       bl,ds:[Den]
         call      KonvDatN                 ; konverze data na den

         sub       ax,word ptr ds:[Den1]
         sbb       dx,word ptr ds:[Den1+2]
         jnc       JulDat3
         xor       ax,ax
JulDat3:

JulDat9: pop       dx
         pop       cx
         pop       bx
         ret

JulDat   ENDP

; -----------------------------------------------------------------------------
;        v�po�et data z absolutn�ho po�tu dn� od 31.12.1899 (AX=po�et dn�)
; -----------------------------------------------------------------------------

InvJul   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         xor       dx,dx
         add       ax,word ptr ds:[Den1]
         adc       dx,word ptr ds:[Den1+2]

         call      KonvNDat                 ; v�po�et data

         mov       ds:[Den],bl
         mov       ds:[Mesic],bh
         mov       ds:[Rok],cx

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InvJul   ENDP

; *****************************************************************************
;                            KonvDatN
;                     p�evod data na po�et dn�
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
;        BH=m�s�c
;        BL=den
; V�STUP:DX:AX=den absolutn�
; *****************************************************************************

KonvDatN PROC      NEAR

; ------ �schova registr�

         push      bx
         push      cx
         push      si

; ------ p��prava registr� a p�i�ten� dne

         xor       dx,dx                    ; ni��� slovo st�ada�e
         xor       si,si                    ; vy��� slovo st�ada�e
         mov       dl,bl                    ; den
         dec       dl                       ; korekce (0...)

; ------ p�i�ten� m�s�c�

KonvDtN1:dec       bh                       ; sn��en� ukazatele m�s�ce
         jz        KonvDtN2                 ; byly ji� v�echny m�s�ce
         call      MesicGet                 ; stanoven� po�tu dn� v m�s�ci
         add       dx,ax                    ; p�i�ten� po�tu dn� v m�s�ci
         jmp       short KonvDtN1           ; dal�� m�s�c

; ------ p�i�ten� let

KonvDtN2:sub       cx,1                     ; sn��en� ukazatele rok�
         jc        KonvDtN3                 ; byly ji� v�echny roky
         cmp       cx,1979
         jne       KonvDtN4

         add       dx,word ptr ds:[Den0]
         adc       si,word ptr ds:[Den0+2]
         jmp       short KonvDtN3

KonvDtN4:call      RokGet                   ; stanoven� po�tu dn� v roce
         add       dx,ax                    ; p�i�ten� po�tu dn� v roce
         adc       si,0                     ; p�enos do vy���ho slova
         jmp       short KonvDtN2           ; dal�� rok

; ------ n�vrat registr�

KonvDtN3:mov       ax,dx                    ; den absolutn� LOW
         mov       dx,si                    ; den absolutn� HIGH
         pop       si
         pop       cx
         pop       bx
         ret

KonvDatN ENDP

; *****************************************************************************
;                              KonvNDat
;                  p�evod absolutn�ho dne na datum
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=den absolutn�
; V�STUP:AL=den v t�dnu (0...)
;        AH=po�et dn� v m�s�ci
;        BH=m�s�c
;        BL=den
;        CX=rok
; *****************************************************************************

KonvNDat PROC      NEAR

; ------ �schova registr�

         push      dx
         push      si
         push      di
         push      bp

; ------ p��prava registr�

         mov       bp,dx                    ; den HIGH
         mov       di,ax                    ; den LOW
         mov       si,dx                    ; den HIGH
         mov       dx,ax                    ; den LOW
         xor       cx,cx                    ; CX <- 0

; ------ ode�ten� stolet�

KonvNDt1:call      StoGet                   ; stanoven� po�tu dn� ve stolet�
         sub       dx,ax                    ; stolet� dosa�eno ?
         sbb       si,0                     ; p�enos do vy���ho slova
         jc        KonvNDt2                 ; stolet� dosa�eno OK
         add       cx,100                   ; zv��en� ukazatele roku o 100 let
         jmp       short KonvNDt1           ; p�evod dal��ho stolet�
KonvNDt2:add       dx,ax                    ; n�vrat stolet�
         adc       si,0                     ; p�enos do vy���ho slova

; ------ ode�ten� rok� ve stolet�

KonvNDt3:call      RokGet                   ; stanoven� po�tu dn� v roce
         sub       dx,ax                    ; roku dosa�eno ?
         sbb       si,0                     ; p�enos do vy���ho slova
         jc        KonvNDt4                 ; rok je nastaven OK
         inc       cx                       ; zv��en� ukazatele roku
         jmp       short KonvNDt3           ; p�evod dal��ho roku
KonvNDt4:add       dx,ax                    ; n�vrat roku
         adc       si,0                     ; p�enos do vy���ho slova

; ------ ode�ten� m�s�ce

         xor       bx,bx                    ; p�ednastaven� m�s�ce a dne
KonvNDt5:inc       bh                       ; zv��en� ��sla m�s�ce
         call      MesicGet                 ; stanoven� po�tu dn� v m�s�ci
         sub       dx,ax                    ; je m�s�c nalezen ?
         sbb       si,0                     ; p�enos do vy���ho slova
         jnc       KonvNDt5                 ; p�evod dal��ho m�s�ce
         add       dx,ax                    ; n�vrat m�s�ce

; ------ stanoven� dne

         inc       dl                       ; den v m�s�ci
         mov       bl,dl                    ; den v m�s�ci

; ------ v�po�et dne v t�dnu

         push      bx
         push      ax

         mov       dx,bp                    ; den HIGH
         mov       ax,di                    ; den LOW
         add       ax,3                     ; korekce pro spr�vn� den
         adc       dx,0                     ; p�enod do vy���ho slova
         mov       bx,7                     ; po�et dn� v t�dnu

         push      ax                       ; den LOW
         mov       ax,dx                    ; den HIGH
         xor       dx,dx                    ; DX <- 0
         div       bx                       ; d�len� vy���ho slova
         pop       ax                       ; den LOW
         div       bx                       ; v�po�et dne v t�dnu
         mov       al,dl                    ; den v t�dnu

         pop       bx                       ; n�vrat po�tu dn� v m�s�ci
         mov       ah,bl                    ; po�et dn� v m�s�ci
         pop       bx

; ------ n�vrat registr�

         pop       bp
         pop       di
         pop       si
         pop       dx
         ret

KonvNDat ENDP

; -----------------------------------------------------------------------------
;                     stanoven� po�tu dn� v m�s�ci
; -----------------------------------------------------------------------------
; VSTUP: BH=m�s�c
;        CX=rok
;        DS=datov� segment
; V�STUP:AX=po�et dn�
; -----------------------------------------------------------------------------

MesicGet PROC      NEAR

         push      bx

; ------ v prosinci 1582 je 28 dn�

         cmp       cx,1582                  ; je rok 1582 ?
         jne       MesicGt1                 ; nen� rok 1582
         mov       ax,28                    ; je 28 dn� v prosinci
         cmp       bh,12                    ; je prosinec ?
         je        MesicGt2                 ; je prosinec 1582

; ------ po�et dn� v m�s�ci

MesicGt1:mov       bl,bh                    ; m�s�c
         xor       bh,bh                    ; BX=m�s�c
         mov       al,ds:[bx+PoctyDnu-1]    ; po�et dn� v m�s�ci
         cbw                                ; po�et dn� v m�s�ci
         cmp       bl,2                     ; je to �nor ?
         jne       MesicGt2                 ; nen� �nor
         call      RokTest                  ; test p�estupnosti roku
         jnc       MesicGt2                 ; rok nen� p�estupn�
         inc       ax                       ; po�et dn� v �noru = 29

MesicGt2:pop       bx
         ret

MesicGet ENDP

; -----------------------------------------------------------------------------
;                     stanoven� po�tu dn� v roce
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
; V�STUP:AX=po�et dn�
; -----------------------------------------------------------------------------

RokGet   PROC      NEAR

; ------ po�et dn� v roce 1582

         mov       ax,365-3                 ; po�et dn� v roce 1582
         cmp       cx,1582                  ; je rok 1582 ?
         je        RokGet1                  ;

; ------ po�et dn� podle p�estupnosti roku

         mov       ax,365                   ; po�et dn� v nep�estupn�m roce
         call      RokTest                  ; test p�estupnosti roku
         jnc       RokGet1                  ; rok nen� p�estupn�
         inc       ax                       ; po�et dn� v p�estup. roce 366
RokGet1: ret

RokGet   ENDP

; -----------------------------------------------------------------------------
;                    test p�estupnosti roku
; -----------------------------------------------------------------------------
; VSTUP: CX=rok
; V�STUP:CY=je p�estupn� rok
; -----------------------------------------------------------------------------

RokTest  PROC      NEAR

; ------ test, zda rok je n�sobkem 4

         test      cl,3                     ; je p�estupn� rok ?
         jnz       RokTest3                 ; nen� p�estupn� rok

; ------ p�ed rokem 1600 je p�estupn� v�dy

         cmp       cx,1600                  ; je p�ed rokem 1600 ?
         jb        RokTest3                 ; p�ed 1600 p�estupn� v�dy

; ------ �schova registr�

         push      ax
         push      bx
         push      dx

; ------ test, zda je stolet� n�sobkem 4

         mov       bx,100                   ; stolet�
         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         div       bx                       ; v�po�et stolet�
         or        dx,dx                    ; je stolet� ?
         jnz       RokTest1                 ; nen� stolet� - je p�estupn�
         test      ax,3                     ; je stolet� d�liteln� 4 ?
         jnz       RokTest2                 ; nen� d�liteln� - nen� p�estupn�

; ------ n�vrat registr�

RokTest1:stc                                ; p��znak p�estupn�ho roku
RokTest2:pop       dx
         pop       bx
         pop       ax

RokTest3:ret

RokTest  ENDP

; -----------------------------------------------------------------------------
;                      stanoven� po�tu dn� ve stolet�
; -----------------------------------------------------------------------------
; VSTUP: CX=rok (kon��c� 00 - stolet�)
; V�STUP:AX=po�et dn� ve stolet� (od roku CX po rok CX+99)
; -----------------------------------------------------------------------------

StoGet   PROC      NEAR

; ------ �schova registr�

         push      bx
         push      dx

; ------ v�po�et ��sla stolet�

         xor       dx,dx                    ; DX <- 0
         mov       ax,cx                    ; rok
         mov       bx,100                   ; po�et let ve stolet�
         div       bx                       ; v�po�et stolet�

; ------ po�et let ve stolet� 15xx

         cmp       ax,15                    ; je stolet� 15 ?
         jne       StoGet1                  ; nen� stolet� 15
         mov       ax,25*366+75*365-3       ; zkr�cen� p�estupn� stolet�
         jmp       short StoGet3

; ------ stolet� p�ed 1582 je p�estupn� v�dy

StoGet1: cmp       cx,1600                  ; je p�ed rokem 1600 ?
         jb        StoGet2                  ; je p�ed 1600 - p�estupn� v�dy

; ------ po�et let podle p�estupnosti stolet�

         test      al,3                     ; je stolet� d�liteln� 4 ?
         mov       ax,24*366+76*365         ; nep�estupn� stolet�
         jnz       StoGet3                  ; stolet� nen� p�estupn�
StoGet2: mov       ax,25*366+75*365         ; stolet� je p�estupn�

; ------ n�vrat registr�

StoGet3: pop       dx
         pop       bx
         ret

StoGet   ENDP


; -----------------------------------------------------------------------------
;        dek�dov�n� �asu
; -----------------------------------------------------------------------------

DekTime  PROC      NEAR

         call      DekNum                   ; dek�dov�n� hodiny
         jc        DekTime9
         mov       ds:[Hodina],al           ; hodina

         call      DekTec                   ; dek�dov�n� odd�lova�e
         jc        DekTime9

         call      DekNum                   ; dek�dov�n� minuty
         jc        DekTime9
         mov       ds:[Minuta],al           ; minuta
         clc

DekTime9:
         ret

DekTime  ENDP

; -----------------------------------------------------------------------------
;        dek�dov�n� data
; -----------------------------------------------------------------------------

DekDate  PROC      NEAR

         call      DekNum                   ; dek�dov�n� data
         jc        DekDate9
         mov       ds:[Den],al              ; den

         call      DekTec                   ; dek�dov�n� odd�lova�e
         jc        DekDate9

         call      DekNum                   ; dek�dov�n� m�s�ce
         jc        DekDate9
         mov       ds:[Mesic],al            ; m�s�c

         call      DekTec                   ; dek�dov�n� odd�lova�e
         jc        DekDate9

         call      DekNum                   ; dek�dov�n� roku
         jc        DekDate9
         cmp       ax,100
         ja        DekDate2
         add       ax,1900
DekDate2:mov       ds:[Rok],ax              ; rok
         clc

DekDate9:
         ret

DekDate  ENDP

; -----------------------------------------------------------------------------
;        dek�dov�n� odd�lovac� te�ky
; -----------------------------------------------------------------------------

DekTec   PROC      NEAR

         call      DekSpc
         call      DekCh
         jc        DekTec9
         cmp       al,"."
         je        DekTec9
         cmp       al,","
         je        DekTec9
         cmp       al,"/"
         je        DekTec9
         cmp       al,":"
         je        DekTec9
         stc

DekTec9: ret

DekTec   ENDP

; -----------------------------------------------------------------------------
;        dek�dov�n� ��sla
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

         push      dx
         xor       dx,dx
         call      DekSpc                   ; vypu�t�n� po��te�n�ch mezer
         call      DekNm                    ; prvn� ��slice
         jc        DekNum9

DekNum1: push      ax
         mov       ax,10
         mul       dx
         pop       dx
         mov       dh,0
         add       dx,ax
         call      DekNm
         jnc       DekNum1
         clc

DekNum9: mov       ax,dx
         pop       dx
         ret

DekNum   ENDP

DekNm    PROC      NEAR

         call      DekCh
         jc        DekNm9
         cmp       al,"0"
         jb        DekNm8
         cmp       al,"9"
         ja        DekNm8
         sub       al,"0"
         ret

DekNm8:  dec       si
         stc
DekNm9:  ret

DekNm    ENDP

; -----------------------------------------------------------------------------
;        vypu�t�n� po��te�n�ch mezer (DS:SI=ukazatel textu, CY=konec textu)
; -----------------------------------------------------------------------------

DekSpc   PROC      NEAR

         call      DekCh
         jc        DekSpc9
         cmp       al," "
         je        DekSpc
         dec       si
DekSpc9: ret

DekSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku p�i dek�dov�n� (DS:SI=ukazatel textu, CY=nen� dal�� znak)
; -----------------------------------------------------------------------------

DekCh    PROC      NEAR

         mov       al,ds:[si]
         cmp       al,9
         jne       DekCh1
         mov       al," "
DekCh1:  cmp       al," "
         jb        DekCh9
         inc       si
DekCh9:  ret

DekCh    ENDP

; -----------------------------------------------------------------------------
;        od��dkov�n�
; -----------------------------------------------------------------------------

DispCr   PROC      NEAR

         push      dx
         mov       dx,offset CrTxt
         call      DispTxt
         pop       dx
         ret

DispCr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen� textu
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

A        db        0
I        db        0
J        db        0
Minuta   db        0
Hodina   db        0
Den      db        0                        ; den
Mesic    db        0                        ; m�s�c
Rok      dw        0                        ; rok
N1       dw        0                        ; datum narozen� absolutn�
T1       dw        0                        ; �as narozen� matky absolutn�

Den0     dd        723189                   ; den 1.1.1980
Den1     dd        693970                   ; den 31.12.1899

; ------ po�ty dn� v m�s�c�ch roku

PoctyDnu db        31                       ; leden
         db        28                       ; �nor
         db        31                       ; b�ezen
         db        30                       ; duben
         db        31                       ; kv�ten
         db        30                       ; �erven
         db        31                       ; �ervenec
         db        31                       ; spren
         db        30                       ; z���
         db        31                       ; ��jen
         db        30                       ; listopad
         db        31                       ; prosinec

Zad1Txt  db        'Datum narozeni matky [Den.Mesic.Rok] (Enter=konec): $'
Err1Txt  db        'Chybne zadani data !',13,10,'$'

Zad2Txt  db        'Cas narozeni matky [Hodina:Minuta] (Enter=12:00): $'
Err2Txt  db        'Chybne zadani casu !',13,10,'$'

CrTxt    db        13,10,'$'

Datum    db        127,0,128 dup(?)         ; buffer k zad�n� data

code     ends
         end       Start

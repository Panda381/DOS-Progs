
; Stanice sly¨iteln‚ v Evropˆ:
; ---------------------------
;  DCF77 - Mainfligen (SRN)
;  HBG - Prangins (›v˜carsko)
;  MSF - Rugby (Velk  Brit nie)
;  OMA - Liblice (€R) (viz AR 1976 a 1979)
;
; Vys¡la‡ DCF je um¡stˆn v Mainfligenu pobl¡‘ Frankfurtu nad Mohanem (SRN).
; Vys¡la‡ vys¡l  na kmito‡tu 77.5 kHz a m  v˜kon 27 kW. Nep©esnost £daje
; je 2 * 10^-13 za 100 dn¡. Sekundov  zna‡ka je vytvo©ena zmen¨en¡m amplitudy
; nosn‚ na 25 % na za‡ tku ka‘d‚ sekundy. D‚lka sekundov‚ zna‡ky je buƒ 100 ms
; (="0") nebo 200 ms (="1"). Bˆhem ka‘d‚ minuty je odvys¡l na £pln  ‡asov 
; informace mezi 20. a‘ 58. sekundou - tj. st©edoevropsk˜ ‡as, platn˜ pro
; n sleduj¡c¡ minutu sou‡asnˆ s datem. Za‡ tek p©enosu za‡¡n  ve 20. sekundˆ
; ka‘d‚ minuty odvys¡l n¡m sekundov‚ zna‡ky "1". V¨echny £daje jsou p©en ¨eny
; v BCD k¢du (od nejni‘¨¡ch bit– a od nejni‘¨¡ch ‡¡slic). —daje minut jsou
; odvys¡l ny mezi 21. a‘ 27. sekundou (4 + 3 bity). V 28. sekundˆ je vys¡l n
; paritn¡ bit pro minuty (sud  parita). —daje hodin jsou vys¡l ny mezi
; 29. a‘ 34. sekundou (4 + 2 bity), ve 35. sekundˆ je vys¡l n paritn¡ bit pro
; hodiny. Mezi 36. a‘ 41. sekundou je vys¡l n den (4 + 2 bity), mezi
; 42. a‘ 44. sekundou je vys¡l n den v t˜dnu (3 bity, 0=nedˆle), mezi 45.
; a‘ 49. sekundou je vys¡l n mˆs¡c a mezi 50. a‘ 57. sekundou je vys¡l n
; rok (4 + 4 bity, pouze 2 posledn¡ ‡¡slice bez stolet¡). V 58. sekundˆ
; je vys¡l n paritn¡ bit pro datum. Za‡ tek minuty se synchronizuje
; vyhodnocen¡m minutov‚ zna‡ky, kter  je vytvo©ena chybˆj¡c¡ sekundovou
; zna‡kou v 59. sekundˆ. Vys¡la‡ DCF77 je v chodu nep©etr‘itˆ kromˆ
; ka‘d‚ho druh‚ho £ter˜ v mˆs¡ci mezi 5. a 9. hodinou (prob¡h  technick 
; £dr‘ba).


AdrMER   EQU       20*80*2                  ; adresa mˆ©¡tka
AdrBit   EQU       8*160                    ; adresa bit–
AdrTim   EQU       12*160+2*25              ; adresa ‡asu

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

Port     dw        0                        ; ‡¡slo portu COM - 1 (tj. 0 a‘ 3)
AdrPort  dw        0                        ; adresa portu COM


; -----------------------------------------------------------------------------
;        instalace programu do pamˆti
; -----------------------------------------------------------------------------

; ------

Instal:


; ------ p©¡prava k rozboru p©¡kazov‚ho © dku

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld

Instal2: jcxz      Instal3
         lodsb
         dec       cx
         cmp       al," "
         jbe       Instal2
         mov       ds:[InstTxt1],al
         sub       al,"1"
         jb        Chyba
         mov       byte ptr ds:[Port],al
         cmp       al,4
         jb        Instal3

Chyba:   mov       dx,offset HelpTxt
Chyba1:  mov       ah,9
         int       21h
         int       20h

; ------ adresa portu COM

Instal3: mov       ax,40h
         mov       es,ax
         mov       bx,ds:[Port]             ; ‡¡slo portu COM
         shl       bx,1
         mov       ax,es:[bx]               ; AX <- adresa portu COM
         mov       dx,offset InstTxt
         or        ax,ax                    ; je port COM nainstalov n ?
         jz        Chyba1                   ; nen¡ nainstalov n
         mov       ds:[AdrPort],ax          ; adresa portu COM

; ------ instalace INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ instalace INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h

         mov       dx,offset Int23
         mov       ax,2523h
         int       21h
         mov       ax,2524h
         int       21h


         call      initDisp                 ; inicializa‡n¡ zobrazen¡

Instal6: sti
         call      Disp                     ; obsluha zobrazen¡

         test      byte ptr ds:[Param],bit0
         jz        Instal6



         push      ds
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h
         pop       ds

         push      ds
         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h
         pop       ds

         call      DeInit                   ; n vrat nastaven¡ hodin

         mov       ah,1
         int       16h
         jz        Instal9
         mov       ah,0
         int       16h
Instal9:

         call      InitVMod

         int       20h

Int23:   iret

; -----------------------------------------------------------------------------
;        inicializa‡n¡ zobrazen¡
; -----------------------------------------------------------------------------

InitDisp PROC      NEAR

         call      InitVMod                 ; inicializace videom¢du

; ------ zobrazen¡ linky mˆ©¡tka

         cld
         mov       es,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       di,AdrMER                ; adresa mˆ©¡tka
         mov       ah,0ah
         mov       cx,80
         mov       si,offset MerTxt
InitDsp2:lodsb
         stosw
         loop      InitDsp2

         mov       ah,0fh
         mov       cl,80
InitDsp3:lodsb
         stosw
         loop      InitDsp3

         mov       ah,0eh
         mov       cl,2*80
InitDsp4:lodsb
         stosw
         loop      InitDsp4


         call      ImpVyp9                  ; zobrazen¡ indik toru

; ------ nastaven¡ portu

         mov       dx,ds:[AdrPort]          ; adresa portu
         add       dx,4
         mov       al,9
         out       dx,al

         ret

InitDisp ENDP

; -----------------------------------------------------------------------------
;        obsluha zobrazen¡
; -----------------------------------------------------------------------------
;þ
XXXK     dd        1

XXX      dd        1

Disp     PROC      NEAR

         sub       word ptr ds:[xxx],1
         sbb       word ptr ds:[xxx+2],0
;         jnc        Disp4

         mov       ax,word ptr ds:[xxxk]
         mov       word ptr ds:[xxx],ax
         mov       ax,word ptr ds:[xxxk+2]
         mov       word ptr ds:[xxx+2],ax


; ------ na‡ten¡ stavu portu

         mov       dx,ds:[AdrPort]          ; adresa portu
         add       dx,6
         in        al,dx                    ; ‡ten¡ stavu modemu
         test      al,10h                   ; je sign l ?
         jnz       Disp4                    ; sign l je zapnut

; ------ test, zda je sign l ji‘ vypnut

Disp2:   test      byte ptr ds:[Param],bit1 ; je sign l ji‘ vypnut ?
         jz        Disp8                    ; sign l je ji‘ vypnut

         cmp       word ptr ds:[Cit08],2    ; minim lnˆ 110 ms
         jb        Disp8

         and       byte ptr ds:[Param],not bit1 ; vypnut¡ sign lu
         call      ImpVyp                   ; vypnut¡ impulsu

;         sti
;         xor       ax,ax
;         mov       es,ax
;         mov       ax,es:[46ch]
;Disp5:   cmp       ax,es:[46ch]
;         je        Disp5


         jmp       short Disp8

; ------ test, zda je sign l ji‘ zapnut

Disp4:   test      byte ptr ds:[Param],bit1 ; je sign l ji‘ zapnut ?
         jnz       Disp8                    ; sign l je ji‘ zapnut

         cmp       word ptr ds:[Cit08],12   ; minim lnˆ 660 ms
         jb        Disp8

         or        byte ptr ds:[Param],bit1 ; zapnut¡ sign lu

         call      ImpZap                   ; zapnut¡ impulsu

Disp8:   ret

Disp     ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ impulsu
; -----------------------------------------------------------------------------

ImpZap   PROC      NEAR

         mov       es,ds:[AdrVRAM]          ; adresa videopamˆti

; ------ na‡ten¡ ‡asu

         call      GetTime                  ; na‡ten¡ ‡asu
         cmp       dx,9                     ; je jen kr tk  prodleva ?
         jae       ImpZap2                  ; je dlouh˜ ‡as
         add       word ptr ds:[Stradac],ax
         adc       word ptr ds:[Stradac+2],dx
         jmp       short ImpZap8

; ------ impuls je platn˜

ImpZap2: cmp       word ptr ds:[Stradac+2],3 ; je to "1" ?
         mov       al,"1"                   ; je to "1"
         jae       ImpZap3                  ; je to "1"
         dec       ax                       ; jinak "0"
ImpZap3: mov       di,ds:[UkazBit]          ; ukazatel bit–
         mov       byte ptr es:[di+160]," " ; vymaz n¡ ukazatele
         cld
         mov       ah,0eh
         stosw

         cmp       dx,20                    ; byla mezera ?
         jb        ImpZap4                  ; nebyla mezera
         mov       di,AdrBit                ; za‡ tek © dku

ImpZap4: cmp       di,AdrBit+2*79
         jbe       ImpZap5
         dec       di
         dec       di
ImpZap5: mov       ds:[UkazBit],di

         mov       al,30
         mov       ah,0bh
         mov       es:[di+160],ax

         xor       ax,ax
         mov       word ptr ds:[Stradac],ax
         mov       word ptr ds:[Stradac+2],ax

         call      DispTim                  ; zobrazen¡ ‡asu

; ------ zobrazen¡ indik toru

ImpZap8: mov       di,4*80*2 + 33*2
         mov       es,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       ah,4
         cld
         mov       al,"Û"                   ; sv¡t¡
         mov       cx,14
         rep       stosw
         ret

ImpZap   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ impulsu
; -----------------------------------------------------------------------------

ImpVyp   PROC      NEAR

; ------ na‡ten¡ ‡asu -> DX:AX

         call      GetTime                  ; na‡ten¡ ‡asu
         cmp       word ptr ds:[Stradac],0  ; je to prvn¡ impuls ?
         jne       ImpVyp1                  ; nen¡ prvn¡ impuls
         cmp       word ptr ds:[Stradac+2],0
         jne       ImpVyp1                  ; nen¡ prvn¡ impuls
         or        dx,dx
         jnz       ImpVyp1                  ; impuls je dost dlouh˜
         cmp       ax,20000                 ; asi tak minim lnˆ 17 ms
         jb        ImpVyp2                  ; je jen kr tk˜ impuls
ImpVyp1: add       word ptr ds:[Stradac],ax
         adc       word ptr ds:[Stradac+2],dx

; ------ v˜po‡et polohy indik toru

ImpVyp2: mov       cx,3977                  ; dˆlitel pro p©epo‡et
         cmp       dx,cx                    ; bylo by p©ete‡en¡ ?
         jae       ImpVyp4                  ; bylo by p©ete‡en¡
         div       cx                       ; v˜po‡et d¡lk–
         cmp       ax,80                    ; p©ete‡en¡ ?
         jae       ImpVyp4                  ; p©ete‡en¡

; ------ ozna‡en¡ v mapˆ

         xchg      ax,bx                    ; BX <- poloha
         mov       byte ptr ds:[Mapa+bx],30 ; d‚lka trv n¡ impulsu

; ------ zobrazen¡ indik toru

         mov       al,"Û"
         mov       ah,4
         call      DispInd

; ------ vypnut¡ indik toru sign lu (je vol no p©i startu !)

ImpVyp4:
ImpVyp9: mov       es,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       di,4*80*2 + 33*2
         mov       al,"Ä"                   ; nesv¡t¡
         mov       ah,4
         cld
         mov       cx,14
         rep       stosw
         ret

ImpVyp   ENDP

; -----------------------------------------------------------------------------
;        obsluha dek¢dov n¡ a zobrazen¡ ‡asu
; -----------------------------------------------------------------------------
;þ
DispTim  PROC      NEAR

         cld
         mov       es,ds:[AdrVRAM]          ; adresa videopamˆti
         mov       si,AdrBit+2*21
         mov       di,AdrBit + 3*160

         mov       ah,0fh

; ------ minuta (21 a‘ 27)

         xor       cx,cx
         mov       bl,27
         call      Get4Nm
         call      Get3Nm
         mov       al,":"
         call      Get4NmCh

; ------ parita minut (28)

         call      GetBit                   ; parita minut

; ------ hodina (29 a‘ 34)

         mov       bl,24
         xor       cx,cx
         call      Get4Nm
         call      Get2Nm

; ------ parita hodin (35)

         call      GetBit

; ------ den (36 a‘ 41)

         mov       bl,10
         xor       cx,cx
         call      Get4Nm
         call      Get2Nm

; ------ den v t˜dnu (42 a‘ 44)

         mov       bl,0
         call      Get3Nm

         push      si
         push      cx

         mov       di,AdrTim
         mov       bl,es:[di]
         mov       bh,0
         sub       bl,"0"
         shl       bx,1
         shl       bx,1
         shl       bx,1
         add       bx,offset DnyTxt
         mov       si,bx
         mov       cx,8
DispTim1:lodsb
         stosw
         loop      DispTim1

         pop       cx
         pop       si

; ------ mˆs¡c (45 a‘ 49)

         mov       bl,13
         call      Get4Nm
         call      Get1Nm
         mov       al,"."
         call      Get4NmCh

; ------ rok (50 a‘ 57)

         mov       bl,18
         call      Get4Nm
         call      Get4Nm

         cmp       byte ptr es:[AdrTim+18*2-2],"8"
         jae       DispTim2

         mov       al,"0"
         call      Get4NmCh
         mov       al,"2"
         jmp       short DispTim3

DispTim2:mov       al,"9"
         call      Get4NmCh
         mov       al,"1"
DispTim3:call      Get4NmCh

         mov       al,"."
         call      Get4NmCh

; ------ parita pro datum

         call      GetBit

         ret

DispTim  ENDP

; -----------------------------------------------------------------------------
;     na‡ten¡ 1-bit ‡¡slice AL z pozice ES:SI videopamˆti (CL=st©ada‡ parity)
; -----------------------------------------------------------------------------

Get1Nm   PROC      NEAR

         mov       al,80h
         jmp       short Get4Nm1

Get1Nm   ENDP

; -----------------------------------------------------------------------------
;     na‡ten¡ 2-bit ‡¡slice AL z pozice ES:SI videopamˆti (CL=st©ada‡ parity)
; -----------------------------------------------------------------------------

Get2Nm   PROC      NEAR

         mov       al,80h
         jmp       short Get4Nm2

Get2Nm   ENDP

; -----------------------------------------------------------------------------
;     na‡ten¡ 3-bit ‡¡slice AL z pozice ES:SI videopamˆti (CL=st©ada‡ parity)
; -----------------------------------------------------------------------------

Get3Nm   PROC      NEAR

         mov       al,80h
         jmp       short Get4Nm3

Get3Nm   ENDP

; -----------------------------------------------------------------------------
;     na‡ten¡ 4-bit ‡¡slice AL z pozice ES:SI videopamˆti (CL=st©ada‡ parity)
; -----------------------------------------------------------------------------

Get4Nm   PROC      NEAR

         mov       al,80h
         call      GetBit
         rcr       al,1
Get4Nm3: call      GetBit
         rcr       al,1
Get4Nm2: call      GetBit
         rcr       al,1
Get4Nm1: call      GetBit
         rcr       al,1

Get4Nm0: shr       al,1
         jnc       Get4Nm0

         add       al,"0"                   ; korekce na ASCII znak

Get4NmCh:push      bx
         mov       bh,0
         shl       bx,1
         mov       es:[bx+AdrTim],ax
         pop       bx
         dec       bx
         ret

Get4Nm   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bitu z pozice ES:SI videopamˆti -> CY="1", CL=st©ada‡ parity
; -----------------------------------------------------------------------------

GetBit   PROC      NEAR

         xor       cl,es:[si]
         and       cl,bit0

         cmp       byte ptr es:[si],"1"
         cmc
         inc       si
         inc       si
         ret

GetBit   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ indik toru - pozice BX, znak AX
; -----------------------------------------------------------------------------

DispInd  PROC      NEAR

         push      bx
         push      es

         mov       es,ds:[AdrVRAM]
         shl       bx,1
         add       bx,AdrMER-2*80
         mov       es:[bx],ax
         mov       es:[bx-160],ax

         pop       es
         pop       bx
         ret

DispInd  ENDP

; -----------------------------------------------------------------------------
;        inicializace videom¢du
; -----------------------------------------------------------------------------

InitVMod PROC      NEAR

         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du

         cmp       al,7
         je        InitVMd2
         mov       al,3
         mov       byte ptr ds:[AdrVRAM+1],0b8h

InitVMd2:mov       ah,0
         mov       ds:[VMod],al
         call      Int10                    ; inicializace videom¢du

         mov       dx,25*256
         mov       ah,2
         call      Int10                    ; vypnut¡ kurzoru

         ret

InitVMod ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡ta‡e ‡asu -> DX:AX
; -----------------------------------------------------------------------------
;þ
GetTime  PROC      NEAR

         cli

         mov       al,34h

         out       [43h],al
         jmp       $+2
         jmp       $+2
         jmp       $+2
         in        al,[40h]
         jmp       $+2
         jmp       $+2
         jmp       $+2
         mov       ah,al
         in        al,[40h]
         xchg      al,ah
         neg       ax

         push      ax
         xor       ax,ax
         out       [40h],al
         jmp       $+2
         jmp       $+2
         jmp       $+2
         out       [40h],al
         pop       ax

         xor       dx,dx                    ; DX <- 0
         xchg      dx,ds:[Cit08]            ; na‡ten¡ a nulov n¡ ‡¡ta‡e INT 08

         sti
         ret

GetTime  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Int10    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

         push      ax
         push      es

         xor       ax,ax
         mov       es,ax
         mov       ax,es:[41ch]

         pushf
         call      dword ptr cs:[Old09]

         cmp       ax,es:[41ch]
         je        Int098

;         mov       ah,1
;         int       16h
;         jz        Int096
;
;         mov       ah,0
;         int       16h
;
;         cmp       ah,48h
;         jne       Int092
;         add       word ptr cs:[XXXK],4600
;         adc       word ptr cs:[XXXK+2],0
;         jmp       short Int098
;
;Int092:  cmp       ah,50h
;         jne       Int096
;         sub       word ptr cs:[XXXK],4600
;         sbb       word ptr cs:[XXXK+2],0
;         jnc       Int098
;         mov       word ptr cs:[XXXK],1
;         mov       word ptr cs:[XXXK+2],0
;         jmp       short Int098
;
Int096:  or        byte ptr cs:[Param],bit0 ; p©¡znak p©eru¨en¡

Int098:  pop       es
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

         pushf
         call      dword ptr cs:[Old08]

         cli

         push      ax
         push      bx
         push      ds
         push      es

         push      cs
         pop       ds

         mov       es,ds:[AdrVRAM]
         mov       ah,9
         mov       al," "
         mov       bx,ds:[Poz08]
         mov       es:[bx],ax
         inc       bx
         inc       bx
         cmp       bx,49*2
         jb        Int080
         mov       bx,31*2
Int080:  mov       al,"³"
         mov       es:[bx],ax
         mov       ds:[Poz08],bx

         inc       word ptr ds:[Cit08]      ; zv˜¨en¡ ‡¡ta‡e p©ete‡en¡

         mov       ah,7
         mov       al," "
         xor       bx,bx
Int081:  cmp       byte ptr ds:[bx+Mapa],0
         je        Int082
         dec       byte ptr ds:[bx+Mapa]
         jnz       Int082
         call      DispInd                  ; vymaz n¡ indik toru

Int082:  inc       bx
         cmp       bl,80
         jb        Int081

         pop       es
         pop       ds
         pop       bx
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        n vrat nastaven¡ hodin
; -----------------------------------------------------------------------------

DeInit   PROC      NEAR

; ------ ‡ten¡ hodin syst‚mov‚ho ‡asu (AT)

         mov       dl,8ah                   ; p©ednastaven¡ na nesmysl
         mov       ah,2
         int       1ah                      ; ‡ten¡ hodin
         cmp       dl,1                     ; p©ete‡en¡ p©es p–lnoc ?
         ja        Deinit3                  ; hodiny neplat¡

; ------ n vrat p©¡znaku p©ete‡en¡ p©es p–lnoc

         jne       DeInit2                  ; nen¡ p©ete‡en¡ p©es p–lnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n vrat p©¡znaku p©ete‡en¡ p–lnoci

; ------ konverze z BCD form tu na bin rn¡

DeInit2: mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       dh,al

; ------ nastaven¡ ‡asu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu

DeInit3:
         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        Konverze ‡¡sla z BCD tvaru na bin rn¡
; -----------------------------------------------------------------------------

BcdBin   PROC      NEAR

         push      cx
         mov       ch,al
         and       ch,0fh
         and       al,0f0h
         mov       cl,4
         shr       al,cl
         mov       cl,10
         mul       cl
         add       al,ch
         pop       cx
         ret

BcdBin   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Poz08    dw        31*2

Stradac  dd        0                        ; st©ada‡ ‡asu pro 1 impuls
UkazBit  dw        AdrBit                   ; ukazatel k zobrazen¡ bit–

Cit08    dw        0                        ; ‡¡ta‡ pr–chod– INT 08h

Param    db        0                        ; parametry
                                            ;   bit 0: 1=p©eru¨en¡ od INT 09h
                                            ;   bit 1: 1=sign l je zapnut

Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old09    dd        0                        ; p–vodn¡ adresa iNT 09h

AdrVRAM  dw        0b000h                   ; adresa videopamˆti

VMod     db        3                        ; videom¢d 3 nebo 7

DnyTxt   db        '------- '               ; 0
         db        'pondeli '               ; 1
         db        '  utery '               ; 2
         db        ' streda '               ; 3
         db        'ctvrtek '               ; 4
         db        '  patek '               ; 5
         db        ' sobota '               ; 6
         db        ' nedele '               ; 7

HelpTxt  db        'DCF_ANAL - analyzator DCF77; (c) Miroslav Nemecek',13,10
         db        'Parametry programu:  1 az 4 ..... cislo portu COM',13,10
         db        '$'

MerTxt   db        'ÃÄÄÁÄÄÁÄÄÁÄÄÁÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÅÄÄÁÄÄÁÄÄÁÄÄÁÄÄÅÄÄÁÄ'
         db        '0              50            100            150            200            250   '
         db        '                              ',30,'                             ',30,'                   '
         db        '                              ³ "0"                         ³ "1"               '

InstTxt  db        'CHYBA - port COM'
InstTxt1 db        '1 neni nainstalovan v pocitaci !',13,10,'$'

Mapa     db        80 dup(0)                ; mapa impuls–
                                            ; 1 d¡lek = 3.333333 ms

Code     ENDS
         END       Start

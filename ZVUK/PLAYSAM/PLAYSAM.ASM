
; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h

code     segment
         assume    cs:code,ds:code

BUFFSIZE EQU       0f800h

; ------ rozbor jm‚na souboru

start:   call      DekParm                  ; dek¢dov n¡ parametr–

; ------ inicializace registr–

         push      cs
         pop       ds
         mov       ds:[SegPSP],es
         push      cs
         pop       es

; ------ otev©en¡ souboru

         mov       dx,offset All
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         mov       bx,ax                    ; identifik tor souboru
         jnc       Start1

; ------ chyba - soubor nenalezen

Start0:  mov       dx,offset FndTxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; ------ na‡ten¡ souboru do bufferu

Start1:  mov       cx,BUFFSIZE
         mov       dx,offset Buffer
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru
         jc        Start0                   ; chyba
         mov       ds:[SamSize],ax          ; velikost vzorku

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ inicializace port–

         call      InitPort                 ; inicializace port–

; ------ ‡ek n¡ na p©ehr t¡ cel‚ho vzorku

Start8:  sti
         cmp       word ptr ds:[SamSize],0  ; je ji‘ cel˜ vzorek ?
         jne       Start8                   ; ‡ek n¡ na p©ehr t¡ vzorku

; ------ n vrat nastaven¡ port–

         call      DeInit                   ; n vrat nastaven¡ port–

; ------ konec programu

         mov       ax,4c00h
         int       21h


; *****************************************************************************
;                              Int08
;                 obsluha p©eru¨en¡ hodin INT 08h
; *****************************************************************************

Int08    PROC      FAR

; ------ £schova registr–

Int080:  push      ax

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡ (odteƒ m–‘e nastat znovu p©eru¨en¡ INT 08h)

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         sti                                ; mo‘n‚ opˆtovn‚ p©eru¨en¡

; ------ £schova registr–

         push      bx
         push      cx
         push      dx
         push      si
         push      ds

         push      cs
         pop       ds

; ------ test, zda je ji‘ konec vzorku

         cli
         cmp       word ptr ds:[SamSize],0  ; je ji‘ cel˜ vzorek ?
         je        Int089                   ; je ji‘ cel˜ vzorek
         dec       word ptr ds:[SamSize]    ; sn¡‘en¡ ‡¡ta‡e vzorku
         sti

; ------ ‡ten¡ vzorku

         mov       si,ds:[SamUkaz]          ; ukazatel vzorku
         cld
         lodsb                              ; na‡ten¡ bajtu vzorku
         xor       byte ptr ds:[Citac0],1
         jnz       Int083

         cbw
         xchg      dx,ax

         mov       ds:[SamUkaz],si          ; nov  adresa vzorku
         lodsb
         cbw

         add       ax,dx
         sar       ax,1

; ------ vysl n¡ sign lu na port LPT

Int083:  sub       al,80h                   ; posun na nulu
ADRLPT1: mov       dx,378h                  ; adresa portu LPT 1
         out       dx,al                    ; vysl n¡ sign lu na port LPT 1
ADRLPT2: mov       dx,278h                  ; adresa portu LPT 2
         out       dx,al                    ; vysl n¡ sign lu na port LPT 2

; ------ vysl n¡ sign lu na reproduktor

         add       al,80h
         mov       bx,offset TabLog         ; tabulka pro logaritmizaci sign lu
         xlat                               ; konverze podle tabulky
         shl       al,1
         out       [42h],al                 ; vysl n¡ sign lu na reproduktor

; ------ n vrat registr–

Int089:  pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int08    ENDP

; *****************************************************************************
;                               Int09
;                 obsluha p©eru¨en¡ kl vesnice INT 09h
; *****************************************************************************

Int09    PROC      FAR

; ------ £schova registr–

         push      ax

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         sti

; ------ uzam‡en¡ kl vesnice

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzam‡en¡ kl vesnice

; ------ ‡ten¡ k¢du kl vesy

         call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         in        al,[60h]

; ------ p©eru¨en¡ programu ESC

         cmp       al,1                     ; ESC
         jne       Int099
         mov       word ptr ds:[SamSize],0 ; p©¡znak p©eru¨en¡ kl vesnic¡

; ------ uvolnˆn¡ kl vesnice

Int099:  call      Cekej09                  ; ‡ek n¡ na p©ipravenost kl vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnˆn¡ kl vesnice

; ------ n vrat registr–

         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost kl vesnice
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         push      ax
         push      cx
         cli
         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,bit1
         loopnz    Cekej091
         pop       cx
         pop       ax
         ret

Cekej09  ENDP

; *****************************************************************************
;                             InitPort
;               inicializace port–, start hry melodie
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

InitPort PROC      NEAR

; ------ vypnut¡ motor– disketov˜ch mechanik

         mov       dx,3f2h
         mov       al,0ch
         out       dx,al                    ; vypnut¡ motor– mechanik
         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[43fh],not bit0+bit1+bit2+bit3+bit4+bit5 ; motory
         pop       ds

; ------ £schova vektoru INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es ; £schova adresy INT 08h

; ------ £schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es ; £schova adresy INT 09h

; ------ £schova registru masky p©eru¨en¡

         in        al,[21h]                 ; registr masky p©eru¨en¡
         mov       ds:[OldMask],al          ; £schova masky p©eru¨en¡

; ------ p©echodn˜ z kaz v¨ech p©eru¨en¡

         cli                                ; z kaz p©eru¨en¡
         mov       al,0ffh
         out       [21h],al                 ; z kaz v¨ech p©eru¨en¡

; ------ instalace INT 08h

         mov       dx,offset Int08          ; obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; instalace obsluhy INT 08h

; ------ instalace INT 09h

         mov       dx,offset Int09          ; obsluha INT 09h
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

; ------ inicializace hodin INT 08h

         mov       al,34h
         out       [43h],al                 ; povel pro nastaven¡ hodin
         mov       al,ds:[Konst08]          ; dˆlic¡ konstanta pro hodiny
         out       [40h],al                 ; dˆlic¡ konstanta pro hodiny
         mov       al,0
         out       [40h],al                 ; vy¨¨¡ bajt dˆlic¡ konstanty

; ------ inicializace v˜stupu na reproduktor

         mov       al,90h
         out       [43h],al                 ; povel pro reproduktor - impulsy
         in        al,[61h]
         or        al,3                     ; zapnut¡ v˜stupu na reproduktor
         out       [61h],al

; ------ uvolnˆn¡ p©eru¨en¡ od kl vesnice a hodin

         mov       al,0fch
         out       [21h],al                 ; uvolnˆn¡ p©eru¨en¡
         sti                                ; povolen¡ p©eru¨en¡
         ret

InitPort ENDP

; *****************************************************************************
;                                DeInit
;                     odinstalov n¡ port– po h©e
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; *****************************************************************************

DeInit   PROC      NEAR

; ------ p©echodn˜ z kaz v¨ech p©eru¨en¡

         mov       al,0ffh
         out       [21h],al                 ; z kaz v¨ech p©eru¨en¡
         cli                                ; z kaz p©eru¨en¡

; ------ vypnut¡ v˜stupu na reproduktor

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut¡ v˜stupu na reproduktor

; ------ standardn¡ nastaven¡ hodin

         mov       al,34h
         out       [43h],al                 ; povel
         mov       al,0
         out       [40h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [40h],al                 ; konstanta - vy¨¨¡ bajt

; ------ standardn¡ nastaven¡ ‡¡ta‡e reproduktoru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n¡‘¨¡ bajt
         out       [42h],al                 ; konstanta - vy¨¨¡ bajt

; ------ n vrat adresy INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; p–vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h
         pop       ds

; ------ n vrat adresy INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h
         pop       ds

; ------ n vrat registru p©eru¨en¡

         mov       al,ds:[OldMask]          ; p–vodn¡ registr masky p©eru¨en¡
         out       [21h],al                 ; n vrat registru masky p©eru¨en¡
         sti                                ; povolen¡ p©eru¨en¡

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

; *****************************************************************************
;                                 DekParm
;                   Dek¢dov n¡ parametr– z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------
; VSTUP: DS,ES=adresa PSP
; *****************************************************************************

DekParm  PROC      NEAR

         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       es
         mov       si,81h
         mov       cl,ds:[si-1]             ; d‚lka parametr–
         mov       ch,0
         cld

; ------ nalezen¡ za‡ tku textu v bufferu

DekParm1:jcxz      DekParm9
         lodsb
         dec       cx
         cmp       al," "
         je        DekParm1
         cmp       al,9
         je        DekParm1
         cmp       al,13
         je        DekParm9

; ------ p©enesen¡ textu do bufferu

         mov       di,offset All
DekParm2:stosb
         jcxz      DekParm3
         lodsb
         dec       cx
         cmp       al," "
         je        DekParm3
         cmp       al,9
         je        DekParm3
         cmp       al,13
         jne       DekParm2

; ------ ozna‡en¡ konce jm‚na souboru

DekParm3:mov       al,0
         stosb

DekParm9:pop       es
         pop       ds
         ret

DekParm  ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

; ------ tabulka pro logaritmizaci v˜stupu na reproduktor

TabLog   label     near
db       32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17
db       17,16,16,15,15,14,14,13,13,13,12,12,12,12,11,11
db       11,11,10,10,10,10,10,9,9,9,9,9,9,9,9,9
db       8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7
db       7,7,7,6,6,6,6,6,6,6,6,6,6,6,5,5
db       5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4
db       4,4,3,3,3,3,3,3,3,3,3,3,2,2,2,2
db       2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1
db       64,64,64,64,64,64,64,64,64,64,63,63,63,63,63,63
db       63,63,63,63,63,63,62,62,62,62,62,62,62,62,62,62
db       61,61,61,61,61,61,61,61,61,60,60,60,60,60,60,60
db       60,60,60,59,59,59,59,59,59,59,59,59,59,58,58,58
db       58,58,58,58,58,58,58,57,57,57,57,57,57,57,57,57
db       57,56,56,56,56,56,56,56,56,55,55,55,55,55,54,54
db       54,54,53,53,53,53,52,52,52,51,51,50,50,49,49,48
db       48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33

SegPSP   dw        0                        ; segment PSP

FndTxt   db        'PLAYSAM V1.0 - prehravac vzorku SAMPLE; (c) Miroslav Nemecek',13,10
         db        'Nenalezen soubor se vzorkem !',13,10,'$'

SamUkaz  dw        offset Buffer            ; ukazatel vzorku
SamSize  dw        0                        ; velikost vzorku (bajt–)

Citac0   db        0                        ; ‡¡ta‡ p©¡rustku

Konst08  db        72                       ; dˆlic¡ konstanta hodin INT 08h

All      db        'SAMPLE.SAM',0           ; specifikace souboru
         db        128 dup(?)

Old09    dd        ?                        ; p–vodn¡ obsluha INT 09h
Old08    dd        ?                        ; p–vodn¡ obsluha INT 08h
OldMask  db        ?                        ; p–vodn¡ maska p©eru¨en¡

Buffer   db        BUFFSIZE dup(?)

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasobnik SEGMENT   STACK

         dw        4000h dup(?)

Zasobnik ENDS

         END       Start





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

; -----------------------------------------------------------------------------
;                        v�stupn� konektor LPT
; -----------------------------------------------------------------------------
; po��ta� CANON25                             tisk�rna CANON25
;  pin 1  )���������o��������������������������������( pin 1     STROBE
;                   �
;  pin 15 )������Ŀ �             (p�eru�it) X�������( pin 15    ERROR
;                 � �
;  pin 18 )�����o��������o���������������������������( pin 18    GND
;               � � �    �
;  pin 16 )����������������������o�������������������( pin 16    INIT
;               � � � R1 � R2    � R3
;               � ����  ���     ���
;               � �� �  � � 2K2 � � 68K
;               � ����  ���     ���
;               � � �5K6 �       �
;               � � �    �       �          SHARP MZ800 - NF konektor
;               � � �����o����������������������>����(         READ
;               � �              �     C1
;               � �              �     68n
;               � ���������������o����Ĵ �������<����(         WRITE
;               �           R4  ���
;               �               � � 22K
;               �               ���
;               �����������������o�������������������(         zem (st�n�n�)
; Odpory R3 a R4 je vhodn� ze za��tku nahradit odporov�m trimrem 100K a nastavit
; st�edn� polohu sign�lu p�i p�enosu do po��ta�e (testovac�m programem)
; -----------------------------------------------------------------------------

code     segment
         assume    cs:code,ds:code
         org       100h

; ------ zmen�en� sou�asn�ho konce bloku programu

start:   mov       bx,offset(Konec-Start+10fh)/16 ; velikost programu v odstav.
         mov       ah,4ah
         int       21h                      ; zmen�en� bloku pam�ti
         mov       dx,offset MemTxt
         jc        Chyba2                   ; nedostatek pam�ti

; ------ inicializace z�sobn�ku

         mov       sp,offset Zasob

; ------ vytvo�en� datov�ho bloku

         mov       bx,1000h                 ; velikost datov�ho bloku
         mov       ah,48h
         int       21h                      ; vytvo�en� datov�ho bloku
         jc        Chyba2                   ; nedostatek pam�ti
         mov       ds:[DatSegm],ax          ; adresa datov�ho bloku

; ------ za��tek jm�na souboru

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld
Start1:  jcxz      chyba
         mov       dx,si
         lodsb
         dec       cx
         cmp       al," "
         je        Start1
         cmp       al,9
         je        Start1
         cmp       al,13
         jne       Start2

; ------ chyba - nen� nic zad�no

Chyba:   mov       dx,offset HlpTxt
Chyba2:  mov       ah,9
         int       21h
         int       20h

; ------ ozna�en� konce jm�na souboru

Start2:  jcxz      Start3
         lodsb
         dec       cx
         cmp       al," "
         ja        Start2
         dec       si
Start3:  mov       byte ptr ds:[si],0

; ------ otev�en� souboru

         mov       ax,3d00h
         int       21h                      ; otev�en� souboru pro �ten�
         jc        Chyba                    ; chybn� zad�n� souboru
         mov       bx,ax                    ; identifik�tor souboru

; ------ na�ten� hlavi�ky souboru

         mov       cx,offset(HlavaEnd-Hlava) ; d�lka hlavi�ky
         mov       dx,offset Hlava          ; za��tek hlavi�ky
         mov       ah,3fh
         int       21h                      ; na�ten� hlavi�ky souboru

; ------ na�ten� souboru do pam�ti

         push      ds
         mov       ds,ds:[DatSegm]          ; datov� segment
         mov       cx,0ffffh                ; velikost dat
         xor       dx,dx                    ; adresa k na�ten� dat
         mov       ah,3fh
         int       21h                      ; na�ten� 1. ��sti souboru do pam�ti
         pop       ds
         mov       ds:[DatNum],ax           ; po�et bajt�

; ------ uzav�en� souboru

         pushf
         mov       ah,3eh
         int       21h                      ; uzav�en� souboru
         popf
         jc        Chyba                    ; chyba �ten�

; ------ hl��en� o vys�l�n� souboru

         mov       dx,offset TextVys
         mov       ah,9
         int       21h

; ------ zobrazen� jm�na souboru

         mov       cx,17                    ; max. d�lka textu
         mov       si,offset HlavaNam
Start6:  mov       dl,ds:[si]
         inc       si
         cmp       dl,13
         je        Start62
         mov       ah,2
         int       21h
         loop      Start6
Start62:

; ------ vysl�n� hlavi�ky souboru

         mov       di,8000                  ; d�lka �vodn�ho t�nu
         mov       bh,40                    ; d�lka synchronizace 1
         mov       bl,40                    ; d�lka synchronizace 2
         mov       cx,offset(HlavaEnd-Hlava) ; d�lka hlavi�ky
         push      ds
         pop       es                       ; segment adresy hlavi�ky
         mov       si,offset Hlava          ; hlavi�ka
         call      SaveHD                   ; vysl�n� hkavi�ky
         jc        StartX                   ; p�eru�en� programu

; ------ vysl�n� dat souboru

         shr       bh,1                     ; synchronizace 1
         shr       bl,1                     ; synchronizace 2
         mov       cx,ds:[HlavaDel]         ; d�lka souboru
         xor       si,si                    ; po��te�n� adresa
         mov       es,ds:[DatSegm]          ; datov� segment
         call      SaveHD                   ; vysl�n� dat souboru

; ------ konec programu

StartX:
         mov       dx,offset CRTxt
         mov       ah,9
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        vysl�n� hlavi�ky nebo dat
; -----------------------------------------------------------------------------
; VSTUP: BH=d�lka synchronizace 1
;        BL=d�lka synchronizace 2
;        CX=d�lka bloku dat
;        DI=d�lka �vodn�ho t�nu
;        ES:SI=po��te�n� adresa dat
;        DS=datov� segment
; V�STUP:CY=p�eru�en� programu
; -----------------------------------------------------------------------------

SaveHD   PROC      NEAR

; ------ �schova registr�

         push      ax
         push      dx
         call      InitPort                 ; instalace a inicializace port�

; ------ kontroln� sou�et dat (do registru DX)

         call      KontrS                   ; kontroln� sou�et hlavi�ky souboru

; ------ vysl�n� �vodu p�ed z�pisem

         call      SaveUvod                 ; vysl�n� �vodn�ho t�nu a synchron.
         jc        SaveHD9                  ; p�eru�en� programu

; ------ vysl�n� obsahu dat

         call      SavBlok                  ; vysl�n� obsahu dat
         jc        SaveHD9                  ; p�eru�en� programu

; ------ vysl�n� kontroln�ho sou�tu

         mov       al,dh                    ; vy��� bajt kontroln�ho sou�tu
         call      SavByte                  ; vysl�n� vy���ho bajtu kontr.sou�tu
         mov       al,dl                    ; ni��� bajt kontroln�ho sou�tu
         call      SavByte                  ; vysl�n� ni���ho bajtu kontr.sou�tu

; ------ vysl�n� STOP bitu "1"

         stc                                ; p��znak bitu "1"
         call      SavBit                   ; vysl�n� stop bitu "1"

; ------ n�vrat registr�

SaveHD9: pushf
         call      DeInit                   ; n�vrat port� a p�eru�en�
         popf
         pop       dx
         pop       ax
         ret

SaveHD   ENDP

; -----------------------------------------------------------------------------
;        kontroln� sou�et bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bloku dat
;        CX=po�et bajt� dat
;        DS=datov� segment
; V�STUP:DX=kontroln� sou�et dat
; -----------------------------------------------------------------------------

KontrS   PROC      NEAR

; ------ �schova registr�

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou n�jak� data

         xor       dx,dx                    ; st�ada� kontroln�ho sou�tu
         jcxz      KontrS9                  ; nejsou ��dn� data

; ------ p�i�ten� jednoho bajtu dat

KontrS1: mov       al,es:[si]               ; datov� bajt k p�i�ten�
         inc       si                       ; zv��en� ukazatele dat
         mov       ah,8                     ; po�et bit� bajtu
KontrS2: shl       al,1                     ; jeden bit k p�i�ten�
         adc       dx,0                     ; p�i�ten� bitu ke st�ada�i
         dec       ah                       ; ��ta� bit�
         jnz       KontrS2                  ; p�i�ten� dal��ho bitu bajtu
         loop      KontrS1                  ; p�i�ten� dal��ho bajtu

; ------ n�vrat registr�

KontrS9: pop       si
         pop       cx
         pop       ax
         ret

KontrS   ENDP

; -----------------------------------------------------------------------------
;        vysl�n� �vodu dat
; -----------------------------------------------------------------------------
; VSTUP: DI=po�et bit� �vodn�ho t�nu ("0") (22000=hlavi�ka, 11000=data)
;        BH=po�et bit� synchronizace 1 ("1") (40=hlavi�ka, 20=data)
;        BL=po�et bit� synchronizace 2 ("0") (40=hlavi�ka, 20=data)
;        DS=datov� segment
; V�STUP:CY=p�eru�en� programu
; -----------------------------------------------------------------------------

SaveUvod PROC      NEAR

; ------ �schova registr�

         push      ax
         push      bx
         push      di

; ------ vysl�n� �vodn�ho t�nu

         or        di,di
         jz        SaveUv11                 ; nen� ��dn� bit
SaveUv1: clc                                ; vy�le se bit 0
         call      SavBit                   ; vysl�n� bitu 0
         jc        SaveUv9                  ; p�eru�en� programu
         dec       di                       ; ��ta� bit� �vodn�ho t�nu
         jnz       SaveUv1                  ; vysl�n� dal��ho bitu

; ------ vysl�n� synchronizace 1

SaveUv11:cmp       bh,0                     ; jsou n�jak� bity ?
         je        SaveUv22                 ; nejsou ��dn� bity
SaveUv2: stc                                ; vy�le se bit 1
         call      SavBit                   ; vysl�n� bitu 1
         dec       bh                       ; po�et bit� synchronizace
         jnz       SaveUv2                  ; vysl�n� synchronizace 1

; ------ vysl�n� synchronizace 2

SaveUv22:cmp       bl,0                     ; jsou n�jak� bity ?
         je        SaveUv4                  ; nejsou ��dn� bity
SaveUv3: clc                                ; vy�le se bit 0
         call      SavBit                   ; vysl�n� bitu 0
         dec       bl                       ; po�et bit� synchronizace
         jnz       SaveUv3                  ; vysl�n� synchronizace 2

; ------ vysl�n� startovac�ho bitu

SaveUv4: stc                                ; vy�le se bit 1
         call      SavBit                   ; vysl�n� bitu 1

; ------ n�vrat registr�

SaveUv9: pop       di
         pop       bx
         pop       ax
         ret

SaveUvod ENDP

; -----------------------------------------------------------------------------
;        vysl�n� bloku dat
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa bloku dat
;        CX=po�et bajt� k vysl�n�
;        DS=datov� segment
; V�STUP:CY=p�eru�en� programu
; -----------------------------------------------------------------------------

SavBlok  PROC      NEAR

; ------ �schova registr�

         push      ax
         push      cx
         push      si

; ------ kontrola, zda jsou n�jak� data k vysl�n�

         clc
         jcxz      SavBlok9                 ; nejsou ��dn� data

; ------ vysl�n� bloku dat

         cld
SavBlok1:mov       al,es:[si]               ; bajt k vysl�n�
         inc       si                       ; zv��en� ukazatele
         call      SavByte                  ; vysl�n� jednoho bajtu dat
         jc        SavBlok9                 ; p�eru�en� programu
         loop      SavBlok1                 ; vysl�n� dal��ho bajtu

; ------ n�vrat registr�

SavBlok9:pop       si
         pop       cx
         pop       ax
         ret

SavBlok  ENDP

; -----------------------------------------------------------------------------
;        vysl�n� jednoho bajtu
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k vysl�n�
;        DS=datov� segment
; V�STUP:CY=p�eru�en�
; ni�� registr AX !
; -----------------------------------------------------------------------------

SavByte  PROC      NEAR

         stc                                ; start bit "1"
         call      SavBit                   ; vysl�n� startovac�ho bitu "1"
         shl       al,1
         call      SavBit                   ; bit 7
         shl       al,1
         call      SavBit                   ; bit 6
         shl       al,1
         call      SavBit                   ; bit 5
         shl       al,1
         call      SavBit                   ; bit 4
         shl       al,1
         call      SavBit                   ; bit 3
         shl       al,1
         call      SavBit                   ; bit 2
         shl       al,1
         call      SavBit                   ; bit 1
         shl       al,1
         call      SavBit                   ; bit 0
         ret

SavByte  ENDP

; -----------------------------------------------------------------------------
;        vysl�n� jednoho bitu
; -----------------------------------------------------------------------------
; VSTUP: CY=bit je 1 (NC=bit je 0)
;        DS=datov� segment
; V�STUP:CY=p�eru�en�
; ni�� registr AH !
; -----------------------------------------------------------------------------

SavBit   PROC      NEAR

; ------ stanoven� d�lky impulsu

         mov       ah,ds:[DelImp]           ; d�lka impulsu "0"
         jnc       SavBit1                  ; je bit 0
         shl       ah,1                     ; jinak impuls "1"

; ------ vysl�n� dvou impuls�

SavBit1: call      SavImp                   ; vysl�n� impulsu "+"
         call      SavImp                   ; vysl�n� impulsu "-"
         ret

SavBit   ENDP

; -----------------------------------------------------------------------------
;        zah�jen� vys�l�n� jednoho impulsu
; -----------------------------------------------------------------------------
; VSTUP: AH=d�lka impulsu
;        DS=datov� segment
; V�STUP:CY=p�eru�en� programu
; -----------------------------------------------------------------------------

SavImp   PROC      NEAR

; ------ test, zda je p�eru�en� porgramu

         sti                                ; p�eru�en� mus� b�t povoleno
SavImp1: test      byte ptr ds:[Param],bit0 ; je p�eru�en� programu ?
         stc                                ; p��znak p�eru�en�
         jnz       SavImp9                  ; je p�eru�en� programu

; ------ �ek�n� na ukon�en� jednoho impulsu

         cmp       byte ptr ds:[CitImp],0   ; je ji� cel� impuls ?
         jne       SavImp1                  ; �ek�n� na ukon�en� impulsu

; ------ za��tek nov�ho impulsu

         mov       ds:[CitImp],ah           ; d�lka nov�ho impulsu
                                            ; zde je p��znak NC
SavImp9: ret

SavImp   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ �schova registr�

         push      ax

; ------ ��t�n� zm�ny v�stupu

         mov       al,cs:[CitImp]           ; ��ta� impuls�
         cmp       al,0                     ; ��t� se impuls ?
         je        Int089                   ; ne��t� se impuls
         dec       al                       ; sn��en� ��ta�e
         mov       cs:[CitImp],al           ; nov� stav ��ta�e
         jnz       Int089                   ; nen� dosa�eno 0

; ------ zm�na portu LPT

         push      dx
         mov       al,cs:[OutPort]          ; v�stup na port LPT
         xor       al,bit0                  ; zm�na sign�lu STROBE
         mov       cs:[OutPort],al          ; �schova nov� hodnoty
PortLPT: mov       dx,37ah                  ; v�stupn� port
         out       dx,al                    ; v�stup bajtu LPT
         pop       dx

;; ------ zm�na portu 61h
;
;         in        al,[61h]
;         xor       al,2                     ; zm�na stavu v�stupu
;         out       [61h],al

; ------ uvoln�n� �adi�e p�eru�en�

Int089:  mov       al,20h
         out       [20h],al                 ; uvoln�n� �adi�e p�eru�en�

; ------ n�vrat registr�

         pop       ax
         iret

INT08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

; ------ �schova registr�

         push      ax
         push      cx

; ------ uvoln�n� �adi�e p�eru�en�

         mov       al,20h
         out       [20h],al                 ; uvoln�n� �adi�e p�eru�en�
         sti

; ------ uzam�en� kl�vesnice

         call      Cekej09                  ; �ek�n� na p�ipravenost kl�vesnice
         mov       al,0adh
         out       [64h],al                 ; vysl�n� povelu-uzam�en� kl�vesnice

; ------ �ten� k�du kl�vesy

         call      Cekej09                  ; �ek�n� na p�ipravenost kl�vesnice
         in        al,[60h]

; ------ p�eru�en� programu

         cmp       al,1
         jne       Int095
         or        byte ptr cs:[Param],bit0 ; p��znak p�eru�en� programu ESC

; ------ uvoln�n� kl�vesnice

Int095:  call      Cekej09                  ; �ek�n� na p�ipravenost kl�vesnice
         mov       al,0aeh
         out       [64h],al                 ; vysl�n� povelu-uvoln�n� kl�vesnice

; ------ n�vrat registr�

         pop       cx
         pop       ax
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        �ek�n� na p�ipravenost kl�vesnice (ni�� registry CX a AL !)
; -----------------------------------------------------------------------------

Cekej09  PROC      NEAR

         cli
         mov       cx,5000
Cekej091:in        al,[64h]
         test      al,bit1
         loopnz    Cekej091
         ret

Cekej09  ENDP

; *****************************************************************************
;                             InitPort
;               inicializace port�, start hry melodie
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; *****************************************************************************

InitPort PROC      NEAR

; ------ �schova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ vypnut� motor� disketov�ch mechanik

         mov       dx,3f2h
         mov       al,0ch
         out       dx,al                    ; vypnut� motor� mechanik
         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[43fh],not bit0+bit1+bit2+bit3+bit4+bit5 ; motory

; ------ inicializace adres port�

         mov       ax,ds:[408h]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,ds:[40ah]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,ds:[40ch]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,ds:[40eh]
         or        ax,ax
         jnz       InitPrt1
         mov       ax,378h
InitPrt1:inc       ax
         inc       ax
         mov       word ptr cs:[PortLPT+1],ax    ; adresa portu LPT
         pop       ds
         mov       byte ptr ds:[OutPort],00000101b ; v�stupn� slovo na port

; ------ �schova vektoru INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut� adresy INT 08h
         mov       word ptr ds:[Old08],bx
         mov       word ptr ds:[Old08+2],es ; �schova adresy INT 08h

; ------ �schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut� adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es ; �schova adresy INT 09h

; ------ �schova registru masky p�eru�en�

         in        al,[21h]                 ; registr masky p�eru�en�
         mov       ds:[OldMask],al          ; �schova masky p�eru�en�

; ------ p�echodn� z�kaz v�ech p�eru�en�

         cli                                ; z�kaz p�eru�en�
         mov       al,0ffh
         out       [21h],al                 ; z�kaz v�ech p�eru�en�

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
         out       [43h],al                 ; povel pro nastaven� hodin
         mov       al,ds:[Konst08]          ; d�lic� konstanta pro hodiny
         out       [40h],al                 ; d�lic� konstanta pro hodiny
         mov       al,0
         out       [40h],al                 ; vy��� bajt d�lic� konstanty

; ------ zapnut� v�stupu na reproduktor

         in        al,[61h]
         and       al,not 1                 ; ��ta� vypnut
         or        al,2                     ; v�stup zapnut
         out       [61h],al

; ------ uvoln�n� p�eru�en� od kl�vesnice a hodin

         mov       al,0fch
         out       [21h],al                 ; uvoln�n� p�eru�en�
         sti                                ; povolen� p�eru�en�

; ------ n�vrat registr�

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitPort ENDP

; *****************************************************************************
;                                DeInit
;                     odinstalov�n� port� po h�e
; -----------------------------------------------------------------------------
; VSTUP: DS=datov� segment
; *****************************************************************************

DeInit   PROC      NEAR

; ------ �schova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      es

; ------ p�echodn� z�kaz v�ech p�eru�en�

         mov       al,0ffh
         out       [21h],al                 ; z�kaz v�ech p�eru�en�
         cli                                ; z�kaz p�eru�en�

; ------ vypnut� v�stupu na reproduktor

         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut� v�stupu na reproduktor

; ------ standardn� nastaven� hodin

         mov       al,34h
         out       [43h],al                 ; povel
         mov       al,0
         out       [40h],al                 ; konstanta - n���� bajt
         out       [40h],al                 ; konstanta - vy��� bajt

; ------ standardn� nastaven� ��ta�e reproduktoru

         mov       al,0b6h                  ; povel
         out       [43h],al
         mov       al,5                     ; konstanta asi tak 920 Hz
         out       [42h],al                 ; konstanta - n���� bajt
         out       [42h],al                 ; konstanta - vy��� bajt

; ------ n�vrat adresy INT 08h

         push      ds
         lds       dx,ds:[Old08]            ; p�vodn� adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n�vrat adresy INT 08h
         pop       ds

; ------ n�vrat adresy INT 09h

         push      ds
         lds       dx,ds:[Old09]            ; p�vodn� adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n�vrat adresy INT 09h
         pop       ds

; ------ n�vrat registru p�eru�en�

         mov       al,ds:[OldMask]          ; p�vodn� registr masky p�eru�en�
         out       [21h],al                 ; n�vrat registru masky p�eru�en�
         sti                                ; povolen� p�eru�en�

; ------ �ten� hodin syst�mov�ho �asu (AT)

         mov       dl,8ah                   ; p�ednastaven� na nesmysl
         mov       ah,2
         int       1ah                      ; �ten� hodin
         cmp       dl,1                     ; p�ete�en� p�es p�lnoc ?
         ja        Deinit3                  ; hodiny neplat�

; ------ n�vrat p��znaku p�ete�en� p�es p�lnoc

         jne       DeInit2                  ; nen� p�ete�en� p�es p�lnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n�vrat p��znaku p�ete�en� p�lnoci

; ------ konverze z BCD form�tu na bin�rn�

DeInit2: mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin�rn� tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin�rn� tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin�rn� tvar
         mov       dh,al

; ------ nastaven� �asu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven� syst�mov�ho �asu

DeInit3:

; ------ n�vrat registr�

         pop       es
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DeInit   ENDP

; -----------------------------------------------------------------------------
;        Konverze ��sla z BCD tvaru na bin�rn�
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

MemTxt   db        'Nedostatek pameti !',13,10,'$'
hlptxt   db        'Zadejte platne jmeno souboru k vyslani !'
CRTxt    db        13,10,'$'

TextVys  db        'Vysilam $'

Param    db        0                        ; parametry
                                            ;  bit 0: 1=p�eru�en� ESC

CitImp   db        0                        ; ��ta� impuls� ke zm�n� sign�lu

SegmVRAM dw        0b000h                   ; segment videopam�ti

Konst08  db        77;72                       ; d�lic� konstanta hodin
                                            ;     (16.57 kHz / 60.34 us)
                                            ;      hodiny 1 193 182 Hz
DelImp   db        2                        ; z�kladn� d�lka impulsu

; ------ tabulka mal�ch p�smen

TabCh    label     byte
         db        0a1h                     ; a
         db        9ah                      ; b
         db        9fh                      ; c
         db        9ch                      ; d
         db        92h                      ; e
         db        0aah                     ; f
         db        97h                      ; g
         db        98h                      ; h
         db        0a6h                     ; i
         db        0afh                     ; j
         db        0a9h                     ; k



; ------ z�hlav� souboru (80h bajt�)

Hlava    label     byte
HlavaTyp db        1                        ; typ souboru (1=stroj., 5=BASIC)
HlavaNam db        17 dup(" ")              ; jm�no souboru
HlavaDel dw        0                        ; d�lka souboru
HlavaBeg dw        1200h                    ; po��te�n� adresa souboru
HlavaExe dw        1200h                    ; startovac� adresa programu
HlavaCom db        80h - 24 dup(0)          ; pozn�mka souboru
HlavaEnd label     byte

Old08    dd        ?                        ; p�vodn� adresa INT 08h
Old09    dd        ?                        ; p�vodn� adresa INT 09h
OldMask  db        ?                        ; p�vodn� maska p�eru�en�

DatSegm  dw        ?                        ; adresa datov�ho bloku
DatNum   dw        ?                        ; po�et bajt� v bufferu

OutPort  db        ?                        ; v�stup na port LPT

         dw        200h dup(?)              ; z�sobn�k
zasob    label     byte                     ; konec z�sobn�ku

konec    label     byte                     ; konec programu

code     ends
         end       start

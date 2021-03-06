
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;
;                            Synchronizace 놹su po눀ta뇲
;
; -----------------------------------------------------------------------------
; Protokol:
;
; Vys죐a� vys죐� data ka멶� 2 impulsy hodin (tj. ka멶쁟h 110 ms). Data se
; p쯥n젴� rychlost� 1200 Baud, 8 bit� bez parity, 1 stop bit
;
;      (1) synchroniza뇆� bajt (odd늢ova� zpr쟶y) ...... 92        + 32 ("|")
;      (1) rok - 1980 (tj. offset od roku 1980) ........ (0 a� 90) + 32
;      (1) m늮죅 ....................................... (1 a� 12) + 32
;      (1) den ......................................... (1 a� 31) + 32
;      (1) hodina ...................................... (0 a� 23) + 32
;      (1) minuta ...................................... (0 a� 59) + 32
;      (1) sekunda ..................................... (0 a� 59) + 32
;      (1) setina sekundy/2 ............................ (0 a� 49) + 32
;      (1) kontroln� sou놽t dat (bez "+ 32") MOD 64 .... (0 a� 63) + 32
;
; Ke v쮍m bajt뻧 se p쯫눀t� hodnota 32, data se p쯥n젴� jako b닊n� znaky ASCII.
;
; P쯥n젴en� 즔aj o 놹su je platn� okam멼kem vys죐쟮� synchroniza뇆죋o bajtu.
; P쯫j죑a� proto 즔aj po p쯫jet� zkoriguje podle p쯥n젴en� doby zpr쟶y
; (tedy p쯫뇍e zhruba 1 sekundu k 즔aji).
;
; Operace aktualizace 놹su se prov쟡� zhruba ka멶쁟h 15 a� 30 sekund.
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

;DEBUG    EQU       1                        ; pæznak lad죅죋o re멼mu

SYNCH    EQU       92                       ; synchroniza뇆� bajt bez "+32"

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

HI       EQU       256

KORIG    EQU       5ch - 103h               ; korekce pro posun adres

KLICFN   EQU       2bh*HI + "?"             ; kl죬 funkce a dotazu
KLIC1    EQU       'PC'                     ; identifika뇆� kl죬 1 (BX)
KLIC2    EQU       'TI'                     ; identifika뇆� kl죬 2 (CX)
KLIC3    EQU       'ME'                     ; identifika뇆� kl죬 3 (DX)
KLICOK   EQU       'OK'                     ; odpov늕n� kl죬 (AX)


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

RezBeg   label     byte                     ; za뇿tek rezidentn죋o modulu

Ident    db        'PT'                     ; identifikace v pam늯i

Old08    dd        0                        ; uschovan� adresa INT 08h
Old21    dd        0                        ; uschovan� adresa INT 21h
Old28    dd        0                        ; p뻱odn� adresa obsluhy INT 28h

Aktiv21  dd        0                        ; adresa pæznaku aktivity DOS
ErrDOS   dd        0                        ; adresa pæznaku obsluhy chyby DOS

InpPort  dw        0                        ; adresa vstupn죋o portu COM (0=nen�)
         db        "0"                      ; 눀slo vstupn죋o portu ASCII

OutPort  dw        0                        ; adresa v쁲tupn죋o portu COM (0=nen�)
         db        "0"                      ; 눀slo v쁲tupn죋o portu ASCII

HodinaL  db        -1                       ; hodina posledn� korekce 놹su
MinutaL  db        -1                       ; minuta posledn� korekce 놹su
SekundaL db        -1                       ; sekunda posledn� korekce 놹su

Param    db        0                        ; parametry
                                            ;   bit 0: 1=obsluha vys죐쟮�
                                            ;   bit 1: 1=bude SYNCHRO 컴�0=nen�
                                            ;   bit 2: 1=bude zpr쟶a    쿽bsluha
                                            ;   bit 3: 1=prob죋� zpr쟶a 쿎OM
                                            ;   bit 4: 1=bude CRC     컴�
                                            ;   bit 5: 1=bude DOS
                                            ;   bit 6: 1=lich� impuls vys죐쟮�

NextCit  db        0                        ; 눀ta� 1/18s pro pæ쮝� p쯥nos

Korekce  dw        0                        ; korekce p쯫 pæjmu

Ukaz     dw        offset Zprava+KORIG      ; ukazatel zpr쟶y

CRC      db        0                        ; st쯠da� CRC

Zprava   label     byte                     ; p쯥n젴en� zpr쟶a (data/min/max)
Rok      db        0,0,90                   ; rok - 1980
Mesic    db        0,1,12                   ; m늮죅
Den      db        0,1,31                   ; den
Hodina   db        0,0,23                   ; hodina
Minuta   db        0,0,59                   ; minuta
Sekunda  db        0,0,59                   ; sekunda
Zprava0  label     byte                     ; posledn� polo멾a
Setina   db        0,0,49                   ; setina sekundy/2 (tj. 1/50 sekundy)

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ 눀t쟮� korekce p쯫 pæjmu

         inc       word ptr cs:[Korekce+KORIG] ; 눀t쟮� korekce p쯫 pæjmu

; ------ test, zda m� b쁳 n늞ak� obsluha portem

         test      byte ptr cs:[Param+KORIG],bit1+bit2+bit3+bit4 ; bude COM ?
         jnz       Int081                   ; je n늞ak� obsluha COM

; ------ aktivace dalÆ operace

         inc       byte ptr cs:[NextCit+KORIG] ; 눀ta� aktivace operace
         jnz       Int080                   ; nebude dalÆ operace

         cmp       word ptr cs:[InpPort+KORIG],0 ; je vstupn� port ?
         je        Int0802                  ; nen� vstupn� port
         mov       byte ptr cs:[Param+KORIG],bit1 ; aktivace p쯫j죑a놽
         push      dx
         mov       dx,cs:[InpPort+KORIG]    ; adresa vstupn죋o portu
         jmp       short Int0801

Int0802: cmp       word ptr cs:[OutPort+KORIG],0 ; je v쁲tupn� port ?
         je        Int080                   ; nen� ani v쁲tupn� port
         mov       byte ptr cs:[Param+KORIG],bit0+bit5 ; aktivace vys죐a놽
         push      dx
         mov       dx,cs:[OutPort+KORIG]    ; adresa v쁲tupn죋o portu
Int0801: call      InitPort                 ; inicializace portu DX
         pop       dx

Int080:  jmp       dword ptr cs:[Old08+KORIG] ; p뻱odn� obsluha INT 08h

; ------ p뻱odn� obsluha INT 08h

Int081:  pushf
         call      dword ptr cs:[Old08+KORIG] ; p뻱odn� obsluha INT 08h

; ------ 즧chova registr�

         push      ax
         push      bx
         push      dx
         push      ds

         push      cs
         pop       ds                       ; DS <- datov� segment

         mov       ah,ds:[Param+KORIG]      ; parametry vys죐쟮�

; ------ test, zda je obsluha vys죐쟮�

         test      ah,bit0                  ; je vys죐쟮� ?
         jz        Int084                   ; nen� vys죐쟮� - je pæjem
         xor       ah,bit6                  ; pæznak lich괿o impulsu
         test      ah,bit6                  ; je lich� impuls ?
         jnz       Int0839                  ; je lich� impuls - p쯥sko눀 se

; ------ test, zda je vys죐ac� buffer pr쟺dn�

         mov       dx,ds:[OutPort+KORIG]    ; adresa vys죐ac죋o portu COM
         add       dx,5
         in        al,dx                    ; na뇍en� stavov괿o registru
         sub       dx,5
         test      al,bit5                  ; je vys죐ac� registr pr쟺dn� ?
         jz        Int0839                  ; vys죐ac� registr nen� pr쟺dn�

; ------ vysl쟮� SYNCHRO

         test      ah,bit1                  ; m� b쁳 SYNCHRO ?
         jz        Int0822                  ; nem� b쁳 SYNCHRO
         mov       word ptr ds:[Ukaz+KORIG],offset Zprava+KORIG ; ukazatel zpr쟶y
         mov       byte ptr ds:[CRC+KORIG],0 ; nulov쟮� st쯠da놽 CRC
         mov       ah,bit0+bit3             ; bude zpr쟶a
         mov       al,SYNCH                 ; synchroniza뇆� bajt
         jmp       short Int083             ; vysl쟮� bajtu

; ------ vys죐쟮� zpr쟶y

Int0822: test      ah,bit3                  ; je zpr쟶a ?
         jz        Int0823                  ; nen� zpr쟶a
         mov       bx,ds:[Ukaz+KORIG]       ; ukazatel zpr쟶y
         mov       al,ds:[bx]               ; znak k vysl쟮�
         add       byte ptr ds:[CRC+KORIG],al ; 눀t쟮� st쯠da놽 CRC
         add       word ptr ds:[Ukaz+KORIG],3 ; posun ukazatele zpr쟶y
         cmp       bx,offset Zprava0+KORIG  ; je to posledn� polo멾a ?
         jb        Int083                   ; nen� to posledn� polo멾a
         mov       ah,bit0+bit4             ; bude vysl쟮� CRC
         jmp       short Int083

; ------ vysl쟮� CRC

Int0823: mov       al,ds:[CRC+KORIG]        ; znak CRC k vysl쟮�
         and       al,bit0+bit1+bit2+bit3+bit4+bit5 ; je v modulu MOD 64
         mov       ah,0                     ; konec vys죐쟮�

; ------ vysl쟮� znaku AL

Int083:  add       al,32                    ; posun na ASCII znak
         out       dx,al                    ; vysl쟮� znaku AL
Int0839: jmp       Int089

; ------ test, zda je p쯫jat� znak

Int084:  mov       dx,ds:[InpPort+KORIG]    ; adresa p쯫j죑ac죋o portu COM
         add       dx,5                     ; stavov� registr linky
         in        al,dx                    ; na뇍en� stavov괿o registru
         sub       dx,5
         test      al,bit0                  ; je p쯫praven znak ?
         jz        Int089                   ; znak nen� p쯫praven

; ------ pæjem znaku, korekce znaku

         in        al,dx                    ; pæjem znaku
         sub       al,32                    ; korekce znaku
         cmp       al,SYNCH                 ; maxim쟫n� znak
         jbe       Int085                   ; znak vyhovuje OK

; ------ zah쟩en� nov괿o pæjmu (AL=znak)

Int0849: mov       ah,bit1                  ; pæznak 놽k쟮� na SYNCHRO

; ------ 놽k쟮� na SYNCHRO

Int085:  test      ah,bit1                  ; 놽k� se na SYNCHRO ?
         jz        Int0852                  ; ne놽k� se na SYNCHRO
         cmp       al,SYNCH                 ; je SYNCHRO ?
         jne       Int089                   ; nen� SYNCHRO
         mov       ah,bit2                  ; bude 놽k쟮� na zpr쟶u
Int0851: mov       word ptr ds:[Korekce+KORIG],4 ; nulov쟮� 눀ta놽 korekce
         jmp       short Int089

; ------ 놽k쟮� na zpr쟶u

Int0852: test      ah,bit2                  ; je 놽k쟮� na zpr쟶u ?
         jz        Int0854                  ; nen� 놽k쟮� na zpr쟶u
         cmp       al,SYNCH                 ; je synchronizace ?
         je        Int0851                  ; je synchronizace
         mov       ah,bit3                  ; pæznak, 멷 prob죋� zpr쟶a
         mov       word ptr ds:[Ukaz+KORIG],offset Zprava+KORIG ; ukazatel zpr쟶y
         mov       byte ptr ds:[CRC+KORIG],0 ; nulov쟮� st쯠da놽 CRC

; ------ pæjem zpr쟶y

Int0854: test      ah,bit3                  ; prob죋� zpr쟶a ?
         jz        Int0856                  ; nen� zpr쟶a
         mov       bx,ds:[Ukaz+KORIG]       ; ukazatel zpr쟶y
         cmp       al,ds:[bx+1]             ; kontrola minim쟫n� hodnoty
         jb        Int0849                  ; nespr쟶n� hodnota
         cmp       al,ds:[bx+2]             ; kontrola maxim쟫n� hodnoty
         ja        Int0849                  ; nespr쟶n� hodnota
         mov       ds:[bx],al               ; ulo멷n� znaku
         add       ds:[CRC+KORIG],al        ; p쯫뇍en� CRC
         add       word ptr ds:[Ukaz+KORIG],3 ; posun ukazatele

; ------ test, je-li konec pæjmu

         cmp       bx,offset Zprava0+KORIG  ; byla to posledn� polo멾a ?
         jb        Int089                   ; nen� to posledn� polo멾a
         mov       ah,bit4                  ; bude CRC
         jmp       short Int089

; ------ pæjem CRC

Int0856: cmp       al,64                    ; kontrola hodnoty CRC
         jae       Int0849                  ; nespr쟶n� hodnota CRC
         xor       ds:[CRC+KORIG],al        ; test CRC
         test      byte ptr ds:[CRC+KORIG],bit0+bit1+bit2+bit3+bit4+bit5 ; souhlas� CRC ?
         jnz       Int0849                  ; CRC nesouhlas�
         mov       ah,bit5                  ; bude nastaven� DOS

; ------ n쟶rat registr�

Int089:  mov       ds:[Param+KORIG],ah      ; nov� parametry

         pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 21h
; -----------------------------------------------------------------------------

Int21    PROC      FAR

; ------ test instalace

         pushf
         cmp       ax,KLICFN                ; funk뇆� kl죬
         jne       Int212
         cmp       bx,KLIC1                 ; identifika뇆� kl죬 1
         jne       Int212
         cmp       cx,KLIC2                 ; identifika뇆� kl죬 2
         jne       Int212
         cmp       dx,KLIC3                 ; identifika뇆� kl죬 3
         jne       Int212
         mov       ax,KLICOK                ; odpov늕n� kl죬
         push      cs
         pop       es                       ; ES <- segment programu
         popf
         iret

Int212:  popf

; ------ obsluha INT 21h

         call      IntDOS                   ; obsluha pæstupu k DOS
         jmp       dword ptr cs:[Old21+KORIG] ; pokra뇇v쟮� p뻱odn� obsluhou

Int21    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         call      IntDOS                   ; obsluha pæstupu k DOS
         jmp       dword ptr cs:[Old28+KORIG] ; pokra뇇v쟮� p뻱odn� obsluhou

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha pæstupu k DOS
; -----------------------------------------------------------------------------

IntDOS   PROC      NEAR

; ------ test, zda m� b쁳 obsluha 놹su DOS

         pushf
         test      byte ptr cs:[Param+KORIG],bit5 ; po멲davek obsluhy DOS ?
         jnz       IntDOS1                  ; je po멲davek obsluhy DOS
IntDOS0: jmp       IntDOS9                  ; nen� po멲dov쟮a obsluha DOS

; ------ test pæznaku aktivity DOS

IntDOS1: push      ds
         push      bx
         lds       bx,cs:[Aktiv21+KORIG]    ; adresa pæznaku aktivity DOS
         cmp       bx,-1                    ; je adresa definov쟮a ?
         je        IntDOS2                  ; nen� definov쟮a
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn� ?
IntDOS2: pop       bx
         pop       ds
         jne       IntDOS0                  ; DOS je aktivn�

; ------ test pæznaku obsluhy chyby DOS

         push      ds
         push      bx
         lds       bx,cs:[ErrDOS+KORIG]     ; adresa pæznaku obsluhy chyby DOS
         cmp       bx,-1                    ; je adresa definov쟮a ?
         je        IntDOS3                  ; nen� definov쟮a
         cmp       byte ptr ds:[bx],0       ; je chyba DOS aktivn� ?
IntDOS3: pop       bx
         pop       ds
         jne       IntDOS0                  ; obsluha chyby DOS je aktivn�

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds                       ; DS <- CS

; ------ test, zda je vys죐쟮�

         test      byte ptr ds:[Param+KORIG],bit0 ; je vys죐쟮� ?
         jz        IntDOS4                  ; nen� vys죐쟮�

; ------ na뇍en� data DOS

IntDOS32:mov       ah,2ah
         call      Int21P                   ; na뇍en� data DOS
         sub       cx,1980                  ; offset od roku 1980
         mov       ds:[Rok+KORIG],cl        ; offset od roku 1980
         mov       ds:[Mesic+KORIG],dh      ; m늮죅
         mov       ds:[Den+KORIG],dl        ; den

; ------ na뇍en� 놹su DOS

         mov       ah,2ch
         call      Int21P                   ; na뇍en� 놹su DOS
         mov       ds:[Hodina+KORIG],ch     ; hodina
         mov       ds:[Minuta+KORIG],cl     ; minuta
         mov       ds:[Sekunda+KORIG],dh    ; sekunda
         shr       dl,1                     ; setina / 2
         mov       ds:[Setina+KORIG],dl     ; setina sekundy
         mov       byte ptr ds:[Param+KORIG],bit0+bit1 ; vys죐쟮� SYNCHRO
         jmp       IntDOS8

; ------ korekce 놹su

IntDOS4: mov       ax,ds:[Korekce+KORIG]    ; korekce 놹su
         cmp       ax,30*18                 ; maxim쟫n� prodleva 30 sekund
         ja        IntDOS7                  ; to je ji� pæli� dlouho
         mov       cx,100
         mul       cx
         mov       cl,18
         div       cx                       ; p쯥po놽t na 1/100 sekund
                                          ;* zde je AX maxim쟫n� 3000
         shl       byte ptr ds:[Setina+KORIG],1 ; p쯥vod setin/2 na setiny
         add       al,ds:[Setina+KORIG]     ; p쯫뇍en� 1/100 sekund
         adc       ah,0
         mov       cl,100
         div       cl                       ; p쯥po놽t na sekundy a setiny
         mov       ds:[Setina+KORIG],ah     ; setina sekundy
         add       ds:[Sekunda+KORIG],al    ; korekce sekund
         cmp       byte ptr ds:[Sekunda+KORIG],60
         jb        IntDOS5
         sub       byte ptr ds:[Sekunda+KORIG],60
         inc       byte ptr ds:[Minuta+KORIG] ; korekce minut (p쯥te놽n� ignoruje)

; ------ nastaven� 놹su DOS

IntDOS5: mov       ch,ds:[Hodina+KORIG]     ; hodina
         mov       cl,ds:[Minuta+KORIG]     ; minuta
         mov       dh,ds:[Sekunda+KORIG]    ; sekunda
         mov       dl,ds:[Setina+KORIG]     ; setina sekundy
         mov       ah,2dh
         call      Int21P                   ; nastaven� syst굆ov괿o 놹su
         cmp       al,0                     ; byl 놹s OK ?
         jne       IntDOS6                  ; nebyl spr쟶n� 놹s
         mov       ds:[HodinaL+KORIG],ch    ; naposledy proveden� korekce
         mov       ds:[MinutaL+KORIG],cl    ; naposledy proveden� korekce
         mov       ds:[SekundaL+KORIG],dh   ; naposledy proveden� korekce

; ------ nastaven� data DOS

IntDOS6: mov       cl,ds:[Rok+KORIG]        ; rok - 1980
         mov       ch,0
         add       cx,1980                  ; oprava data
         mov       dh,ds:[Mesic+KORIG]      ; m늮죅
         mov       dl,ds:[Den+KORIG]        ; den
         mov       ah,2bh
         call      Int21P                   ; nastaven� syst굆ov괿o data

; ------ n쟳leduje vys죐쟮�

IntDOS7: mov       byte ptr ds:[Param+KORIG],0 ; konec pæjmu
         cmp       word ptr ds:[OutPort+KORIG],0 ; je v쁲tupn� port ?
         je        IntDOS8                  ; nen� v쁲tupn� port
         jmp       IntDOS32                 ; aktivace vys죐a놽

; ------ n쟶rat registr�

IntDOS8: pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
IntDOS9: popf
         ret

IntDOS   ENDP

; -----------------------------------------------------------------------------
;        vol쟮� funkce DOS (DS=CS !)
; -----------------------------------------------------------------------------

Int21P   PROC      NEAR

         pushf
         call      dword ptr ds:[Old21+KORIG]
         ret

Int21P   ENDP

; -----------------------------------------------------------------------------
;        inicializace portu DX
; -----------------------------------------------------------------------------

InitPort PROC      NEAR

         push      ax

         add       dx,3                     ; ædic� registr linky
         mov       al,80h
         out       dx,al                    ; zapnut� sign쟫u DLAB
         sub       dx,3                     ; registr d늢i뇃y

         mov       al,96
         out       dx,al                    ; ni뫅� bajt pro rychlost 1200 Baud
         inc       dx
         mov       al,0
         out       dx,al                    ; vyĿ� bajt pro rychlost 1200 Baud

         inc       dx
         inc       dx
         mov       al,00000011b             ; nen� parita, 1 STOP, 8 bit�
         out       dx,al                    ; nastaven� parametr� p쯥nosu

         pop       ax
         ret

InitPort ENDP


IFDEF    DEBUG

STOP     PROC      NEAR

         pushf
         push      ax
         push      es

         mov       ax,0b800h
         mov       es,ax
         inc       byte ptr es:[0]

         pop       es
         pop       ax
         popf
         ret

STOP     ENDP

ENDIF

RezEnd   label     byte                     ; konec rezidentn죋o modulu

; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------
;�
; ------ zobrazen� 즪odn죋o textu

Instal:  mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen� 즪odn죋o textu

; ------ 즧chova adresy INT 08h, INT 21h a INT 28h

         mov       ax,3508h
         int       21h                      ; poskytnut� adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; 즧chova INT 08h
         mov       word ptr ds:[Old08+2],es

         mov       ax,3521h
         int       21h                      ; poskytnut� adresy INT 21h
         mov       word ptr ds:[Old21],bx   ; 즧chova INT 21h
         mov       word ptr ds:[Old21+2],es

         mov       ax,3528h
         int       21h                      ; poskytnut� adresy INT 28h
         mov       word ptr ds:[Old28],bx
         mov       word ptr ds:[Old28+2],es

; ------ instalace pæznaku aktivity DOS

         mov       bx,-1                    ; BX <- 0ffffh nepovolen� hodnota
         mov       es,bx                    ; ES <- 0ffffh nepovolen� hodnota
         mov       ah,34h
         int       21h                      ; poskytnut� pæznaku aktivity DOS
         mov       ax,es
         inc       ax                       ; m� ES povolenou hodnotu ?
         jnz       Instal0                  ; ES je definov쟮o OK
         mov       bx,es                    ; ES i BX maj� hodnotu 0ffffh
Instal0: mov       word ptr ds:[Aktiv21],bx ; adresa pæznaku aktivity DOS
         mov       word ptr ds:[Aktiv21+2],es ; segment pæznaku aktivity DOS

; ------ instalace pæznaku obsluhy chyby DOS

         push      ds
         mov       si,-1                    ; SI <- 0ffffh nepovolen� hodnota
         mov       ds,si                    ; DS <- 0ffffh nepovolen� hodnota
         mov       ax,5d06h
         int       21h                      ; poskytnut� pæznaku chyby DOS
         jnc       Instal03                 ; operace OK
         mov       si,-1                    ; adresa je neplatn�
Instal03:mov       ax,ds                    ; segment adresy
         inc       ax                       ; m� DS povolenou hodnotu ?
         jnz       Instal04                 ; DS je definov쟮o OK
         mov       si,ds                    ; DS i SI maj� hodnotu 0ffffh
Instal04:dec       ax                       ; n쟶rat DS
         pop       ds
         mov       word ptr ds:[ErrDOS],si ; adresa pæznaku aktivity DOS
         mov       word ptr ds:[ErrDOS+2],ax ; segment pæznaku aktivity DOS

; ------ 즧chova pækazov괿o 찤dku

         push      ds
         pop       es                       ; ES <- DS

         mov       si,81h                   ; pækazov� 찤dek
         mov       cl,ds:[si-1]             ; d굃ka pækazov괿o 찤dku
         mov       ch,0
         mov       di,offset ComLine        ; buffer pækazov괿o 찤dku
         cld
         rep       movsb                    ; 즧chova pækazov괿o 찤dku
         mov       al,0                     ; koncov� nula
         stosb                              ; ozna놽n� konce pækazov괿o 찤dku

; ------ posun programu n죷e

         mov       si,offset RezBeg         ; za뇿tek rezidentn죋o modulu
         mov       di,offset RezBeg + KORIG ; nov� za뇿tek rezidentn죋o modulu
         mov       cx,offset(RezEnd-RezBeg) ; d굃ka rezidentn죋o modulu
         rep       movsb                    ; p쯥sun programu n죷e

; ------ test, je-li program rezidentn� (DS=ES !)

         mov       ax,KLICFN                ; kl죬 funkce a dotazu
         mov       bx,KLIC1                 ; identifika뇆� kl죬 1
         mov       cx,KLIC2                 ; identifika뇆� kl죬 2
         mov       dx,KLIC3                 ; identifika뇆� kl죬 3
         int       21h                      ; test instalace
         cmp       ax,KLICOK                ; odpov늕n� kl죬
         jne       Instal1                  ; program nen� rezidentn�
         cmp       word ptr es:[Ident+KORIG],"TP" ; souhlas� identifikace ?
         je        Instal2                  ; program je rezidentn� OK

Instal1: push      cs
         pop       es                       ; ES <- segment tohoto programu
         and       byte ptr ds:[InstPar],not bit0 ; nen� rezidentn�

; ------ zad쟮� port� (ES=rezidentn� segment)

Instal2: mov       si,offset ComLine        ; buffer pækazov괿o 찤dku

         mov       di,offset InpPort+KORIG  ; vstupn� port
         call      RozbPort                 ; rozbor zad쟮� portu
         jc        Instal4                  ; vstupn� port nezad쟮

         mov       di,offset OutPort+KORIG  ; v쁲tupn� port
         call      RozbPort                 ; rozbor zad쟮� portu
         jc        Chyba0                   ; port nezad쟮
         jmp       Inst                     ; instalace programu

; ------ po멲davek odinstalov쟮� programu

Instal4: call      RozbChr                  ; na뇍en� znaku
         jc        Instal5                  ; nen� dalÆ znak

         cmp       al,"!"                   ; odinstalov쟮� ?
         jne       Chyba0                   ; chybn� parametry
         jmp       OdInst                   ; odinstalov쟮� programu

; ------ nen� nic zad쟮o - zobrazen� stavu

Instal5: test      byte ptr ds:[InstPar],bit0 ; je nainstalov쟮 ?
         jz        Chyba0                   ; nen� nainstalov쟮 - chyba
         call      DispStav                 ; zobrazen� stavu
         int       20h

Chyba0:  mov       dx,offset HelpTxt        ; chybov� hl젴en�
Chyba:   call      DispTxt                  ; zobrazen� chyby
Konec:   int       20h

; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------

Inst:    call      DispStav                 ; zobrazen� aktu쟫n죋o stavu
         test      byte ptr ds:[InstPar],bit0 ; je ji� nainstalov쟮 ?
         jnz       Konec                    ; je ji� nainstalov쟮

; ------ hl젴en� o nainstalov쟮�

         mov       dx,offset InstTxt
         call      DispTxt                  ; hl젴en� o nainstalov쟮�

; ------ instalace obsluh INT 08h, INT 21h a INT 28h

         mov       ax,2508h
         mov       dx,offset INT08+KORIG
         int       21h                      ; instalace INT 08h

         mov       ax,2521h
         mov       dx,offset INT21+KORIG
         int       21h                      ; instalace INT 21h

         mov       ax,2528h
         mov       dx,offset INT28+KORIG
         int       21h                      ; instalace INT 28h

; ------ uvoln늧� segmentu prost쯥d�

         mov       es,ds:[2ch]              ; segment prost쯥d�
         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu prost쯥d�

; ------ instalace programu

         mov       dx,offset RezEnd+KORIG   ; konec rezidentn죋o modulu
         int       27h                      ; instalace do pam늯i

; -----------------------------------------------------------------------------
;        zobrazen� stavu programu (ES=rezidentn� segment)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

; ------ vstupn� port

         mov       dx,offset VstupTxt
         call      DispTxt

         mov       al,byte ptr es:[InpPort+KORIG+2] ; ozna놽n� vstupn죋o portu
         mov       ds:[COMTxt1],al          ; ozna놽n� vstupn죋o portu
         mov       dx,offset COMTxt         ; port plat�
         cmp       al,"0"                   ; je port platn� ?
         jne       DispStv2                 ; port je platn� OK
         mov       dx,offset NicTxt
DispStv2:call      DispTxt                  ; zobrazen� vstupn죋o portu

; ------ v쁲tupn� port

         mov       dx,offset VystTxt
         call      DispTxt

         mov       al,byte ptr es:[OutPort+KORIG+2] ; ozna놽n� v쁲tupn죋o portu
         mov       ds:[COMTxt1],al          ; ozna놽n� v쁲tupn죋o portu
         mov       dx,offset COMTxt         ; port plat�
         cmp       al,"0"                   ; je port platn� ?
         jne       DispStv4                 ; port je platn� OK
         mov       dx,offset NicTxt
DispStv4:call      DispTxt                  ; zobrazen� v쁲tupn죋o portu

; ------ 놹s posledn죋o pæjmu

         mov       al,es:[HodinaL+KORIG]    ; hodina pæjmu
         cmp       al,-1
         je        DispStv9                 ; nebyl pæjem

         aam
         or        ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt0],ax ; hodina pæjmu

         mov       al,es:[MinutaL+KORIG]    ; minuta pæjmu
         aam
         or        ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt0+3],ax ; minuta pæjmu

         mov       al,es:[SekundaL+KORIG]    ; sekunda pæjmu
         aam
         or        ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt0+6],ax ; sekunda pæjmu

DispStv9:mov       dx,offset LastTxt        ; posledn� p쯫jat� 놹s
         call      DispTxt
         ret

DispStav ENDP

; -----------------------------------------------------------------------------
;        odinstalov쟮� programu (ES=rezidentn� segment)
; -----------------------------------------------------------------------------

; ------ test, zda je program rezidentn�

OdInst:  mov       dx,offset NeniTxt        ; nen� nainstalov쟮
         test      byte ptr ds:[InstPar],bit0 ; je program rezidentn� ?
         jz        OdInst6                  ; program nen� rezidentn�

; ------ test segment� INT 08h, INT 21h a INT 28h

         mov       dx,offset NelzeTxt       ; hl젴en� - nelze odinstalovat
         mov       ax,es                    ; AX <- rezidentn� segment
         cmp       ax,word ptr ds:[Old08+KORIG+2] ; souhlas� INT 08h ?
         jne       OdInst6                  ; nesouhlas�
         cmp       ax,word ptr ds:[Old21+KORIG+2] ; souhlas� INT 21h ?
         jne       OdInst6                  ; nesouhlas�
         cmp       ax,word ptr ds:[Old28+KORIG+2] ; souhlas� INT 28h ?
         jne       OdInst6                  ; nesouhlas�

; ------ n쟶rat adresy INT 08h, INT 21h a INT 28h

         push      ds
         mov       ax,2508h
         lds       dx,es:[Old08+KORIG]      ; p뻱odn� adresa INT 08h
         int       21h                      ; n쟶rat adresy INT 08h
         mov       ax,2521h
         lds       dx,es:[Old21+KORIG]      ; p뻱odn� adresa INT 21h
         int       21h                      ; n쟶rat adresy INT 21h
         mov       ax,2528h
         lds       dx,es:[Old28+KORIG]      ; p뻱odn� adresa INT 28h
         int       21h                      ; n쟶rat adresy INT 28h
         pop       ds

; ------ zru쮍n� segmentu programu

         mov       ah,49h
         int       21h                      ; uvoln늧� segmentu programu
         mov       dx,offset DInsTxt        ; hl젴en� o odinstalov쟮�
OdInst6: jmp       Chyba

; -----------------------------------------------------------------------------
;        rozbor zad쟮� portu SI -> ES:DI
; -----------------------------------------------------------------------------

RozbPort PROC      NEAR

         call      RozbChr                  ; na뇍en� znaku
         jc        RozbPrt6                 ; nen� znak

         mov       cl,al                    ; CL <- 즧chova ozna놽n� portu COM
         mov       ds:[NeniCOM1],al         ; ozna놽n� portu pro hl젴en�
         cmp       al,"4"
         ja        RozbPrt5                 ; nen� 눀slice
         xor       dx,dx                    ; p쯫 vypnut� portu
         sub       al,"0"
         jb        RozbPrt5                 ; nen� 눀slice
         je        RozbPrt3                 ; port vypnut

         push      ds

         mov       ah,0
         dec       ax                       ; je쮝� korekce 눀sla portu

         push      es
         push      ax                       ; AX = 눀slo portu 0...
         push      cx
         push      si
         push      di

         xchg      ax,dx                    ; DX <- 눀slo portu
         mov       ax,10000011b             ; 1200 Baud/bez parity/1 STOP/8 bit�
         int       14h                      ; nastaven� parametr� portu

         pop       di
         pop       si
         pop       cx
         pop       bx                       ; BX <- 눀slo portu
         pop       es

         shl       bx,1                     ; offset v tabulce
         mov       ax,40h
         mov       ds,ax                    ; DS <- segment BIOS
         mov       dx,ds:[bx]               ; adresa portu

         pop       ds
         or        dx,dx                    ; je port nainstalov쟮 ?
         jnz       RozbPrt3                 ; port nen� nainstalov쟮

         mov       dx,offset NeniCOM
         jmp       Chyba                    ; chybov� hl젴en�

RozbPrt3:mov       es:[di],dx               ; adresa portu
         mov       es:[di+2],cl             ; ozna놽n� portu ASCII
         mov       byte ptr es:[Param+KORIG],0 ; uveden� obsluhy do klidu
         clc                                ; pæznak operace OK
         ret

RozbPrt5:dec       si                       ; n쟶rat neplatn괿o znaku
         stc
RozbPrt6:ret

RozbPort ENDP

; -----------------------------------------------------------------------------
;        na뇍en� znaku z pækazov괿o 찤dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

RozbChr1:cmp       byte ptr ds:[si],0       ; konec textu ?
         stc
         je        RozbChr3                 ; konec textu
         cld
         lodsb                              ; na뇍en� znaku
         cmp       al," "                   ; je mezera nebo tabul쟴or ?
         jbe       RozbChr1                 ; mezera nebo tabul쟴or se ignoruje
         cmp       al,"/"                   ; odd늢ova� parametr� ?
         je        RozbChr1                 ; odd늢ova� parametr� se ignoruje
         cmp       al,"-"                   ; odd늢ova� parametr� ?
         je        RozbChr1                 ; odd늢ova� parametr� se ignoruje
         clc                                ; pæznak operace OK

RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen� textu DS:DX
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

InstPar  db        bit0                     ; parametry pro instalaci
                                            ;    bit 0: 1=program je rezidentn�

UvTxt    db        'PCTIME V1.0 - synchronizace casu pocitacu; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        13,10
         db        'Zadejte:   PCTIME  vstup  vystup',13,10
         db        13,10
         db        '              vstup ...... cislo portu COM pro vstup casu',13,10
         db        '                           (1 az 4, 0 = neni vstup)',13,10
         db        '              vystup ..... cislo portu COM pro vystup casu',13,10
         db        '                           (1 az 4, 0 = neni vystup)',13,10
         db        13,10
         db        '  nebo:    PCTIME !  .... odinstalovani programu z pameti',13,10
         db        13,10
         db        '$'

VstupTxt db        'vstup: $'
COMTxt   db        'COM'
COMTxt1  db        '1:$'
NicTxt   db        ' -- $'
VystTxt  db        '    vystup: $'
LastTxt  db        13,10,'posledni prijaty cas v '
LastTxt0 db        '--:--:--',13,10,'$'

NeniCOM  db        'Port COM'
NeniCOM1 db        '0: neni v pocitaci pritomen !',13,10,'$'

NeniTxt  db        'Program nelze odinstalovat, neni nainstalovan !',13,10,'$'
NelzeTxt db        'Program nelze odinstalovat, nutno odinstalovat',13,10
         db        'nejdrive programy nainstalovane pozdeji !',13,10,'$'
DInsTxt  db        'Program byl odinstalovan z pameti.',13,10,'$'

InstTxt  db        'Program byl nainstalovan do pameti.',13,10,'$'

ComLine  db        128 dup(?)               ; uschovan� pækazov� 찤dek

Code     ENDS
         END       Start

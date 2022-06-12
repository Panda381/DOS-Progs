
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;
;                            Synchronizace ‡asu po‡¡ta‡–
;
; -----------------------------------------------------------------------------
; Protokol:
;
; Vys¡la‡ vys¡l  data ka‘d‚ 2 impulsy hodin (tj. ka‘d˜ch 110 ms). Data se
; p©en ¨¡ rychlost¡ 1200 Baud, 8 bit– bez parity, 1 stop bit
;
;      (1) synchroniza‡n¡ bajt (oddˆlova‡ zpr vy) ...... 92        + 32 ("|")
;      (1) rok - 1980 (tj. offset od roku 1980) ........ (0 a‘ 90) + 32
;      (1) mˆs¡c ....................................... (1 a‘ 12) + 32
;      (1) den ......................................... (1 a‘ 31) + 32
;      (1) hodina ...................................... (0 a‘ 23) + 32
;      (1) minuta ...................................... (0 a‘ 59) + 32
;      (1) sekunda ..................................... (0 a‘ 59) + 32
;      (1) setina sekundy/2 ............................ (0 a‘ 49) + 32
;      (1) kontroln¡ sou‡et dat (bez "+ 32") MOD 64 .... (0 a‘ 63) + 32
;
; Ke v¨em bajt–m se p©i‡¡t  hodnota 32, data se p©en ¨¡ jako bˆ‘n‚ znaky ASCII.
;
; P©en ¨en˜ £daj o ‡asu je platn˜ okam‘ikem vys¡l n¡ synchroniza‡n¡ho bajtu.
; P©ij¡ma‡ proto £daj po p©ijet¡ zkoriguje podle p©en ¨en‚ doby zpr vy
; (tedy p©i‡te zhruba 1 sekundu k £daji).
;
; Operace aktualizace ‡asu se prov d¡ zhruba ka‘d˜ch 15 a‘ 30 sekund.
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;DEBUG    EQU       1                        ; p©¡znak lad¡c¡ho re‘imu

SYNCH    EQU       92                       ; synchroniza‡n¡ bajt bez "+32"

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

KLICFN   EQU       2bh*HI + "?"             ; kl¡‡ funkce a dotazu
KLIC1    EQU       'PC'                     ; identifika‡n¡ kl¡‡ 1 (BX)
KLIC2    EQU       'TI'                     ; identifika‡n¡ kl¡‡ 2 (CX)
KLIC3    EQU       'ME'                     ; identifika‡n¡ kl¡‡ 3 (DX)
KLICOK   EQU       'OK'                     ; odpovˆdn¡ kl¡‡ (AX)


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

RezBeg   label     byte                     ; za‡ tek rezidentn¡ho modulu

Ident    db        'PT'                     ; identifikace v pamˆti

Old08    dd        0                        ; uschovan  adresa INT 08h
Old21    dd        0                        ; uschovan  adresa INT 21h
Old28    dd        0                        ; p–vodn¡ adresa obsluhy INT 28h

Aktiv21  dd        0                        ; adresa p©¡znaku aktivity DOS
ErrDOS   dd        0                        ; adresa p©¡znaku obsluhy chyby DOS

InpPort  dw        0                        ; adresa vstupn¡ho portu COM (0=nen¡)
         db        "0"                      ; ‡¡slo vstupn¡ho portu ASCII

OutPort  dw        0                        ; adresa v˜stupn¡ho portu COM (0=nen¡)
         db        "0"                      ; ‡¡slo v˜stupn¡ho portu ASCII

HodinaL  db        -1                       ; hodina posledn¡ korekce ‡asu
MinutaL  db        -1                       ; minuta posledn¡ korekce ‡asu
SekundaL db        -1                       ; sekunda posledn¡ korekce ‡asu

Param    db        0                        ; parametry
                                            ;   bit 0: 1=obsluha vys¡l n¡
                                            ;   bit 1: 1=bude SYNCHRO ÄÄ¿0=nen¡
                                            ;   bit 2: 1=bude zpr va    ³obsluha
                                            ;   bit 3: 1=prob¡h  zpr va ³COM
                                            ;   bit 4: 1=bude CRC     ÄÄÙ
                                            ;   bit 5: 1=bude DOS
                                            ;   bit 6: 1=lich˜ impuls vys¡l n¡

NextCit  db        0                        ; ‡¡ta‡ 1/18s pro p©¡¨t¡ p©enos

Korekce  dw        0                        ; korekce p©i p©¡jmu

Ukaz     dw        offset Zprava+KORIG      ; ukazatel zpr vy

CRC      db        0                        ; st©ada‡ CRC

Zprava   label     byte                     ; p©en ¨en  zpr va (data/min/max)
Rok      db        0,0,90                   ; rok - 1980
Mesic    db        0,1,12                   ; mˆs¡c
Den      db        0,1,31                   ; den
Hodina   db        0,0,23                   ; hodina
Minuta   db        0,0,59                   ; minuta
Sekunda  db        0,0,59                   ; sekunda
Zprava0  label     byte                     ; posledn¡ polo‘ka
Setina   db        0,0,49                   ; setina sekundy/2 (tj. 1/50 sekundy)

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ ‡¡t n¡ korekce p©i p©¡jmu

         inc       word ptr cs:[Korekce+KORIG] ; ‡¡t n¡ korekce p©i p©¡jmu

; ------ test, zda m  b˜t nˆjak  obsluha portem

         test      byte ptr cs:[Param+KORIG],bit1+bit2+bit3+bit4 ; bude COM ?
         jnz       Int081                   ; je nˆjak  obsluha COM

; ------ aktivace dal¨¡ operace

         inc       byte ptr cs:[NextCit+KORIG] ; ‡¡ta‡ aktivace operace
         jnz       Int080                   ; nebude dal¨¡ operace

         cmp       word ptr cs:[InpPort+KORIG],0 ; je vstupn¡ port ?
         je        Int0802                  ; nen¡ vstupn¡ port
         mov       byte ptr cs:[Param+KORIG],bit1 ; aktivace p©ij¡ma‡e
         push      dx
         mov       dx,cs:[InpPort+KORIG]    ; adresa vstupn¡ho portu
         jmp       short Int0801

Int0802: cmp       word ptr cs:[OutPort+KORIG],0 ; je v˜stupn¡ port ?
         je        Int080                   ; nen¡ ani v˜stupn¡ port
         mov       byte ptr cs:[Param+KORIG],bit0+bit5 ; aktivace vys¡la‡e
         push      dx
         mov       dx,cs:[OutPort+KORIG]    ; adresa v˜stupn¡ho portu
Int0801: call      InitPort                 ; inicializace portu DX
         pop       dx

Int080:  jmp       dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h

; ------ p–vodn¡ obsluha INT 08h

Int081:  pushf
         call      dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      ds

         push      cs
         pop       ds                       ; DS <- datov˜ segment

         mov       ah,ds:[Param+KORIG]      ; parametry vys¡l n¡

; ------ test, zda je obsluha vys¡l n¡

         test      ah,bit0                  ; je vys¡l n¡ ?
         jz        Int084                   ; nen¡ vys¡l n¡ - je p©¡jem
         xor       ah,bit6                  ; p©¡znak lich‚ho impulsu
         test      ah,bit6                  ; je lich˜ impuls ?
         jnz       Int0839                  ; je lich˜ impuls - p©esko‡¡ se

; ------ test, zda je vys¡lac¡ buffer pr zdn˜

         mov       dx,ds:[OutPort+KORIG]    ; adresa vys¡lac¡ho portu COM
         add       dx,5
         in        al,dx                    ; na‡ten¡ stavov‚ho registru
         sub       dx,5
         test      al,bit5                  ; je vys¡lac¡ registr pr zdn˜ ?
         jz        Int0839                  ; vys¡lac¡ registr nen¡ pr zdn˜

; ------ vysl n¡ SYNCHRO

         test      ah,bit1                  ; m  b˜t SYNCHRO ?
         jz        Int0822                  ; nem  b˜t SYNCHRO
         mov       word ptr ds:[Ukaz+KORIG],offset Zprava+KORIG ; ukazatel zpr vy
         mov       byte ptr ds:[CRC+KORIG],0 ; nulov n¡ st©ada‡e CRC
         mov       ah,bit0+bit3             ; bude zpr va
         mov       al,SYNCH                 ; synchroniza‡n¡ bajt
         jmp       short Int083             ; vysl n¡ bajtu

; ------ vys¡l n¡ zpr vy

Int0822: test      ah,bit3                  ; je zpr va ?
         jz        Int0823                  ; nen¡ zpr va
         mov       bx,ds:[Ukaz+KORIG]       ; ukazatel zpr vy
         mov       al,ds:[bx]               ; znak k vysl n¡
         add       byte ptr ds:[CRC+KORIG],al ; ‡¡t n¡ st©ada‡e CRC
         add       word ptr ds:[Ukaz+KORIG],3 ; posun ukazatele zpr vy
         cmp       bx,offset Zprava0+KORIG  ; je to posledn¡ polo‘ka ?
         jb        Int083                   ; nen¡ to posledn¡ polo‘ka
         mov       ah,bit0+bit4             ; bude vysl n¡ CRC
         jmp       short Int083

; ------ vysl n¡ CRC

Int0823: mov       al,ds:[CRC+KORIG]        ; znak CRC k vysl n¡
         and       al,bit0+bit1+bit2+bit3+bit4+bit5 ; je v modulu MOD 64
         mov       ah,0                     ; konec vys¡l n¡

; ------ vysl n¡ znaku AL

Int083:  add       al,32                    ; posun na ASCII znak
         out       dx,al                    ; vysl n¡ znaku AL
Int0839: jmp       Int089

; ------ test, zda je p©ijat˜ znak

Int084:  mov       dx,ds:[InpPort+KORIG]    ; adresa p©ij¡mac¡ho portu COM
         add       dx,5                     ; stavov˜ registr linky
         in        al,dx                    ; na‡ten¡ stavov‚ho registru
         sub       dx,5
         test      al,bit0                  ; je p©ipraven znak ?
         jz        Int089                   ; znak nen¡ p©ipraven

; ------ p©¡jem znaku, korekce znaku

         in        al,dx                    ; p©¡jem znaku
         sub       al,32                    ; korekce znaku
         cmp       al,SYNCH                 ; maxim ln¡ znak
         jbe       Int085                   ; znak vyhovuje OK

; ------ zah jen¡ nov‚ho p©¡jmu (AL=znak)

Int0849: mov       ah,bit1                  ; p©¡znak ‡ek n¡ na SYNCHRO

; ------ ‡ek n¡ na SYNCHRO

Int085:  test      ah,bit1                  ; ‡ek  se na SYNCHRO ?
         jz        Int0852                  ; ne‡ek  se na SYNCHRO
         cmp       al,SYNCH                 ; je SYNCHRO ?
         jne       Int089                   ; nen¡ SYNCHRO
         mov       ah,bit2                  ; bude ‡ek n¡ na zpr vu
Int0851: mov       word ptr ds:[Korekce+KORIG],4 ; nulov n¡ ‡¡ta‡e korekce
         jmp       short Int089

; ------ ‡ek n¡ na zpr vu

Int0852: test      ah,bit2                  ; je ‡ek n¡ na zpr vu ?
         jz        Int0854                  ; nen¡ ‡ek n¡ na zpr vu
         cmp       al,SYNCH                 ; je synchronizace ?
         je        Int0851                  ; je synchronizace
         mov       ah,bit3                  ; p©¡znak, ‘e prob¡h  zpr va
         mov       word ptr ds:[Ukaz+KORIG],offset Zprava+KORIG ; ukazatel zpr vy
         mov       byte ptr ds:[CRC+KORIG],0 ; nulov n¡ st©ada‡e CRC

; ------ p©¡jem zpr vy

Int0854: test      ah,bit3                  ; prob¡h  zpr va ?
         jz        Int0856                  ; nen¡ zpr va
         mov       bx,ds:[Ukaz+KORIG]       ; ukazatel zpr vy
         cmp       al,ds:[bx+1]             ; kontrola minim ln¡ hodnoty
         jb        Int0849                  ; nespr vn  hodnota
         cmp       al,ds:[bx+2]             ; kontrola maxim ln¡ hodnoty
         ja        Int0849                  ; nespr vn  hodnota
         mov       ds:[bx],al               ; ulo‘en¡ znaku
         add       ds:[CRC+KORIG],al        ; p©i‡ten¡ CRC
         add       word ptr ds:[Ukaz+KORIG],3 ; posun ukazatele

; ------ test, je-li konec p©¡jmu

         cmp       bx,offset Zprava0+KORIG  ; byla to posledn¡ polo‘ka ?
         jb        Int089                   ; nen¡ to posledn¡ polo‘ka
         mov       ah,bit4                  ; bude CRC
         jmp       short Int089

; ------ p©¡jem CRC

Int0856: cmp       al,64                    ; kontrola hodnoty CRC
         jae       Int0849                  ; nespr vn  hodnota CRC
         xor       ds:[CRC+KORIG],al        ; test CRC
         test      byte ptr ds:[CRC+KORIG],bit0+bit1+bit2+bit3+bit4+bit5 ; souhlas¡ CRC ?
         jnz       Int0849                  ; CRC nesouhlas¡
         mov       ah,bit5                  ; bude nastaven¡ DOS

; ------ n vrat registr–

Int089:  mov       ds:[Param+KORIG],ah      ; nov‚ parametry

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
         cmp       ax,KLICFN                ; funk‡n¡ kl¡‡
         jne       Int212
         cmp       bx,KLIC1                 ; identifika‡n¡ kl¡‡ 1
         jne       Int212
         cmp       cx,KLIC2                 ; identifika‡n¡ kl¡‡ 2
         jne       Int212
         cmp       dx,KLIC3                 ; identifika‡n¡ kl¡‡ 3
         jne       Int212
         mov       ax,KLICOK                ; odpovˆdn¡ kl¡‡
         push      cs
         pop       es                       ; ES <- segment programu
         popf
         iret

Int212:  popf

; ------ obsluha INT 21h

         call      IntDOS                   ; obsluha p©¡stupu k DOS
         jmp       dword ptr cs:[Old21+KORIG] ; pokra‡ov n¡ p–vodn¡ obsluhou

Int21    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         call      IntDOS                   ; obsluha p©¡stupu k DOS
         jmp       dword ptr cs:[Old28+KORIG] ; pokra‡ov n¡ p–vodn¡ obsluhou

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha p©¡stupu k DOS
; -----------------------------------------------------------------------------

IntDOS   PROC      NEAR

; ------ test, zda m  b˜t obsluha ‡asu DOS

         pushf
         test      byte ptr cs:[Param+KORIG],bit5 ; po‘adavek obsluhy DOS ?
         jnz       IntDOS1                  ; je po‘adavek obsluhy DOS
IntDOS0: jmp       IntDOS9                  ; nen¡ po‘adov na obsluha DOS

; ------ test p©¡znaku aktivity DOS

IntDOS1: push      ds
         push      bx
         lds       bx,cs:[Aktiv21+KORIG]    ; adresa p©¡znaku aktivity DOS
         cmp       bx,-1                    ; je adresa definov na ?
         je        IntDOS2                  ; nen¡ definov na
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn¡ ?
IntDOS2: pop       bx
         pop       ds
         jne       IntDOS0                  ; DOS je aktivn¡

; ------ test p©¡znaku obsluhy chyby DOS

         push      ds
         push      bx
         lds       bx,cs:[ErrDOS+KORIG]     ; adresa p©¡znaku obsluhy chyby DOS
         cmp       bx,-1                    ; je adresa definov na ?
         je        IntDOS3                  ; nen¡ definov na
         cmp       byte ptr ds:[bx],0       ; je chyba DOS aktivn¡ ?
IntDOS3: pop       bx
         pop       ds
         jne       IntDOS0                  ; obsluha chyby DOS je aktivn¡

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

         push      cs
         pop       ds                       ; DS <- CS

; ------ test, zda je vys¡l n¡

         test      byte ptr ds:[Param+KORIG],bit0 ; je vys¡l n¡ ?
         jz        IntDOS4                  ; nen¡ vys¡l n¡

; ------ na‡ten¡ data DOS

IntDOS32:mov       ah,2ah
         call      Int21P                   ; na‡ten¡ data DOS
         sub       cx,1980                  ; offset od roku 1980
         mov       ds:[Rok+KORIG],cl        ; offset od roku 1980
         mov       ds:[Mesic+KORIG],dh      ; mˆs¡c
         mov       ds:[Den+KORIG],dl        ; den

; ------ na‡ten¡ ‡asu DOS

         mov       ah,2ch
         call      Int21P                   ; na‡ten¡ ‡asu DOS
         mov       ds:[Hodina+KORIG],ch     ; hodina
         mov       ds:[Minuta+KORIG],cl     ; minuta
         mov       ds:[Sekunda+KORIG],dh    ; sekunda
         shr       dl,1                     ; setina / 2
         mov       ds:[Setina+KORIG],dl     ; setina sekundy
         mov       byte ptr ds:[Param+KORIG],bit0+bit1 ; vys¡l n¡ SYNCHRO
         jmp       IntDOS8

; ------ korekce ‡asu

IntDOS4: mov       ax,ds:[Korekce+KORIG]    ; korekce ‡asu
         cmp       ax,30*18                 ; maxim ln¡ prodleva 30 sekund
         ja        IntDOS7                  ; to je ji‘ p©¡li¨ dlouho
         mov       cx,100
         mul       cx
         mov       cl,18
         div       cx                       ; p©epo‡et na 1/100 sekund
                                          ;* zde je AX maxim lnˆ 3000
         shl       byte ptr ds:[Setina+KORIG],1 ; p©evod setin/2 na setiny
         add       al,ds:[Setina+KORIG]     ; p©i‡ten¡ 1/100 sekund
         adc       ah,0
         mov       cl,100
         div       cl                       ; p©epo‡et na sekundy a setiny
         mov       ds:[Setina+KORIG],ah     ; setina sekundy
         add       ds:[Sekunda+KORIG],al    ; korekce sekund
         cmp       byte ptr ds:[Sekunda+KORIG],60
         jb        IntDOS5
         sub       byte ptr ds:[Sekunda+KORIG],60
         inc       byte ptr ds:[Minuta+KORIG] ; korekce minut (p©ete‡en¡ ignoruje)

; ------ nastaven¡ ‡asu DOS

IntDOS5: mov       ch,ds:[Hodina+KORIG]     ; hodina
         mov       cl,ds:[Minuta+KORIG]     ; minuta
         mov       dh,ds:[Sekunda+KORIG]    ; sekunda
         mov       dl,ds:[Setina+KORIG]     ; setina sekundy
         mov       ah,2dh
         call      Int21P                   ; nastaven¡ syst‚mov‚ho ‡asu
         cmp       al,0                     ; byl ‡as OK ?
         jne       IntDOS6                  ; nebyl spr vn˜ ‡as
         mov       ds:[HodinaL+KORIG],ch    ; naposledy proveden  korekce
         mov       ds:[MinutaL+KORIG],cl    ; naposledy proveden  korekce
         mov       ds:[SekundaL+KORIG],dh   ; naposledy proveden  korekce

; ------ nastaven¡ data DOS

IntDOS6: mov       cl,ds:[Rok+KORIG]        ; rok - 1980
         mov       ch,0
         add       cx,1980                  ; oprava data
         mov       dh,ds:[Mesic+KORIG]      ; mˆs¡c
         mov       dl,ds:[Den+KORIG]        ; den
         mov       ah,2bh
         call      Int21P                   ; nastaven¡ syst‚mov‚ho data

; ------ n sleduje vys¡l n¡

IntDOS7: mov       byte ptr ds:[Param+KORIG],0 ; konec p©¡jmu
         cmp       word ptr ds:[OutPort+KORIG],0 ; je v˜stupn¡ port ?
         je        IntDOS8                  ; nen¡ v˜stupn¡ port
         jmp       IntDOS32                 ; aktivace vys¡la‡e

; ------ n vrat registr–

IntDOS8: pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
IntDOS9: popf
         ret

IntDOS   ENDP

; -----------------------------------------------------------------------------
;        vol n¡ funkce DOS (DS=CS !)
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

         add       dx,3                     ; ©¡dic¡ registr linky
         mov       al,80h
         out       dx,al                    ; zapnut¡ sign lu DLAB
         sub       dx,3                     ; registr dˆli‡ky

         mov       al,96
         out       dx,al                    ; ni‘¨¡ bajt pro rychlost 1200 Baud
         inc       dx
         mov       al,0
         out       dx,al                    ; vy¨¨¡ bajt pro rychlost 1200 Baud

         inc       dx
         inc       dx
         mov       al,00000011b             ; nen¡ parita, 1 STOP, 8 bit–
         out       dx,al                    ; nastaven¡ parametr– p©enosu

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

RezEnd   label     byte                     ; konec rezidentn¡ho modulu

; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------
;þ
; ------ zobrazen¡ £vodn¡ho textu

Instal:  mov       dx,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ £schova adresy INT 08h, INT 21h a INT 28h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; £schova INT 08h
         mov       word ptr ds:[Old08+2],es

         mov       ax,3521h
         int       21h                      ; poskytnut¡ adresy INT 21h
         mov       word ptr ds:[Old21],bx   ; £schova INT 21h
         mov       word ptr ds:[Old21+2],es

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr ds:[Old28],bx
         mov       word ptr ds:[Old28+2],es

; ------ instalace p©¡znaku aktivity DOS

         mov       bx,-1                    ; BX <- 0ffffh nepovolen  hodnota
         mov       es,bx                    ; ES <- 0ffffh nepovolen  hodnota
         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku aktivity DOS
         mov       ax,es
         inc       ax                       ; m  ES povolenou hodnotu ?
         jnz       Instal0                  ; ES je definov no OK
         mov       bx,es                    ; ES i BX maj¡ hodnotu 0ffffh
Instal0: mov       word ptr ds:[Aktiv21],bx ; adresa p©¡znaku aktivity DOS
         mov       word ptr ds:[Aktiv21+2],es ; segment p©¡znaku aktivity DOS

; ------ instalace p©¡znaku obsluhy chyby DOS

         push      ds
         mov       si,-1                    ; SI <- 0ffffh nepovolen  hodnota
         mov       ds,si                    ; DS <- 0ffffh nepovolen  hodnota
         mov       ax,5d06h
         int       21h                      ; poskytnut¡ p©¡znaku chyby DOS
         jnc       Instal03                 ; operace OK
         mov       si,-1                    ; adresa je neplatn 
Instal03:mov       ax,ds                    ; segment adresy
         inc       ax                       ; m  DS povolenou hodnotu ?
         jnz       Instal04                 ; DS je definov no OK
         mov       si,ds                    ; DS i SI maj¡ hodnotu 0ffffh
Instal04:dec       ax                       ; n vrat DS
         pop       ds
         mov       word ptr ds:[ErrDOS],si ; adresa p©¡znaku aktivity DOS
         mov       word ptr ds:[ErrDOS+2],ax ; segment p©¡znaku aktivity DOS

; ------ £schova p©¡kazov‚ho © dku

         push      ds
         pop       es                       ; ES <- DS

         mov       si,81h                   ; p©¡kazov˜ © dek
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         mov       di,offset ComLine        ; buffer p©¡kazov‚ho © dku
         cld
         rep       movsb                    ; £schova p©¡kazov‚ho © dku
         mov       al,0                     ; koncov  nula
         stosb                              ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ posun programu n¡‘e

         mov       si,offset RezBeg         ; za‡ tek rezidentn¡ho modulu
         mov       di,offset RezBeg + KORIG ; nov˜ za‡ tek rezidentn¡ho modulu
         mov       cx,offset(RezEnd-RezBeg) ; d‚lka rezidentn¡ho modulu
         rep       movsb                    ; p©esun programu n¡‘e

; ------ test, je-li program rezidentn¡ (DS=ES !)

         mov       ax,KLICFN                ; kl¡‡ funkce a dotazu
         mov       bx,KLIC1                 ; identifika‡n¡ kl¡‡ 1
         mov       cx,KLIC2                 ; identifika‡n¡ kl¡‡ 2
         mov       dx,KLIC3                 ; identifika‡n¡ kl¡‡ 3
         int       21h                      ; test instalace
         cmp       ax,KLICOK                ; odpovˆdn¡ kl¡‡
         jne       Instal1                  ; program nen¡ rezidentn¡
         cmp       word ptr es:[Ident+KORIG],"TP" ; souhlas¡ identifikace ?
         je        Instal2                  ; program je rezidentn¡ OK

Instal1: push      cs
         pop       es                       ; ES <- segment tohoto programu
         and       byte ptr ds:[InstPar],not bit0 ; nen¡ rezidentn¡

; ------ zad n¡ port– (ES=rezidentn¡ segment)

Instal2: mov       si,offset ComLine        ; buffer p©¡kazov‚ho © dku

         mov       di,offset InpPort+KORIG  ; vstupn¡ port
         call      RozbPort                 ; rozbor zad n¡ portu
         jc        Instal4                  ; vstupn¡ port nezad n

         mov       di,offset OutPort+KORIG  ; v˜stupn¡ port
         call      RozbPort                 ; rozbor zad n¡ portu
         jc        Chyba0                   ; port nezad n
         jmp       Inst                     ; instalace programu

; ------ po‘adavek odinstalov n¡ programu

Instal4: call      RozbChr                  ; na‡ten¡ znaku
         jc        Instal5                  ; nen¡ dal¨¡ znak

         cmp       al,"!"                   ; odinstalov n¡ ?
         jne       Chyba0                   ; chybn‚ parametry
         jmp       OdInst                   ; odinstalov n¡ programu

; ------ nen¡ nic zad no - zobrazen¡ stavu

Instal5: test      byte ptr ds:[InstPar],bit0 ; je nainstalov n ?
         jz        Chyba0                   ; nen¡ nainstalov n - chyba
         call      DispStav                 ; zobrazen¡ stavu
         int       20h

Chyba0:  mov       dx,offset HelpTxt        ; chybov‚ hl ¨en¡
Chyba:   call      DispTxt                  ; zobrazen¡ chyby
Konec:   int       20h

; -----------------------------------------------------------------------------
;        instalace programu
; -----------------------------------------------------------------------------

Inst:    call      DispStav                 ; zobrazen¡ aktu ln¡ho stavu
         test      byte ptr ds:[InstPar],bit0 ; je ji‘ nainstalov n ?
         jnz       Konec                    ; je ji‘ nainstalov n

; ------ hl ¨en¡ o nainstalov n¡

         mov       dx,offset InstTxt
         call      DispTxt                  ; hl ¨en¡ o nainstalov n¡

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

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ instalace programu

         mov       dx,offset RezEnd+KORIG   ; konec rezidentn¡ho modulu
         int       27h                      ; instalace do pamˆti

; -----------------------------------------------------------------------------
;        zobrazen¡ stavu programu (ES=rezidentn¡ segment)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

; ------ vstupn¡ port

         mov       dx,offset VstupTxt
         call      DispTxt

         mov       al,byte ptr es:[InpPort+KORIG+2] ; ozna‡en¡ vstupn¡ho portu
         mov       ds:[COMTxt1],al          ; ozna‡en¡ vstupn¡ho portu
         mov       dx,offset COMTxt         ; port plat¡
         cmp       al,"0"                   ; je port platn˜ ?
         jne       DispStv2                 ; port je platn˜ OK
         mov       dx,offset NicTxt
DispStv2:call      DispTxt                  ; zobrazen¡ vstupn¡ho portu

; ------ v˜stupn¡ port

         mov       dx,offset VystTxt
         call      DispTxt

         mov       al,byte ptr es:[OutPort+KORIG+2] ; ozna‡en¡ v˜stupn¡ho portu
         mov       ds:[COMTxt1],al          ; ozna‡en¡ v˜stupn¡ho portu
         mov       dx,offset COMTxt         ; port plat¡
         cmp       al,"0"                   ; je port platn˜ ?
         jne       DispStv4                 ; port je platn˜ OK
         mov       dx,offset NicTxt
DispStv4:call      DispTxt                  ; zobrazen¡ v˜stupn¡ho portu

; ------ ‡as posledn¡ho p©¡jmu

         mov       al,es:[HodinaL+KORIG]    ; hodina p©¡jmu
         cmp       al,-1
         je        DispStv9                 ; nebyl p©¡jem

         aam
         or        ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt0],ax ; hodina p©¡jmu

         mov       al,es:[MinutaL+KORIG]    ; minuta p©¡jmu
         aam
         or        ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt0+3],ax ; minuta p©¡jmu

         mov       al,es:[SekundaL+KORIG]    ; sekunda p©¡jmu
         aam
         or        ax,"00"
         xchg      al,ah
         mov       word ptr ds:[LastTxt0+6],ax ; sekunda p©¡jmu

DispStv9:mov       dx,offset LastTxt        ; posledn¡ p©ijat˜ ‡as
         call      DispTxt
         ret

DispStav ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu (ES=rezidentn¡ segment)
; -----------------------------------------------------------------------------

; ------ test, zda je program rezidentn¡

OdInst:  mov       dx,offset NeniTxt        ; nen¡ nainstalov n
         test      byte ptr ds:[InstPar],bit0 ; je program rezidentn¡ ?
         jz        OdInst6                  ; program nen¡ rezidentn¡

; ------ test segment– INT 08h, INT 21h a INT 28h

         mov       dx,offset NelzeTxt       ; hl ¨en¡ - nelze odinstalovat
         mov       ax,es                    ; AX <- rezidentn¡ segment
         cmp       ax,word ptr ds:[Old08+KORIG+2] ; souhlas¡ INT 08h ?
         jne       OdInst6                  ; nesouhlas¡
         cmp       ax,word ptr ds:[Old21+KORIG+2] ; souhlas¡ INT 21h ?
         jne       OdInst6                  ; nesouhlas¡
         cmp       ax,word ptr ds:[Old28+KORIG+2] ; souhlas¡ INT 28h ?
         jne       OdInst6                  ; nesouhlas¡

; ------ n vrat adresy INT 08h, INT 21h a INT 28h

         push      ds
         mov       ax,2508h
         lds       dx,es:[Old08+KORIG]      ; p–vodn¡ adresa INT 08h
         int       21h                      ; n vrat adresy INT 08h
         mov       ax,2521h
         lds       dx,es:[Old21+KORIG]      ; p–vodn¡ adresa INT 21h
         int       21h                      ; n vrat adresy INT 21h
         mov       ax,2528h
         lds       dx,es:[Old28+KORIG]      ; p–vodn¡ adresa INT 28h
         int       21h                      ; n vrat adresy INT 28h
         pop       ds

; ------ zru¨en¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu programu
         mov       dx,offset DInsTxt        ; hl ¨en¡ o odinstalov n¡
OdInst6: jmp       Chyba

; -----------------------------------------------------------------------------
;        rozbor zad n¡ portu SI -> ES:DI
; -----------------------------------------------------------------------------

RozbPort PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbPrt6                 ; nen¡ znak

         mov       cl,al                    ; CL <- £schova ozna‡en¡ portu COM
         mov       ds:[NeniCOM1],al         ; ozna‡en¡ portu pro hl ¨en¡
         cmp       al,"4"
         ja        RozbPrt5                 ; nen¡ ‡¡slice
         xor       dx,dx                    ; p©i vypnut¡ portu
         sub       al,"0"
         jb        RozbPrt5                 ; nen¡ ‡¡slice
         je        RozbPrt3                 ; port vypnut

         push      ds

         mov       ah,0
         dec       ax                       ; je¨tˆ korekce ‡¡sla portu

         push      es
         push      ax                       ; AX = ‡¡slo portu 0...
         push      cx
         push      si
         push      di

         xchg      ax,dx                    ; DX <- ‡¡slo portu
         mov       ax,10000011b             ; 1200 Baud/bez parity/1 STOP/8 bit–
         int       14h                      ; nastaven¡ parametr– portu

         pop       di
         pop       si
         pop       cx
         pop       bx                       ; BX <- ‡¡slo portu
         pop       es

         shl       bx,1                     ; offset v tabulce
         mov       ax,40h
         mov       ds,ax                    ; DS <- segment BIOS
         mov       dx,ds:[bx]               ; adresa portu

         pop       ds
         or        dx,dx                    ; je port nainstalov n ?
         jnz       RozbPrt3                 ; port nen¡ nainstalov n

         mov       dx,offset NeniCOM
         jmp       Chyba                    ; chybov‚ hl ¨en¡

RozbPrt3:mov       es:[di],dx               ; adresa portu
         mov       es:[di+2],cl             ; ozna‡en¡ portu ASCII
         mov       byte ptr es:[Param+KORIG],0 ; uveden¡ obsluhy do klidu
         clc                                ; p©¡znak operace OK
         ret

RozbPrt5:dec       si                       ; n vrat neplatn‚ho znaku
         stc
RozbPrt6:ret

RozbPort ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

RozbChr1:cmp       byte ptr ds:[si],0       ; konec textu ?
         stc
         je        RozbChr3                 ; konec textu
         cld
         lodsb                              ; na‡ten¡ znaku
         cmp       al," "                   ; je mezera nebo tabul tor ?
         jbe       RozbChr1                 ; mezera nebo tabul tor se ignoruje
         cmp       al,"/"                   ; oddˆlova‡ parametr– ?
         je        RozbChr1                 ; oddˆlova‡ parametr– se ignoruje
         cmp       al,"-"                   ; oddˆlova‡ parametr– ?
         je        RozbChr1                 ; oddˆlova‡ parametr– se ignoruje
         clc                                ; p©¡znak operace OK

RozbChr3:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
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
                                            ;    bit 0: 1=program je rezidentn¡

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

ComLine  db        128 dup(?)               ; uschovan˜ p©¡kazov˜ © dek

Code     ENDS
         END       Start

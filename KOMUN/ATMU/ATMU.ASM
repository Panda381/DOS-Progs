Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

MAXBUFF  EQU       8000h                    ; velikost bufferu (16 KB)
DATBIT   EQU       10h                      ; datov˜ bit
ACKBIT   EQU       80h                      ; potvrzovac¡ bit

; ------ kontrola pamˆti

Start:   cmp       sp,offset Konec+200h     ; kontrola ukazatele z sobn¡ku
         jae       Start1

; ------ konec se zobrazen¡m textu

         mov       dx,offset MemTxt         ; chyba - nedostatek pamˆti
Chyba:   mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; ------ adresa portu LPT 1

Start1:  xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[408h]             ; adresa portu LPT 1
         mov       dx,offset PortTxt
         or        ax,ax                    ; je platn  adresa ?
         jz        Chyba                    ; chyba - nen¡ port LPT 1
         inc       ax
         mov       ds:[AdrPort],ax          ; adresa portu LPT 1

; ------ instalace videom¢du

         mov       ah,0fh
         int       10h
         cmp       al,7
         je        Start2
         mov       byte ptr cs:[SegmVRAM+1],0b8h
         cmp       al,2
         je        Start2
         cmp       al,3
         je        Start2
         mov       ax,3
         int       10h
Start2:  push      cs
         pop       ds

; ------ hl ¨en¡ - prob¡h  p©enos

         mov       dx,offset OkTxt
         mov       ah,9
         int       21h

; ------ £schova vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es ; £schova adresy INT 09h

; ------ instalace INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h                      ; instalace INT 09h

; ------ £schova registru masky p©eru¨en¡

         in        al,[21h]                 ; registr masky p©eru¨en¡
         mov       ds:[OldMask],al          ; £schova masky p©eru¨en¡

; ------ z kaz p©eru¨en¡ od hodin

         mov       al,not 2                 ; p©eru¨en¡ pouze od kl vesnice
         out       [21h],al                 ; z kaz p©eru¨en¡

; -----------------------------------------------------------------------------
;        p©¡jem dat
; -----------------------------------------------------------------------------

; ------ p©¡prava registr–

         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       cx,MAXBUFF               ; maxim ln¡ velikost dat
         mov       di,offset Buffer         ; buffer
         xor       si,si
         mov       dx,ds:[AdrPort]          ; adresa portu
         cld

; ------ ‡ek n¡ na zah jen¡ p©enosu

Prijem1: sti
         test      byte ptr ds:[Param],1    ; je p©eru¨en¡ programu ?
         jnz       Prijem9                  ; je p©eru¨en¡ programu
         in        al,dx
         and       al,ACKBIT+DATBIT
         cmp       al,DATBIT
         jne       Prijem1                  ; ‡ek n¡ na £vod dat
         in        al,dx
         and       al,ACKBIT+DATBIT
         cmp       al,DATBIT
         jne       Prijem1                  ; ‡ek n¡ na £vod dat

; ------ ‡ek n¡ na start bit

         mov       bl,8                     ; po‡et bit–
Prijem3: sti
         test      byte ptr ds:[Param],1    ; je p©eru¨en¡ programu ?
         jnz       Prijem9                  ; je p©eru¨en¡ programu
         in        al,dx
         mov       bh,al
         test      al,ACKBIT
         jz        Prijem3
         in        al,dx
         cmp       al,bh
         jne       Prijem3

; ------ ‡ten¡ dat

         and       al,DATBIT                ; datov˜ bit
         shr       ah,1                     ; rotace st©ada‡e
         shl       al,1
         shl       al,1
         shl       al,1
         or        ah,al                    ; p©id n¡ nov‚ho bitu

; ------ ulo‘en¡ bajtu

         dec       bl                       ; posun ‡¡ta‡e bit–
         jnz       Prijem4                  ; nejsou je¨tˆ v¨echny bity
         mov       al,ah
Prijem5: stosb                              ; ulo‘en¡ bajtu

         push      es
         mov       es,ds:[SegmVRAM]
         mov       es:[si],al
         pop       es

         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e dat
         jz        Prijem9                  ; buffer je pln˜

         mov       bl,8                     ; nov˜ stav ‡¡ta‡e dat

         cmp       al,0dh
         mov       al,0ah
         je        Prijem5

; ------ ‡ek n¡ na stop bit

Prijem4: sti
         test      byte ptr ds:[Param],1    ; je p©eru¨en¡ programu ?
         jnz       Prijem9                  ; je p©eru¨en¡ programu
         in        al,dx
         mov       bh,al
         test      al,ACKBIT
         jnz       Prijem4
         in        al,dx
         cmp       al,bh
         jne       Prijem4
         jmp       short Prijem3            ; dal¨¡ bit

Prijem9: sub       di,offset Buffer
         mov       ds:[BufferN],di

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu
; -----------------------------------------------------------------------------

; ------ n vrat adresy INT 09h

         cli
         push      ds
         lds       dx,ds:[Old09]            ; p–vodn¡ adresa INT 09h
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h
         pop       ds

; ------ n vrat registru p©eru¨en¡

         mov       al,ds:[OldMask]          ; p–vodn¡ registr masky p©eru¨en¡
         out       [21h],al                 ; n vrat registru masky p©eru¨en¡
         sti                                ; povolen¡ p©eru¨en¡

; ------ zru¨en¡ kl vesy z bufferu

         mov       ah,1
         int       16h
         jz        DeInit1
         mov       ah,0
         int       16h

; ------ ‡ten¡ hodin syst‚mov‚ho ‡asu (AT)

DeInit1: mov       dl,8ah                   ; p©ednastaven¡ na nesmysl
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

; ------ od© dkov n¡ textu

DeInit3: push      cs
         pop       ds
         mov       dx,offset CrTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ od© dkov n¡ textu

; -----------------------------------------------------------------------------
;        Ulo‘en¡ dat do souboru
; -----------------------------------------------------------------------------

; ------ kontrola, zda jsou nˆjak  data

         cmp       word ptr ds:[BufferN],0  ; jsou nˆjak  data ?
         jne       Uloz1                    ; jsou nˆjak  data
         mov       dx,offset PrerTxt
Chyb1:   jmp       Chyba                    ; chyba - nejsou data

; ------ vytvo©en¡ souboru

Uloz1:   mov       dx,offset Soubor
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ souboru
Uloz2:   mov       dx,offset WritTxt
         jc        Chyb1                    ; chyba z pisu do souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ z pis dat do souboru

         mov       dx,offset Buffer
         mov       cx,ds:[BufferN]          ; po‡et bajt–
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         jc        Uloz2
         cmp       ax,cx
         jb        Uloz2                    ; nesouhlas¡ po‡et bajt–

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

; ------ konec programu

         mov       ax,4c00h
         int       21h

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
;        obsluha INT 09h
; -----------------------------------------------------------------------------

Int09    PROC      FAR

         push      ax
         in        al,[60h]
         test      al,80h                   ; je stisk kl vesy ?
         jnz       Int092                   ; nen¡ stisk kl vesy
         or        byte ptr cs:[Param],1    ; p©¡znak p©eru¨en¡ programu
Int092:  pop       ax
         jmp       dword ptr cs:[Old09]

Int09    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Param    db        0                        ; parametry
                                            ;   bit 0: 1=p©¡znak p©eru¨en¡
AdrPort  dw        0                        ; adresa portu LPT 1
Old09    dd        0                        ; p–vodn¡ adresa INT 09h
OldMask  db        0                        ; p–vodn¡ maska registru p©eru¨en¡
BufferN  dw        0                        ; ‡¡ta‡ bajt– v bufferu
SegmVRAM dw        0b000h                   ; segment videopamˆti

MemTxt   db        'Nedostatek pameti !',13,10,'$'
PortTxt  db        'Neni nainstalovan port LPT1 !'
CrTxt    db        13,10,'$'
OkTxt    db        'Zvolte funkci TISK. Ukonceni prenosu stiskem libovolne klavesy... $'
PrerTxt  db        'Program prerusen bez preneseni dat !',13,10,'$'
WritTxt  db        'Chyba zapisu do souboru ATMU.DAT !',13,10,'$'

Soubor   db        'ATMU.DAT',0             ; jm‚no souboru

Buffer   db        MAXBUFF dup(?)           ; buffer pro p©¡jem dat
Konec    label     byte

Code     ENDS
         END       Start

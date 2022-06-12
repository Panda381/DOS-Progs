
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ test, zda je videokarta EGA nebo VGA

         mov       ah,12h
         mov       bx,5610h
         int       10h
         mov       dx,offset CardTxt
         cmp       bh,1
         ja        Chyba00
         cmp       bl,3
         ja        Chyba00

; ------ dek¢dov n¡ p©¡kazov‚ho © dku

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
Start01: jcxz      Start07
         cld
         lodsb
         dec       cx
         cmp       al," "
         jbe       Start01
         cmp       al,"/"
         je        Start01

         cmp       al,"a"
         jb        Start02
         cmp       al,"z"
         ja        Start02
         sub       al,32

Start02: cmp       al,"B"
         jne       Start03
         mov       byte ptr ds:[Format],0
         jmp       short Start01

Start03: cmp       al,"H"
         jne       Start04
         mov       byte ptr ds:[Format],1
         jmp       short Start01

Start04: cmp       al,"D"
         jne       Start08
         mov       byte ptr ds:[Format],2
         jmp       short Start01

Start05:


Start07: cmp       byte ptr ds:[Format],2
         jbe       Start09

Start08: mov       dx,offset HelpTxt
Chyba00: jmp       Chyba


; ------ kontrola pamˆti

Start09: mov       dx,offset MemTxt
         cmp       sp,offset Buffer + 256*32 + 200h ; kontrola pamˆti
         jb        Chyba00                  ; nedostatek pamˆti

; ------ po‡et linek na znak

         xor       ax,ax
         mov       es,ax
         mov       al,es:[485h]             ; po‡et linek na znak
         mov       ds:[Linek],ax            ; po‡et linek na znak
         or        ax,ax
         jz        Start9
         cmp       al,32
         ja        Start9

; ------ kontrola, zda je textov˜ videom¢d

         mov       al,es:[449h]             ; aktu ln¡ videom¢d
         and       al,7fh                   ; zru¨en¡ p©¡znaku nemaz n¡ displeje
         mov       ah,0eh                   ; registr mapov n¡ pro CGA
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         jbe       Start1                   ; je textov˜ m¢d CGA - OK
         cmp       al,85                    ; videom¢d "Paradise VGA" ?
         je        Start1                   ; textov˜ videom¢d OK
         cmp       al,7                     ; je videom¢d MDA ?
         jne       Start9                   ; nen¡ textov˜ videom¢d
         mov       ah,0ah                   ; registr mapov n¡ pro MDA
Start1:  mov       ds:[RegMap],ah           ; £schova registru pro mapov n¡

; ------ nastaven¡ ©adi‡e do pomocn‚ho m¢du

         call      InitRegF                 ; inicializace pro fonty

; ------ p©enos fontu do bufferu

         push      ds
         pop       es
         push      ds
         mov       ax,0a000h
         mov       ds,ax                    ; segment videopamˆti
         xor       si,si
         mov       di,offset Buffer         ; buffer k £schovˆ fontu
         mov       cx,256*32                ; velikost tabulky fontu
         cld
         rep       movsb                    ; p©enos fontu
         pop       ds

; ------ n vrat video©adi‡e

         call      InitRegT                 ; inicializace pro textov˜ videom¢d

; ------ p©¡prava ‡¡sla souboru

         mov       al,byte ptr ds:[Linek]
         aam
         add       ax,"00"
         xchg      ah,al
         mov       word ptr ds:[Soubor0],ax

; ------ vytvo©en¡ souboru

         mov       dx,offset Soubor
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ souboru
         jc        ChybaW
         mov       bx,ax                    ; identifik tor souboru

; ------ v˜stup fontu do souboru

         call      WritFont                 ; z pis fontu
         call      WritBuff                 ; vypr zdnˆn¡ bufferu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

         mov       byte ptr ds:[Soubor1],"."
         mov       dx,offset OutTxt
         mov       ah,9
         int       21h

Start9:  int       20h

; ------ chyba

ChybaW:  mov       dx,offset WritTxt
Chyba:   mov       ah,9
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;     Inicializace registr– videokarty na re‘im ‡ten¡ font–
; -----------------------------------------------------------------------------

InitRegF PROC      NEAR

         mov       cx,4                     ; nastaven¡ mapov n¡ pro fonty
         mov       bx,207h                  ; BH=rovina, BL=prokl d n¡
         jmp       short InitReg            ; inicializace registr–

InitRegF ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty na textov˜ videom¢d
; -----------------------------------------------------------------------------

InitRegT PROC      NEAR

         mov       cl,ds:[RegMap]           ; registr pro mapov n¡
         mov       ch,10h
         mov       bx,003h                  ; BH=rovina, BL=prokl d n¡

InitRegT ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr– videokarty
; -----------------------------------------------------------------------------
; VSTUP: BH=nastaven¡ roviny pro ‡ten¡
;        BL=nastaven¡ prokl d n¡
;        CL=nastaven¡ mapov n¡
;        CH=registr m¢du
; -----------------------------------------------------------------------------
; zni‡en‚ registry: AX, DX
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ nastav. prokl d n¡ bajt– sud /lich 

         mov       dx,3c4h                  ; b zov  adresa 03c4h
         mov       al,4
         out       dx,al
         inc       dx
         mov       al,bl                    ; prokl d n¡
         out       dx,al                    ; nastaven¡ prokl d n¡ bajt–

; ------ nastaven¡ mapov n¡ videopamˆti

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         out       dx,al
         inc       dx
         mov       al,cl                    ; nastaven¡ mapov n¡
         out       dx,al                    ; registr 6: mapov n¡ videopamˆti

; ------ nastaven¡ registru m¢du

         dec       dx
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,ch                    ; registr m¢du
         out       dx,al

; ------ volba roviny pro ‡ten¡

         dec       dx
         mov       al,4
         out       dx,al
         inc       dx
         mov       al,bh                    ; rovina ke ‡ten¡
         out       dx,al                    ; nastaven¡ roviny ke ‡ten¡
         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;        z pis fontu do souboru (BX=identifik tor)
; -----------------------------------------------------------------------------

WritFont PROC      NEAR

         cmp       byte ptr ds:[Format],0
         je        WritFn04
         mov       al,5                     ; po‡et pozic na bajt HEX
         cmp       byte ptr ds:[Format],1
         je        WritFn02
         mov       al,4                     ; po‡et pozic na bajt DEK
WritFn02:mul       byte ptr ds:[Linek]      ; po‡et pozic na znak
         add       ax,19                    ; po‡et pozic na DB
         cmp       ax,44
         jbe       WritFn04
         mov       byte ptr ds:[CommPoz],al ; pozice koment ©e

WritFn04:
         mov       si,offset Buffer
         mov       dx,256
WritFnt1:push      si
         mov       cx,ds:[Linek]            ; po‡et linek na znak

; ------ dek¢dov n¡ znaku v HEX a DEk m¢du

         cmp       byte ptr ds:[Format],0   ; BIN form t ?
         je        WritFnt6
         call      WritDB
WritFnt2:cld
         lodsb
         cmp       byte ptr ds:[Format],2
         je        WritFnt3
         call      WritHex
         jmp       short WritFnt4
WritFnt3:call      WritNum
WritFnt4:dec       cx
         jz        WritFnt5
         mov       al,","
         call      WritByte
         jmp       short WritFnt2
WritFnt5:call      WritCom
         jmp       short WritFnt8

; ------ dek¢dov n¡ znaku v Bin rn¡m m¢du

WritFnt6:cld
         lodsb
         call      WritBin
         call      WritCom                  ; zobrazen¡ koment ©e
         call      WritCr
         dec       cx
         jz        WritFnt8
WritFnt7:cld
         lodsb
         call      WritBin
         call      WritCR
         loop      WritFnt7

; ------ p©¡prava pro dal¨¡ znak

WritFnt8:call      WritCR
         pop       si
         add       si,32
         dec       dx
         jnz       WritFnt1
         ret

WritFont ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu AL v HEX m¢du
; -----------------------------------------------------------------------------

WritHex  PROC      NEAR

         cmp       al,9
         jbe       WritNum                  ; bude dekadick‚ ‡¡slo

         push      ax

         cmp       al,9fh
         jbe       WritHex2

         push      ax
         mov       al,"0"
         call      WritByte
         pop       ax

WritHex2:push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      WritHx
         pop       ax
         call      WritHx

         mov       al,"h"
         call      WritByte

         pop       ax
         ret

WritHex  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku HEX
; -----------------------------------------------------------------------------

WritHx   PROC      NEAR

         push      ax
         and       al,0fh
         cmp       al,9
         jbe       Writhx2
         add       al,7
WritHx2: add       al,"0"
         call      WritByte
         pop       ax
         ret

WritHx   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AL
; -----------------------------------------------------------------------------

WritNum  PROC      NEAR

         push      ax
         push      cx
         push      dx

         xor       cx,cx
WritNm1: mov       ah,0
         mov       dl,10
         div       dl
         add       ah,"0"
         push      ax
         inc       cx
         or        al,al
         jnz       WritNm1

WritNm2: pop       ax
         mov       al,ah
         call      WritByte
         loop      WritNm2

         pop       dx
         pop       cx
         pop       ax
         ret

WritNum  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice tabel toru AL
; -----------------------------------------------------------------------------

WritTab  PROC      NEAR

         push      ax
         push      cx

         mov       ch,0
         mov       cl,al                    ; po‘adovan  pozice
         sub       cl,ds:[Pozice]           ; chybˆj¡c¡ po‡et pozic
         jbe       WritTab2                 ; je ji‘ za pozic¡

         mov       al," "
WritTab1:call      WritByte
         loop      WritTab1

WritTab2:pop       cx
         pop       ax
         ret

WritTab  ENDP

; -----------------------------------------------------------------------------
;        z pis konec © dku CR/LF
; -----------------------------------------------------------------------------

WritCR   PROC      NEAR

         push      ax
         mov       al,13
         call      WritByte
         mov       al,10
         call      WritByte
         pop       ax
         ret

WritCr   ENDP

; -----------------------------------------------------------------------------
;        z pis jednoho bajtu BIN
; -----------------------------------------------------------------------------

WritBin  PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       cx,8
         mov       dl,al                    ; bajt

         call      WritDb                   ; z pis textu "DB"

WritBin1:mov       al,"0"
         shl       dl,1
         jnc       WritBin2
         inc       ax
WritBin2:call      WritByte
         loop      WritBin1

         mov       al,"b"
         call      WritByte

         pop       dx
         pop       cx
         pop       ax
         ret

WritBin  ENDP

; -----------------------------------------------------------------------------
;        z pis textu "DB"
; -----------------------------------------------------------------------------

WritDB   PROC      NEAR

         push      ax
         mov       al,9
         call      WritTab
         mov       al,"d"
         call      WritByte
         mov       al,"b"
         call      WritByte
         mov       al,19
         call      WritTab
         pop       ax
         ret

WritDB   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ koment ©e (DL=‡¡ta‡ znak– k zobrazen¡)
; -----------------------------------------------------------------------------

WritCom  PROC      NEAR

         push      ax

         mov       al,ds:[CommPoz]          ; pozice koment ©e
         call      WritTab
         mov       al,";"
         call      WritByte
         mov       al," "
         call      WritByte

         mov       al,0
         sub       al,dl
         call      WritNum
         cmp       al," "
         jb        WritCom2

         push      ax
         mov       al," "
         call      WritByte
         mov       al,34
         call      WritByte
         pop       ax
         call      WritByte
         mov       al,34
         call      WritByte

WritCom2:pop       ax
         ret

WritCom  ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL do bufferu
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         push      si

         cmp       al,10
         je        WritByt4
         cmp       al,13
         jne       WritByt1
         mov       byte ptr ds:[Pozice],0ffh; pozice na © dku
WritByt1:inc       byte ptr ds:[Pozice]     ; zv˜¨en¡ ukazatele pozice

WritByt4:mov       si,ds:[OutNum]           ; po‡et bajt– v bufferu
         cmp       si,1000h
         jb        WritByt5
         call      WritBuff                 ; vypr zdnˆn¡ bufferu
         xor       si,si

WritByt5:mov       ds:[si+Buff1],al         ; vlo‘en¡ znaku do bufferu
         inc       si
         mov       ds:[OutNum],si
         pop       si
         ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu buffer do souboru
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       dx,offset Buff1
         mov       cx,ds:[OutNum]
         mov       ah,40h
         int       21h

         pop       dx
         pop       cx
         pop       ax
         ret

WritBuff ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

CommPoz  db        44                       ; pozice koment ©e
Pozice   db        0                        ; ukazatel pozice na © dku

Format   db        0ffh                     ; form t v˜stup
                                            ;   0 = bitov˜
                                            ;   1 = hexadecim ln¡
                                            ;   2 = dekadick˜

Linek    dw        0                        ; po‡et linek na znak
RegMap   db        0                        ; registr mapov n¡
OutNum   dw        0                        ; po‡et znak– ve v˜stupn¡m bufferu

UvTxt    db        'GETFONT V1.0 - sejmuti fontu z videopameti; (c) Miroslav Nemecek',13,10,'$'
CardTxt  db        'Program vyzaduje grafickou kartu EGA nebo VGA !',13,10,'$'
HelpTxt  db        'Zadejte:      B ........ bitovy format',13,10
         db        '              H ........ hexadecimalni format',13,10
         db        '              D ........ dekadicky format',13,10
         db        '$'


WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
MemTxt   db        'Nedostatek pameti !',13,10,'$'

OutTxt   db        'Font zapsan do souboru '
Soubor   db        'FONT'                   ; jm‚no souboru
Soubor0  db        'xx.ASM'
Soubor1  db        0
         db        13,10,'$'

Buff1    db        1000h dup(?)             ; v˜stupn¡ buffer

Buffer   label     byte                     ; buffer k £schovˆ fontu

Code     ENDS
         END       Start

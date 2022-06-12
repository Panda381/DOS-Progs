
KLICAX   EQU       'UN'
KLICBX   EQU       'PA'
KLICCX   EQU       'RK'
KLICDX   EQU       '10'
KLICOK   EQU       'OK'

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal

Old13    dd        0                        ; p–vodn¡ adresa INT 13h
Old16    dd        0                        ; p–vodn¡ adresa INT 16h

Disk     db        -1
Doba     dw        -1                       ; po‘adovan  doba odparkov v n¡

OldTime  dw        0                        ; uschovan˜ ‡as p©¡stupu

; -----------------------------------------------------------------------------
;        obsluha INT 13h
; -----------------------------------------------------------------------------

Int13    PROC      FAR

         pushf
         cmp       dl,cs:[Disk]
         jne       Int131
         cmp       ah,2
         jb        Int131
         cmp       ah,4
         ja        Int131

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         mov       word ptr cs:[OldTime],ax
         pop       ds
         pop       ax

Int131:  popf
         jmp       dword ptr cs:[Old13]

Int13    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 16h
; -----------------------------------------------------------------------------

Int16    PROC      FAR

         pushf
         cmp       ax,KLICAX
         jne       Int161
         cmp       bx,KLICBX
         jne       Int161
         cmp       cx,KLICCX
         jne       Int161
         cmp       dx,KLICDX
         jne       Int161
         mov       ax,KLICOK
         push      cs
         pop       es
         popf
         iret

Int161:  cmp       word ptr cs:[Doba],0
         je        Int163                   ; vypnuto
         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         sub       ax,cs:[OldTime]
         cmp       ax,cs:[Doba]
         pop       ds
         pop       ax
         jb        Int163

         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         xor       bx,bx
         mov       es,bx
         mov       ch,es:[46ch]
         mov       ax,401h
         mov       cl,1
         mov       dh,0
         mov       dl,cs:[Disk]
         int       13h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf

Int163:  cmp       ah,0
         jne       Int164

         mov       ah,1
         pushf
         call      dword ptr cs:[Old16]
         mov       ah,0
         jz        Int161

Int164:  popf
         jmp       dword ptr cs:[Old16]

Int16    ENDP

; -----------------------------------------------------------------------------
;        start a instalace programu
; -----------------------------------------------------------------------------

; ------ zobrazen¡ £vodn¡ho textu

Instal:  mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ test, zda je ji‘ nainstalov n

         mov       ax,KLICAX
         mov       bx,KLICBX
         mov       cx,KLICCX
         mov       dx,KLICDX
         int       16h
         cmp       ax,KLICOK
         je        Instal1
         push      cs
         pop       es

; ------ p©¡prava p©¡kazov‚ho © dku

Instal1: mov       si,81h
         mov       bl,ds:[si-1]
         mov       bh,0
         mov       ds:[si+bx],bh
         cld

; ------ vypu¨tˆn¡ mezer

Instal2: lodsb
         cmp       al," "
         je        Instal2
         cmp       al,":"
         je        Instal2
         cmp       al,"/"
         je        Instal2
         jb        Instal6
         or        al,20h

; ------ disk C:

         cmp       al,"c"
         jne       Instal3
         mov       byte ptr es:[Disk],80h
         jmp       short Instal2

; ------ disk D:

Instal3: cmp       al,"d"
         jne       Instal4
         mov       byte ptr es:[Disk],81h
         jmp       short Instal2

; ------ ‡¡slo

Instal4: sub       al,"0"
         jb        Chyba
         cmp       al,9
         ja        Chyba

         mov       ah,0
         xchg      ax,cx
         mov       ax,10
         mul       word ptr ds:[DobaZad]
         add       ax,cx
         mov       ds:[DobaZad],ax
         mov       cl,18
         mul       cx
         mov       es:[Doba],ax
         jmp       short Instal2

; ------ test, zda byl zad n ‡as i disk

Instal6: cmp       word ptr es:[Doba],-1
         je        Chyba
         mov       al,es:[Disk]
         add       al,"C"-80h
         mov       ds:[HlasTxt0],al
         cmp       byte ptr es:[Disk],-1
         jne       Instal7

; ------ chyba - zobrazen¡ n povˆdy

Chyba:   mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         int       20h

; ------ zobrazen¡ hl ¨en¡

Instal7: mov       dx,offset HlasTxt
         mov       ah,9
         int       21h

; ------ zobrazen¡ doby odparkov v n¡

         mov       ax,es:[Doba]
         mov       dx,offset HlasTxt2
         or        ax,ax
         jz        Instal9
         xor       dx,dx
         mov       bx,18
         div       bx
         xor       cx,cx
         mov       bx,10
Instal8: xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       Instal8

Instl82: pop       dx
         add       dl,"0"
         mov       ah,2
         int       21h
         loop      Instl82

         mov       dx,offset HlasTxt1
Instal9: mov       ah,9
         int       21h                      ; zbytek hl ¨en¡

; ------ test, zda m  b˜t instalace

         mov       ax,es
         mov       bx,cs
         cmp       ax,bx
         je        InstalA
         int       20h

; ------ hl ¨en¡ o instalaci

InstalA: mov       dx,offset InstTxt
         mov       ah,9
         int       21h

; ------ £schova INT 13h

         mov       ax,3513h
         int       21h
         mov       word ptr ds:[Old13],bx
         mov       word ptr ds:[Old13+2],es

; ------ £schova INT 16h

         mov       ax,3516h
         int       21h
         mov       word ptr ds:[Old16],bx
         mov       word ptr ds:[Old16+2],es

; ------ instalace INT 13h

         mov       ax,2513h
         mov       dx,offset Int13
         int       21h

; ------ instalace INT 16h

         mov       ax,2516h
         mov       dx,offset Int16
         int       21h

; ------ instalace do pamˆti

         mov       dx,offset Instal
         int       27h

UvTxt    db        'UNPARK V1.0 - odparkovavani disku; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte:  cislo ....... doba pro odparkovavani v sekundach (0=vypnuto)',13,10
         db        '          C nebo D .... odparkovavani disku C nebo D',13,10
         db        '$'

DobaZad  dw        0                        ; zadan  doba

InstTxt  db        ' Program byl nainstalovan do pameti.',13,10,'$'
HlasTxt  db        ' Doba odparkovavani disku '
HlasTxt0 db        'C: $'
HlasTxt1 db        ' sekund.',13,10,'$'
HlasTxt2 db        '- vypnuto.',13,10,'$'

Code     ENDS
         END       Start

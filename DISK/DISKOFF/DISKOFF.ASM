
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

IDENTAX  EQU       'D' + 2bh*256
IDENTBX  EQU       'IS'
IDENTCX  EQU       'KO'
IDENTDX  EQU       'FF'

IDENTOK  EQU       'OK'

Start:   jmp       Instal

Old21    dd        0                        ; p–vodn¡ adresa INT 21h

DiskTab  db        32 dup (0)               ; 1=zak zan˜ disk

; -----------------------------------------------------------------------------
;        obsluha INT 21h
; -----------------------------------------------------------------------------

Int21    PROC      FAR

; ------ test instalace rezidentn¡ho modulu

         pushf
         cmp       ax,IDENTAX
         jne       Int211
         cmp       bx,IDENTBX
         jne       Int211
         cmp       cx,IDENTCX
         jne       Int211
         cmp       dx,IDENTDX
         jne       Int211
         mov       bx,IDENTOK
         mov       cx,cs
         mov       al,0ffh
         popf
         iret

; ------ funkce nastaven¡ disku

Int211:  cmp       ah,0eh
         jne       Int213
         cmp       dl,32
         jae       Int213
         push      bx
         mov       bh,0
         mov       bl,dl                    ; po‘adovan˜ disk
         cmp       byte ptr cs:[bx+DiskTab],0
         pop       bx
         je        Int213                   ; disk voln˜

         mov       ah,19h
;         pushf
         call      dword ptr cs:[Old21]     ; poskytnut¡ aktivn¡ho disku

         push      dx
         mov       dl,al                    ; DL <- aktivn¡ disk
         mov       ah,0eh
         pushf
         call      dword ptr cs:[Old21]     ; nastaven¡ aktivn¡ho disku
         pop       dx
         iret

Int213:  popf
Int219:  jmp       dword ptr cs:[Old21]

Int21    ENDP

; -----------------------------------------------------------------------------
;        start a instalace
; -----------------------------------------------------------------------------

; ------ £vodn¡ text

Instal:  mov       ah,9
         mov       dx,offset UvText
         int       21h

; ------ rozbor zad n¡ disk–

         mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0

; ------ nalezen¡ za‡ tku parametr–

         cld
Instal1: jcxz      Chyba
         lodsb
         dec       cx
         cmp       al," "
         je        Instal1

; ------ konverze na velk‚ p¡smeno

Instal2: cmp       al,"a"
         jb        Instal3
         cmp       al,"z"
         ja        Instal3
         sub       al,32

; ------ test, zda je platn˜ disk

Instal3: sub       al,"A"
         jc        Chyba
         cmp       al,32
         ja        Chyba

; ------ nastaven¡ p©¡znaku disku

         mov       ah,0
         xchg      ax,bx
         or        byte ptr ds:[bx+DiskTab],1

; ------ dal¨¡ znak

Instal4: jcxz      Instal5
         lodsb
         dec       cx
         cmp       al," "
         je        Instal4
         jmp       short Instal2

; ------ chyba - nen¡ nic zad no

Chyba:   mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         int       20h

; ------ test, zda je program nainstalov n

Instal5: mov       ax,IDENTAX
         mov       bx,IDENTBX
         mov       cx,IDENTCX
         mov       dx,IDENTDX
         int       21h
         mov       ax,ds
         cmp       ax,cx
         je        Instal6
         cmp       bx,IDENTOK
         je        Instal7

; ------ zobrazen¡ hl ¨en¡

Instal6: mov       dx,offset InstTxt
         mov       ah,9
         int       21h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]
         mov       ah,49h
         int       21h

; ------ adresa INT 21h

         mov       ax,3521h
         int       21h
         mov       word ptr ds:[Old21],bx
         mov       word ptr ds:[Old21+2],es

; ------ instalace INT 21h

         mov       ax,2521h
         mov       dx,offset Int21
         int       21h

; ------ instalace do pamˆti

         mov       dx,offset Instal
         int       27h

; ------ p©enesen¡ do rezidentn¡ho modulu

Instal7: mov       es,cx
         mov       si,offset DiskTab
         mov       di,si
         mov       cx,32
         cld
         rep       movsb

; ------ hl ¨en¡

         mov       dx,offset AktTxt
         mov       ah,9
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvText   db        'DISKOFF V1.0 - uzamykani disku; (c) Miroslav Nemecek',13,10,'$'
InstTxt  db        ' Program nainstalovan do pameti.',13,10,'$'
HelpTxt  db        'Zadejte seznam uzamcenych disku (pismena A az Z, [ az `)',13,10,'$'
AktTxt   db        ' Nastaveni disku aktualizovano.',13,10,'$'

Code     ENDS
         END       Start

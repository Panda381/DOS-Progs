
code     segment
         assume    cs:code,ds:code
         org       100h

MaxBuf   equ       2000h

start:

; ------ otev�en� vstupn�ho souboru

         mov       ax,3d00h
         mov       dx,offset soubor1
         int       21h
         jc        chyba
         mov       ds:[ident1],ax

; ------ otev�en� v�stupn�ho souboru

         mov       ah,3ch
         xor       cx,cx
         mov       dx,offset soubor2
         int       21h
         mov       ds:[ident2],ax
         jnc       start1

; ------ chyba

chyba:   mov       dx,offset errtxt
chyba2:  mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h



; ------ na�ten� prvn�ho znaku k�du ESC

start1:  call      Move1                    ; p�enos 1 bajtu
         cmp       al,27                    ; je ESC ?
         jne       start1                   ; nen� ESC

; ------ na�ten� druh�ho znaku k�du

         call      Move1                    ; p�enos druh�ho znaku

; ------ je prav� z�vorka (bude popisova� fontu)

         cmp       al,")"
         jne       start3

; ------ o�ek�v� se znak "s"

         call      Move1
         cmp       al,"s"
         jne       start6

; ------ p�enos ��sla

         call      Cislo                    ; p�enos ��sla
         cmp       dx,28                    ; minim�ln� velikost
         jb        start1

; ------ o�ek�v� se znak "W"

         cmp       al,"W"
         jne       start1

; ------ p�esko�en� prvn� ��sti parametr�

         mov       cx,12
         call      Move

; ------ n�hrada p��znaku LANDSCAPE p��znakem PORTRAIT

         call      read
         mov       al,0                     ; n�hrada portrait
         call      write

; ------ p�esko�en� zbyl�ch znak�

         mov       cx,dx
         sub       cx,13
         call      move
         jmp       short start1             ; dal�� k�d



; ------ ostatn� k�dy - pouze se p�enesou

start5:  call      move1                    ; identifikace parametru k�du
start6:  call      cislo                    ; p�enos ��sla a koncov�ho znaku
start9:  jmp       start1



; ------ je znak "(" - bude definice znaku

start3:  cmp       al,"("
         jne       start4

; ------ o�ek�v� se znak "s"

         call      Move1
         cmp       al,"s"
         jne       start6

; ------ �ten� ��sla

         call      CisloI                   ; p�enos ��sla

; ------ o�ek�v� se znak "W"

         cmp       al,"W"
         jne       start4a

; ------ na�ten� definice znaku

         mov       cx,dx                    ; d�lka definice znaku
         mov       di,offset znak           ; za��tek bufferu k ulo�en� definice
         call      readb                    ; na�ten� definice znaku
         mov       word ptr ds:[buffer2],offset buffer ; p�ednastaven� dat znaku
         call      Korig                    ; korekce nulov� velikosti znaku

; ------ kontrola, zda se m� prov�st konverze

         cmp       byte ptr ds:[Znakori],1  ; je landscape ?
         jne       start49                  ; nen� landscape
         mov       ds:[buffer2],di          ; adresa druh� ��sti definice


; ------ konverze znaku

         call      konvert



; ------ v�po�et nov� d�lky definice znaku

start49:
         mov       ax,ds:[znaksir]          ; ���ka znaku
         xchg      ah,al                    ; oprava po�ad� bajt�
         add       ax,7                     ; zaokrouhlen� na bajt
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; po�et bajt� na linku
         mov       dx,ds:[znakvys]          ; v��ka znaku
         xchg      dh,dl                    ; oprava po�ad� bajt�
         mul       dx                       ; v�po�et d�lky definice znaku
         mov       cx,ax                    ; d�lka definice znaku

; ------ ulo�en� zbytku k�du

         mov       al,"W"
         mov       dx,cx
         add       dx,16
         call      cisloo                   ; z�pis ��sla a zbytku k�du

; ------ ulo�en� nov�ho z�hlav�

         push      cx
         mov       si,offset znak
         mov       cx,16
         call      writeb                   ; z�pis z�hlav�
         pop       cx

; ------ ulo�en� dat znaku

         mov       si,ds:[buffer2]          ; p�ek�dovan� data znaku
         call      writeb                   ; ulo�en� dat
         jmp       short start9

start4a: call      cisloo
start99: jmp       short start9

; ------ je znak "*" - bode ��slo znaku

start4:  cmp       al,"*"
         jne       start5

; ------ o�ek�v� se znak "c"

         call      Move1
         cmp       al,"c"
         jne       start6

; ------ p�enos ��sla

         call      Cislo                    ; p�enos ��sla

; ------ o�ek�v� se znak "E"

         cmp       al,"E"
         jne       start9
         mov       ds:[znakchr],dl          ; k�d znaku
         jmp       short start99



; ------ konec programu

konec:   call      writbuf                  ; z�pis v�stupn�ho bufferu na disk
         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        korekce znaku s nulovou ���kou nebo v��kou
; -----------------------------------------------------------------------------

korig:
         cmp       word ptr ds:[ZnakSir],0
         je        korig2
         cmp       word ptr ds:[ZnakVys],0
         jne       korig3

korig2:  mov       word ptr ds:[ZnakSir],100h
         mov       word ptr ds:[ZnakVys],100h
         mov       word ptr ds:[ZnakLeft],0
         mov       word ptr ds:[ZnakTop],0
         mov       byte ptr ds:[Buffer],0
korig3:  ret

; -----------------------------------------------------------------------------
;        konverze znaku
; -----------------------------------------------------------------------------

konvert:

         mov       byte ptr ds:[ZnakOri],0  ; zm�na orientace znaku

; ------ informace o konvertovan�m znaku

         mov       dl,ds:[znakchr]          ; k�d p�en��en�ho znaku
         mov       ah,2
         int       21h                      ; zobrazen� konvertovan�ho znaku

; ------ p��prava registr� ke konverzi

         mov       si,offset buffer         ; buffer s p�vodn�m znakem
         mov       di,ds:[buffer2]          ; buffer k ulo�en� nov�ho znaku
         mov       bx,ds:[znaksir]          ; sou�asn� ���ka znaku
         xchg      bh,bl                    ; oprava po�ad� bajt�
         add       bx,7                     ; zaokrouhlen� na bajty
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p��rustek adresy linky
         xor       dx,dx                    ; ��ta� linek
         cld

; ------ nastaven� na adresu posledn� linky

         mov       cx,ds:[znakvys]          ; v��ka znaku (po�et linek)
         xchg      ch,cl                    ; oprava po�ad� bajt�
         jcxz      konv8                    ; nen� co konvertovat
konv3:   add       si,bx
         loop      konv3
         sub       si,bx                    ; adresa posledn� linky

; ------ konverze znaku

         mov       cx,ds:[znaksir]          ; po�et slouc� znaku
         xchg      ch,cl
         jcxz      konv8                    ; nen� co konvertovat
konv4:   push      si
         push      cx
         mov       al,1                     ; p��znak konverze 8 bit�
         mov       cx,ds:[znakvys]          ; v��ka znaku (po�et linek)
         xchg      ch,cl                    ; oprava po�ad� bajt�
konv5:   shl       byte ptr ds:[si],1
         rcl       al,1
         jnc       konv6                    ; nen� je�t� 8 bit�
         stosb
         mov       al,1
konv6:   sub       si,bx                    ; adresa dal�� linky
         loop      konv5                    ; dal�� linka znaku
         cmp       al,1                     ; byl ulo�en posledn� bajt ?
         je        konv63                   ; posledn� bajt byl ulo�en
konv62:  shl       al,1
         jnc       konv62
         stosb                              ; ulo�en� posledn�ho bajtu
konv63:  pop       cx
         pop       si
         inc       dx
         test      dl,7
         jnz       konv7
         inc       si                       ; posun na dal�� �adu linek
konv7:   loop      konv4                    ; dal�� sloupec

; ------ oprava horn�ho a lev�ho offsetu

         mov       dx,ds:[znakleft]         ; lev� offset
         xchg      dh,dl
         mov       bx,ds:[znaktop]          ; horn� offset
         xchg      bh,bl
         neg       dx
         xchg      dh,dl
         mov       ds:[znaktop],dx          ; nov� horn� offset
         mov       ax,ds:[znakvys]          ; star� v��ka znaku
         xchg      ah,al
         sub       bx,ax                    ; v�po�et nov�ho lev�ho offsetu
         inc       bx
         xchg      bh,bl
         mov       ds:[znakleft],bx         ; nov� lev� offset

; ------ z�m�na ���ky a v��ky znaku

konv8:   mov       ax,ds:[znaksir]
         xchg      ax,ds:[znakvys]
         mov       ds:[znaksir],ax
         ret

; -----------------------------------------------------------------------------
;        p�enos ��sla
; -----------------------------------------------------------------------------
; V�STUP: AL=n�sleduj�c� znak za ��slem
;         AH=znak znam�nka
;         DX=��slo (��seln� ��st bez znam�nka)
; -----------------------------------------------------------------------------

Cislo:   xor       dx,dx                    ; p�ednastaven� ��sla

Cislo1:  call      Move1

; ------ mezera

         cmp       al," "
         je        Cislo1

; ------ znam�nko +

         cmp       al,"+"
         jne       Cislo2
         mov       ah,al
         jmp       short Cislo1

; ------ znam�nko -

Cislo2:  cmp       al,"-"
         jne       Cislo3
         mov       ah,al
         jmp       short Cislo1

; ------ ��slice

Cislo3:  cmp       al,"0"
         jb        Cislo4
         cmp       al,"9"
         ja        Cislo4

; ------ p�epo�et na ��slo

         sub       al,"0"
         push      ax
         mov       ax,10
         mul       dx
         mov       dx,ax
         pop       ax
         add       dl,al
         adc       dh,0
         jmp       short Cislo1

Cislo4:  ret

; -----------------------------------------------------------------------------
;        v�stup ��sla
; -----------------------------------------------------------------------------
; AL=koncov� znak
; DX=��slo
; -----------------------------------------------------------------------------

CisloO:

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ax,dx
         mov       bx,10
         xor       cx,cx
cisloo1: xor       dx,dx
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       cisloo1

cisloo2: pop       ax
         add       al,"0"
         call      write
         loop      cisloo2

         pop       dx
         pop       cx
         pop       bx
         pop       ax

         call      write

         ret

; -----------------------------------------------------------------------------
;        vstup ��sla
; -----------------------------------------------------------------------------
; V�STUP: AL=n�sleduj�c� znak za ��slem
;         AH=znak znam�nka
;         DX=��slo (��seln� ��st bez znam�nka)
; -----------------------------------------------------------------------------

CisloI:  xor       dx,dx                    ; p�ednastaven� ��sla

CisloI1: call      read

; ------ mezera

         cmp       al," "
         je        CisloI1

; ------ znam�nko +

         cmp       al,"+"
         jne       CisloI2
         mov       ah,al
         jmp       short CisloI1

; ------ znam�nko -

CisloI2: cmp       al,"-"
         jne       CisloI3
         mov       ah,al
         jmp       short CisloI1

; ------ ��slice

CisloI3: cmp       al,"0"
         jb        CisloI4
         cmp       al,"9"
         ja        CisloI4

; ------ p�epo�et na ��slo

         sub       al,"0"
         push      ax
         mov       ax,10
         mul       dx
         mov       dx,ax
         pop       ax
         add       dl,al
         adc       dh,0
         jmp       short CisloI1

CisloI4: ret


; -----------------------------------------------------------------------------
;        p�enos jednoho bajtu (vr�t� bajt AL)
; -----------------------------------------------------------------------------

Move1:   call      Read
         call      Write
         ret

; -----------------------------------------------------------------------------
;        p�enos dan�ho po�tu bajt� (vr�t� posledn� bajt AL)
; -----------------------------------------------------------------------------

Move:    push      cx
Move2:   call      Read
         call      Write
         loop      Move2
         pop       cx
         ret

; -----------------------------------------------------------------------------
;        z�pis bajtu na v�stup
; -----------------------------------------------------------------------------

write:   cmp       word ptr ds:[outnum],maxbuf
         jb        write2

         call      writbuf

write2:  push      bx
         mov       bx,ds:[outnum]
         mov       ds:[bx+outbuf],al
         inc       word ptr ds:[outnum]
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        z�pis v�stupn�ho bufferu
; -----------------------------------------------------------------------------

writbuf: push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,ds:[ident2]
         mov       cx,ds:[outnum]
         mov       word ptr ds:[Outnum],0
         mov       dx,offset outbuf
         mov       ah,40h
         jcxz      writbuf2
         int       21h
         jc        writbuf1
         or        ax,ax
         jnz       writbuf2
writbuf1:jmp       chyba

writbuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        z�pis CX bajt� z bufferu SI
; -----------------------------------------------------------------------------

writeb:  jcxz      writeb2
writeb1: cld
         lodsb
         call      write
         loop      writeb1
writeb2: ret

; -----------------------------------------------------------------------------
;        na�ten� CX bajt� do bufferu DI (AL=posledn� znak)
; -----------------------------------------------------------------------------

ReadB:   jcxz      Readb3
readb1:  call      read
         cld
         stosb
         loop      readb1
readb3:  ret

; -----------------------------------------------------------------------------
;        �ten� znaku z bufferu
; -----------------------------------------------------------------------------

read:    cmp       word ptr ds:[inpnum],0
         jne       read2

         call      readbuf

read2:   push      bx
         mov       bx,ds:[inpadr]
         mov       al,ds:[bx+inpbuf]
         inc       word ptr ds:[inpadr]
         dec       word ptr ds:[inpnum]
         pop       bx
         ret

; -----------------------------------------------------------------------------
;        na�ten� bufferu
; -----------------------------------------------------------------------------

readbuf: push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpadr],0
         mov       bx,ds:[ident1]
         mov       cx,maxbuf
         mov       dx,offset inpbuf
         mov       ah,3fh
         int       21h                      ; �ten�

         jnc       readbuf1
         jmp       chyba                    ; chyba �ten�

readbuf1:mov       ds:[inpnum],ax
         or        ax,ax
         jnz       readbuf2
         jmp       konec                    ; konec programu OK

readbuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

soubor1  db        'l',0
soubor2  db        'p.sfp',0

ident1   dw        0
ident2   dw        0

inpnum   dw        0
inpadr   dw        0                        ; ukazatel adresy

znakchr  db        "A"                      ; k�d konvertovan�ho znaku

outnum   dw        0

errtxt   db        'Chyba !',13,10,'$'

inpbuf   db        maxbuf dup(?)
outbuf   db        maxbuf dup(?)


buffer2  dw        ?                        ; adresa druh� ��sti definice znaku

; -----------------------------------------------------------------------------
;        definice znaku
; -----------------------------------------------------------------------------
; VAROV�N�: v�echna slova maj� zam�n�no po�ad� HIGH a LOW !!!!!
; -----------------------------------------------------------------------------

Znak     label     byte
ZnakForm db        ?                        ; form�t popisova�e (=4)
ZnakCont db        ?                        ; p��znak pokra�ov�n� popis. (=1)
ZnakSize db        ?                        ; velikost popisova�e (=14)
ZnakTyp  db        ?                        ; form�t dat znaku (=1)
ZnakOri  db        ?                        ; orientace (0=port., 1=landsc.)
         db        ?                        ; rezervov�no
ZnakLeft dw        ?                        ; lev� offset
ZnakTop  dw        ?                        ; horn� offset
ZnakSir  dw        ?                        ; ���ka znaku
ZnakVys  dw        ?                        ; v��ka znaku
ZnakInc  dw        ?                        ; p��rustek pozice (�vrt-body)

buffer   label     byte                     ; buffer znaku

code     ends
         end       start

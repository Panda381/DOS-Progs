
; *****************************************************************************
;
;                   ukl d n¡ dat pro tisk rnu do souboru
;
; *****************************************************************************

BufSize  equ       0f000h                   ; velikost diskov‚ho bufferu
BufX     EQU       06000h                   ; hranice pro ulo‘en¡ dat
TimeOut  EQU       2*18                     ; doba pro ulo‘en¡ zbytku dat



CODE     SEGMENT
         ASSUME    CS:CODE,DS:CODE
         ORG       100H

START:   jmp       instal

Aktiv21  dd        0                        ; adresa p©¡znaku aktivity DOS

Old17    dd        0
Old08    dd        0                        ; adresa p–vodn¡ obsluhy INT 08h
Old28    dd        0                        ; adresa p–vodn¡ obsluhy INT 28h

Port     dw        0                        ; port LPT

NumBuff  dw        0                        ; po‡et bajt– v diskov‚m bufferu

                                          ;* jm‚no souboru
Soubor   db        'A:\',64+14 dup(0)       ; buffer pro adres © a soubor
AdrSoub  dw        0                        ; adresa ‡¡sla souboru

CitCas   dw        0                        ; ‡¡ta‡ ‡asu od posledn¡ho znaku

AktUloz  db        0                        ; 1=p©¡znak, ‘e prob¡h  ukl d n¡

Novy     db        0                        ; 1=p©¡znak nov‚ho souboru

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

int08    PROC      FAR

         cmp       word ptr cs:[CitCas],0ffffh
         je        int081
         inc       word ptr cs:[citcas]
int081:

         pushf
         call      dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h
         call      Ukladej                  ; obsluha ukl d n¡ do souboru
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 28h
; -----------------------------------------------------------------------------

int28    PROC      FAR

         pushf
         call      dword ptr cs:[Old28]     ; p–vodn¡ obsluha INT 28h
         call      Ukladej                  ; obsluha ukl d n¡ do souboru
         iret

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 17h
; -----------------------------------------------------------------------------

Int17    PROC      FAR

         call      Ukladej                  ; obsluha ukl d n¡ do souboru

; ------ kontrola ‡¡sla portu

         cmp       dx,cs:[Port]
         jne       Int179

; ------ ulo‘en¡ znaku do bufferu

         or        ah,ah                    ; je vysl n¡ znaku ?
         jnz       Int176

; ------ nastaven¡ p©¡znaku nov‚ho souboru

         cmp       word ptr cs:[CitCas],TimeOut
         jb        Int172                   ; nen¡ nov˜ soubor
         mov       byte ptr cs:[Novy],1     ; p©¡znak nov‚ho souboru

; ------ ‡ek n¡ na vypr zdnˆn¡ bufferu

Int172:  cmp       word ptr cs:[NumBuff],BufSize ; je buffer ji‘ pln˜ ?
         jb        Int174                   ; buffer je¨tˆ nen¡ pln˜
         sti                                ; povolen¡ p©eru¨en¡
         call      Ukladej                  ; pokus o ulo‘en¡ bufferu
         cmp       word ptr cs:[CitCas],3*18 ; maxim ln¡ doba ‡ek n¡
         jb        Int172                   ; nen¡ je¨tˆ p©ete‡en¡ doby

; ------ chyba - buffer nelze ulo‘it na disk

         mov       ah,00001001b             ; chyba tisk rny
         iret

; ------ znak se m–‘e ulo‘it OK

Int174:  push      bx
         mov       bx,cs:[NumBuff]          ; po‡et znak– v bufferu
         mov       cs:[bx+Buffer],al        ; ulo‘en¡ znaku do bufferu
         inc       word ptr cs:[NumBuff]    ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         pop       bx
         mov       word ptr cs:[CitCas],0   ; nulov n¡ ‡¡ta‡e ‡asu
         jmp       short Int177             ; navr cen¡ stavu tisk rny

; ------ funkce resetov n¡ tisk rny

Int176:  cmp       ah,1
         je        Int177

; ------ funkce dotazu na stav tisk rny

         cmp       ah,2
         jne       Int179                   ; nezn m  funkce

; ------ navr cen¡ stavu tisk rny

Int177:  mov       ah,00010000b
         cmp       word ptr cs:[NumBuff],BufX ; buffer zaplnˆn ?
         jae       Int178                   ; buffer zaplnˆn
         or        ah,80h                   ; jinak tisk rna p©ipravena
Int178:  iret

; ------ p–vodn¡ obsluha tisk rny

Int179:  jmp       dword ptr cs:[Old17]

Int17    ENDP

; -----------------------------------------------------------------------------
;        Obsluha ukl d n¡ do souboru
; -----------------------------------------------------------------------------

Ukladej0:ret

Ukladej: cmp       byte ptr cs:[AktUloz],0  ; prob¡h  ji‘ ukl d n¡ ?
         jne       Ukladej0                 ; ukl d n¡ ji‘ prob¡h 

         cmp       word ptr cs:[NumBuff],0  ; je nˆco v bufferu ?
         je        Ukladej0                 ; v bufferu nic nen¡

         push      ds
         push      bx
         lds       bx,cs:[Aktiv21]          ; adresa p©¡znaku aktivity DOS
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn¡ ?
         pop       bx
         pop       ds
         jne       Ukladej0                 ; DOS je aktivn¡

         cmp       word ptr cs:[CitCas],TimeOut ; je ji‘ dlouh  doba ?
         jae       Ukladej1                 ; je ji‘ dlouh  doba
         cmp       word ptr cs:[NumBuff],BufX ; je ji‘ mnoho dat ?
         jb        Ukladej0                 ; nen¡ ani mnoho dat je¨tˆ


                                          ;* akce se provede
Ukladej1:
         mov       byte ptr cs:[AktUloz],1  ; p©¡znak operace ukl d n¡

         pushf
         sti                                ; p©eru¨en¡ povoleno
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         push      cs
         pop       ds

; ------ test, zda soubor ji‘ existuje

Ukladej3:mov       dx,offset Soubor
         mov       ax,3d01h                 ; funkce otev©en¡ souboru
         int       21h                      ; pokus o otev©en¡ souboru
         jc        Ukladej4                 ; soubor asi nenalezen - pou‘ije se
         mov       bx,ax                    ; identifik tor souboru

; ------ test, zda je tisk stejn‚ho souboru

         cmp       byte ptr ds:[Novy],0     ; m  b˜t nov˜ soubor ?
         jne       Ukladej2                 ; m  b˜t nov˜ soubor

; ------ p©esun ukazatele na konec souboru

         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h
         jmp       short Ukladej5

; ------ opˆtovn‚ uzav©en¡ souboru

Ukladej2:mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         call      ZvysSoub                 ; zv˜¨en¡ ‡¡sla souboru
         jmp       short Ukladej3           ; nov˜ pokus s dal¨¡m souborem

; ------ vytvo©en¡ nov‚ho souboru

Ukladej4:mov       ah,3ch
         xor       cx,cx                    ; atributy
         int       21h                      ; vytvo©en¡ nov‚ho souboru
         jc        Ukladej9                 ; chyba - soubor nelze vytvo©it
         mov       bx,ax

; ------ z pis dat do souboru

Ukladej5:mov       ah,40h
         mov       dx,offset Buffer
         mov       cx,ds:[NumBuff]
         int       21h

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h

Ukladej9:mov       word ptr ds:[NumBuff],0  ; zru¨en¡ dat v bufferu
         mov       word ptr ds:[CitCas],0   ; inicializace ‡¡ta‡e ‡asu
         mov       byte ptr ds:[Novy],0

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

         mov       byte ptr cs:[AktUloz],0  ; zru¨en¡ p©¡znaku operace ukl d n¡

         ret

; -----------------------------------------------------------------------------
;        Zv˜¨en¡ ‡¡sla souboru
; -----------------------------------------------------------------------------

ZvysSoub:push      si
         mov       si,ds:[AdrSoub]
ZvysSou1:inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"9"+1
         jne       ZvysSou2
         mov       byte ptr ds:[si],"0"
         dec       si
         jmp       short ZvysSou1
ZvysSou2:pop       si
         ret


         EVEN                               ; zaokrouhlen¡ na sudou adresu


buffer   label     byte                     ; za‡ tek bufferu dat

; *****************************************************************************
;
;        instalace
;
; *****************************************************************************

Instal:  mov       dx,offset uvTxt
         mov       ah,9
         int       21h

; ------ instalace obsluhy INT 08h

         cli                                ; z kaz p©eru¨en¡

         mov       ax,3508h                 ; funkce poskytnut¡ adresy INT 08h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr [Old08],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [Old08+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset Int08          ; vlastn¡ obsluha INT 08h
         mov       ax,2508h                 ; funkce nastaven¡ adresy INT 08h
         int       21h                      ; nastaven¡ adresy INT 08h

; ------ instalace p©eru¨en¡ INT 17h

         mov       ax,3517h                 ; funkce poskytnut¡ adresy INT 17h
         int       21h                      ; poskytnut¡ adresy INT 17h
         mov       word ptr [old17],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old17+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int17          ; vlastn¡ obsluha INT 17h
         mov       ax,2517h                 ; funkce nastaven¡ adresy INT 17h
         int       21h                      ; nastaven¡ adresy INT 17h

; ------ instalace p©eru¨en¡ INT 28h

         mov       ax,3528h                 ; funkce poskytnut¡ adresy INT 28h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr [old28],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old28+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int28          ; vlastn¡ obsluha INT 28h
         mov       ax,2528h                 ; funkce nastaven¡ adresy INT 28h
         int       21h                      ; nastaven¡ adresy INT 28h

; ------ instalace p©¡znaku aktivity DOS

         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku aktivity DOS
         mov       word ptr [aktiv21],bx    ; adresa p©¡znaku aktivity DOS
         mov       word ptr [aktiv21+2],es  ; segment p©¡znaku aktivity DOS

         sti                                ; povolen¡ p©eru¨en¡

         push      cs
         pop       es

; ------ £schova aktivn¡ho adres ©e a disku

         mov       ah,19h                   ; funkce poskytnut¡ disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         add       byte ptr ds:[Soubor],al  ; ozna‡en¡ aktivn¡ho disku
         mov       ah,47h                   ; funkce poskytnut¡ adres ©e
         mov       dl,0                     ; aktivn¡ disk
         mov       si,offset Soubor + 3     ; buffer k na‡ten¡ adres ©e
         int       21h                      ; poskytnut¡ aktivn¡ho adres ©e
         dec       si
Inst3:   inc       si                       ; zv˜¨en¡ ukazatele adres ©e
         cmp       byte ptr ds:[si],0       ; je konec jm‚na adres ©e ?
         jne       Inst3                    ; nalezen¡ konce adres ©e
         cmp       byte ptr ds:[si-1],"\"   ; je to z kladn¡ adres © ?
         je        Inst4                    ; je to z kladn¡ adres ©
         mov       byte ptr ds:[si],"\"     ; ozna‡en¡ konce adres ©e
         inc       si                       ; p©esko‡en¡ znaku "\"
Inst4:   mov       di,si                    ; adresa k ulo‘en¡ jm‚na souboru
         mov       si,offset Soubor0        ; jm‚no souboru
         mov       cx,offset(Soubor1-Soubor0)
         cld
         rep       movsb                    ; p©enos jm‚na souboru
         sub       di,6                     ; adresa konce ‡¡sla
         mov       ds:[AdrSoub],di          ; adresa ‡¡sla souboru

         mov       dx,offset(Buffer+BufSize+600) ; konec programu
         int       27h                      ; instalace jako rezidentn¡

soubor0  db        'SAVE0001.DAT',0         ; pracovn¡ soubor
soubor1  label     byte


UvTxt    db        'SavePRN V1.0 - tisk do souboru; (c) Miroslav Nemecek',13,10,'$'

code     ends
         end       start


; *****************************************************************************
;
;                   Zvò®en° kapacity disket 360 KB
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ zobrazen° £vodn°ho textu

Start:   push      cs
         pop       ds
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ nalezen° oznaáen° disku s disketou

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         xor       cx,cx
         mov       cl,es:[si-1]             ; poáet znakñ p©°kazovÇho ©†dku
Start1:  jcxz      Start4                   ; nen° nic zad†no
         mov       al,es:[si]               ; naáten° dal®°ho znaku
         inc       si
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "                   ; oddàlovaá ?
         jbe       Start1                   ; je oddàlovaá
         and       al,not 20h               ; p©evod na velkÇ p°smeno
         mov       ds:[TextDisk],al         ; disk

; ------ chyba zad†n° parametrñ

         mov       dx,offset HelpTxt
         cmp       al,"A"
         jb        Start2
         cmp       al,"B"
         jbe       Start4
Start2:  mov       ah,9
         int       21h
Start3:  mov       ax,4c01h
         int       21h

; ------ zobrazen° vòzvy

Start4:  mov       dx,offset VyzvaTxt
         mov       ah,9
         int       21h                      ; zobrazen° vòzvy

; ------ áek†n° na stisk kl†vesy

         mov       ax,0c08h
         int       21h                      ; vstup s vypr†zdnàn°m
         cmp       al,13
         jne       Start3                   ; p©eru®en° programu

; ------ zobrazen° vòzvy k áek†n°

         mov       dx,offset CekTxt         ; vòzva k áek†n°
         mov       ah,9
         int       21h

; ------ naáten° pñvodn°ho BOOT sektoru

         call      GetBuff                  ; vòpoáet adresy BOOT sektoru
         xor       bx,bx                    ; sektor 0
         call      Read                     ; naáten° pñvodn°ho BOOT sektoru

; ------ kontrola, zda je to platnò disk 360 KB

         mov       dx,offset No360Txt       ; text - nen° 360 KB
         cmp       word ptr es:[0bh],200h   ; dÇlka sektoru 512 bajtñ ?
         jne       Start2                   ; neplatn† disketa
         cmp       word ptr es:[0eh],1      ; 1 rezerv. sektor ?
         jne       Start2                   ; neplatn† disketa
         cmp       byte ptr es:[10h],2      ; jsou 2 FAT ?
         jne       Start2                   ; neplatn† disketa
         cmp       word ptr es:[13h],720    ; spr†vnò poáet sektorñ celkem ?
         jne       Start2                   ; neplatn† disketa
         cmp       byte ptr es:[15h],0fdh   ; spr†vnò popisovaá mÇdia ?
         jne       Start2                   ; neplatn† disketa



; ------ nastaven° novÇho form†tu diskety

                                            ; 1 sektor ROOT
                                            ; 2*3 sektory FAT
                                            ; 3 sektory ROOT
                                            ; 710 datovòch sektorñ

         mov       byte ptr es:[0dh],1      ; velikost bloku - 1 sektor
         mov       word ptr es:[11h],30h    ; max. poloëek ROOT = 48
         mov       byte ptr es:[16h],3      ; 3 sektory na FAT

; ------ z†pis BOOT sektoru opàt na disk

         xor       bx,bx                    ; sektor 0
         call      Write                    ; z†pis sektoru na disk

; ------ inicializace tabulky FAT - 1. sektor

         mov       word ptr es:[0],0fffdh   ; inicializaán° slovo
         mov       byte ptr es:[2],0ffh     ;
         mov       cx,512-3
         mov       di,3
         xor       al,al
         cld
         rep       stosb                    ; vymaz†n° zbytku FAT

; ------ z†pis 1. sektoru tabulky FAT

         inc       bx                       ; 1. sektor 1. FAT
         call      Write                    ; z†pis 1. sektoru 1. FAT
         mov       bx,4                     ; 1. sektor 2. FAT
         call      Write                    ; z†pis 1. sektoru 2. FAT

; ------ z†pis ostatn°ch sektorñ FAT

         mov       word ptr es:[0],0
         mov       byte ptr es:[2],0
         mov       bx,2                     ; 2. sektor 1. FAT
         call      Write                    ; z†pis 2. sektoru 1. FAT
         inc       bx                       ; 3. sektor 1. FAT
         call      Write                    ; z†pis 3. sektoru 1. FAT
         mov       bx,5                     ; 2. sektor 2. FAT

; ------ z†pis zbytku FAT a z†pis ROOT

         mov       cx,2+3                   ; 2 sektory FAT a 3 sektory ROOT
Start7:  call      Write                    ; z†pis sektoru
         inc       bx                       ; zvò®en° á°sla sektoru
         loop      Start7                   ; z†pis dal®°ho sektoru

; ------ reset diskovÇho systÇmu, konec programu

         mov       ah,0dh
         int       21h                      ; resetov†n° diskovÇho systÇmu
         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        poskytnut° adresy bufferu
; -----------------------------------------------------------------------------
; VùSTUP: ES=segment s bufferem
; -----------------------------------------------------------------------------

GetBuff  PROC      NEAR

         push      ax
         mov       ax,cs
         add       ax,offset(Konec-Start+15)/16 ; segment za programem
         mov       es,ax
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         add       ax,400h
         jnc       GetBuff2
         mov       ax,es
         add       ax,40h
         mov       es,ax
GetBuff2:pop       ax
         ret

GetBuff  ENDP

; -----------------------------------------------------------------------------
;        z†pis sektoru na disk
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo sektoru
; VùSTUP:CY=chyba z†pisu
; -----------------------------------------------------------------------------

Write    PROC      NEAR

         push      ax
         mov       ah,3                     ; operace z†pisu na disk
         jmp       short Read2

Write    ENDP

; -----------------------------------------------------------------------------
;        áten° sektoru z disku
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo sektoru
;        ES=segment se sektorem
; VùSTUP:CY=chyba áten°
; -----------------------------------------------------------------------------

Read     PROC      NEAR

         push      ax
         mov       ah,2                     ; operace áten° z disku

; ------ £schova registrñ

Read2:   push      bx
         push      cx
         push      dx
         push      si

; ------ vòpoáet parametrñ disku

         push      ax
         mov       ax,bx                    ; á°slo sektoru
         xor       dx,dx
         mov       cx,9                     ; 9 sektorñ na stopu
         div       cx                       ; vòpoáet stopy a sektoru
         mov       cl,dl                    ; á°slo sektoru - 1
         inc       cl                       ; á°slo sektoru
         mov       ch,al                    ; á°slo stopy
         xor       dx,dx                    ; DX <- 0
         shr       ch,1                     ; á°slo v†lce
         adc       dh,0                     ; á°slo strany
         pop       ax
         mov       dl,ds:[TextDisk]         ; disk pro operaci
         sub       dl,"A"                   ; á°slo disku

; ------ z†pis sektoru na disk

         mov       si,3                     ; poáet pokusñ o z†pis
         xor       bx,bx                    ; offset sektoru
Read3:   push      ax
         mov       al,1
         int       13h                      ; z†pis sektoru na disk
         pop       ax
         jnc       Read9                    ; operace OK

; ------ resetov†n° disku

         push      ax
         xor       ax,ax
         int       13h                      ; resetov†n° disku
         pop       ax
         dec       si                       ; sn°ëen° á°taáe pokusñ
         jnz       Read3                    ; dal®° pokus o z†pis

; ------ chyba operace

         add       sp,12                    ; zru®en° obsahu z†sobn°ku
         mov       dx,offset ReadErr
         cmp       ah,2
         je        Read8
         mov       dx,offset WritErr
Read8:   mov       ah,9
         int       21h                      ; zobrazen° textu chyby
         mov       ax,4c01h
         int       21h                      ; n†vrat z programu

; ------ n†vrat registrñ

Read9:   pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Read     ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'High360K V1.10 - zvyseni kapacity disket 360K; '
         db        '(c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte disk A: nebo B: !',13,10,'$'

VyzvaTxt db        'Varovani: veskera data na diskete v mechanice '
TextDisk db        'A:',13,10
         db        '          budou znicena (<Enter>=pokracovani) !',13,10,'$'

ReadErr  db        'Chyba cteni z diskety !',13,10,'$'
WritErr  db        'Chyba zapisu na disketu !',13,10,'$'

CekTxt   db        'Cekejte ...',13,'$'

No360Txt db        'Neni disketa s formatem 360 KB !',13,10,'$'

Konec    label     near                     ; konec programu

Buff     db        0f000h dup(?)            ; rezerva pro buffery

Code     ENDS

zasob    segment   stack
         dw        1000h dup(?)
zasob    ends

         END       Start

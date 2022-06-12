Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ "Pozdrav" ladi‡–m program–

Start:   db        '****************',13,10
         db        ' KUK_NA_STREJDU',13,10
         db        '**************** ',13,10,10

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

         mov       si,81h
         mov       bl,ds:[si-1]
         mov       bh,0
         mov       ds:[si+bx],bh

; ------ nalezen¡ za‡ tku ozna‡en¡ disku

         cld
Start1:  lodsb
         cmp       al," "
         je        Start1
         cmp       al,9
         je        Start1

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        Start2
         cmp       al,"z"
         ja        Start2
         sub       al,32

; ------ zad n¡ disku

Start2:  mov       ds:[VyzvaTx1],al
         sub       al,"A"
         jc        Chyba
         mov       ds:[Disk],al
         cmp       al,1
         jbe       Start3

; ------ zobrazen¡ n povˆdy

Chyba:   mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         int       20h

; ------ nalezen¡ za‡ tku zad n¡ kapacity

Start3:  lodsb
         cmp       al," "
         je        Start3
         cmp       al,9
         je        Start3
         cmp       al,":"
         je        Start3

; ------ test, zda je znak ‡¡slice

Start4:  sub       al,"0"
         jb        Start6
         cmp       al,9
         ja        Start6

; ------ p©id n¡ ‡¡slice ke st©ada‡i

         push      ax
         mov       ax,10
         mul       word ptr ds:[Kapacita]
         or        dx,dx
         jz        Start5
         mov       ax,-1
Start5:  mov       ds:[Kapacita],ax
         pop       ax
         mov       ah,0
         add       ds:[Kapacita],ax
         jnc       Start3
         mov       word ptr ds:[Kapacita],-1
         jmp       short Start3

; ------ test, zda bylo nˆco zad no

Start6:  cmp       word ptr ds:[Kapacita],0
         je        Chyba

; ------ zobrazen¡ v˜zvy

         mov       dx,offset VyzvaTxt
         mov       ah,9
         int       21h

; ------ ‡ek n¡ na stisk kl vesy

         mov       ax,0c08h
         int       21h                      ; ‡ek n¡ na stisk kl vesy
         cmp       al,13
         je        Start7
         int       20h

Start7:  mov       dx,offset FormTxt
         mov       ah,9
         int       21h

; ------ £vodn¡ RESET disk–

         mov       ah,0dh
         int       21h

; ------ na‡ten¡ BOOT sektoru z mechaniky

         xor       dx,dx                    ; ‡¡slo BOOT sektoru
         call      ReadSekt                 ; na‡ten¡ BOOT sektoru
         jnc       Start80
         jmp       StartX                   ; chyba

; ------ oprava kapacity

Start80: mov       ax,ds:[Kapacita]
         shl       ax,1
         jnc       Start8
         mov       ax,-1
Start8:  mov       ds:[MaxSekt],ax          ; po‡et sektor– disku

; ------ po‡et sektor– na ROOT

         mov       ax,ds:[MaxRoot]
         mov       cl,4
         shr       ax,cl
         mov       ds:[SektRoot],ax         ; po‡et sektor– na ROOT

         mov       al,ds:[TypDisk]
         mov       ds:[Idnt],al

; ------ omezen¡ po‡tu sektor– podle v lc–

         mov       ax,ds:[SektTrck]         ; po‡et sektor– na stopu
         mul       word ptr ds:[NumHead]    ; po‡et sektor– na v lec
         mov       bx,1024                  ; maxim ln¡ po‡et v lc–
         mul       bx                       ; maxim ln¡ po‡et sektor–
         or        dx,dx
         jnz       Start81
         cmp       ax,ds:[MaxSekt]
         jae       Start81
         mov       ds:[MaxSekt],ax          ; omezen¡ po‡tu sektor–

; ------ stanoven¡ velikosti aloka‡n¡ho bloku

Start81: mov       byte ptr ds:[SektBlok],2 ; pro disky DD 2 sektory na blok
         cmp       word ptr ds:[Kapacita],1000 ; asi tak disketa HD
         jb        Start83                  ; je disketa DD
         mov       byte ptr ds:[SektBlok],1 ; pro diskety HD 1 sektor na blok
Start82: mov       bl,ds:[SektBlok]         ; po‡et sektor– na blok
         mov       bh,0
         mov       ax,ds:[MaxSekt]          ; sektor– celkem
         sub       ax,ds:[SektRoot]         ; ode‡ten¡ asi tak sektory pro ROOT
         xor       dx,dx
         div       bx                       ; v˜po‡et po‡tu blok–
         cmp       ax,0ff4h                 ; asi tak maxim lnˆ blok–
         jbe       Start83                  ; po‡et blok– je OK
         shl       byte ptr ds:[SektBlok],1 ; po‡et sektor– na blok * 2
         jmp       short Start82            ; dal¨¡ pokus

; ------ stanoven¡ po‡tu sektor– pro FAT

Start83: mov       word ptr ds:[SektFat],0  ; po‡et sektor– na FAT
Start84: inc       word ptr ds:[SektFat]    ; zv˜¨en¡ po‡tu FAT
         mov       ax,ds:[MaxSekt]          ; po‡et sektor– celkem
         sub       ax,ds:[RezSekt]          ; ode‡ten¡ rezervovan˜ch sektor–
         sub       ax,ds:[SektFat]          ; ode‡ten¡ FAT 1
         sub       ax,ds:[SektFat]          ; ode‡ten¡ FAT 2
         sub       ax,ds:[SektRoot]         ; ode‡ten¡ ROOT
         xor       dx,dx

         mov       bl,ds:[SektBlok]         ; po‡et sektor– na blok
         mov       bh,0
         div       bx                       ; v˜po‡et po‡tu blok–
         inc       ax
         inc       ax                       ; po‡et blok–

         mov       bx,ax
         shl       ax,1
         add       ax,bx                    ; po‡et blok– * 3 = po‡et tetr d
         shr       ax,1                     ; po‡et bajt– na FAT
         add       ax,511                   ; zaokrouhlen¡
         shr       ah,1                     ; AH = po‡et sektor–
         cmp       ah,byte ptr ds:[SektFat] ; vyhovuje ji‘ po‡et sektor– ?
         ja        Start84                  ; po‡et sektor– je je¨tˆ mal˜

Start88: mov       ax,ds:[SektFat]
         mov       ds:[SektFat2],ax

; ------ z pis BOOT sektoru

         xor       dx,dx
         call      WritSekt                 ; z pis BOOT sektoru
         jc        StartX

; ------ z pis FAT 1 a FAT 2

         mov       bh,2
         mov       dx,1

Start882:cld
         mov       al,ds:[Idnt]
         mov       di,offset Buffer
         stosb
         mov       ax,-1
         stosw
         mov       cx,512-3
         mov       al,0
         rep       stosb

         mov       bl,byte ptr ds:[SektFat2]

Start89: call      WritSekt
         jc        StartX

         mov       word ptr ds:[Buffer],0
         mov       byte ptr ds:[Buffer+2],0
         dec       bl
         jnz       Start89

         dec       bh
         jnz       Start882

; ------ z pis ROOT

         mov       bx,ds:[SektRoot]
Start892:call      WritSekt
         jc        StartX
         dec       bx
         jnz       Start892

         mov       dx,offset OKTxt
         jmp       short StartY

StartX:  mov       dx,offset WritTxt

StartY:  mov       ah,9
         int       21h

         mov       ah,0dh
         int       21h                      ; reset disk–
         int       20h

; -----------------------------------------------------------------------------
;        na‡ten¡ sektoru DX
; -----------------------------------------------------------------------------

ReadSekt PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         mov       ds:[Zasob],sp
         mov       al,ds:[Disk]
         mov       bx,offset Buffer
         mov       cx,1
         int       25h                      ; na‡ten¡ sektoru
         mov       sp,ds:[Zasob]

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       dx
         ret

ReadSekt ENDP

Zasob    dw        0

; -----------------------------------------------------------------------------
;        z pis sektoru DX
; -----------------------------------------------------------------------------

WritSekt PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         mov       ds:[Zasob],sp
         mov       al,ds:[Disk]
         mov       bx,offset Buffer
         mov       cx,1
         int       26h                      ; z pis sektoru
         mov       sp,ds:[Zasob]

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       dx
         ret

WritSekt ENDP

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

UvTxt    db        'FDMEGA V1.0 - zvyseni kapacity disket; (c) April Soft <<< FREEWARE >>>',13,10,'$'
HelpTxt  db        '   Zadejte mechaniku A: nebo B: a pozadovanou kapacitu v [KB].',13,10
         db        '   Napr. zadani "FDMEGA B: 2880" zformatuje disketu 1.44 MB na 2.88 MB !',13,10,'$'

VyzvaTxt db        13,10,'Vlozte do mechaniky '
VyzvaTx1 db        'A: cistou NAFORMATOVANOU disketu a stisknete ENTER.',13,10
         db        'VAROVANI .... vsechna data diskety budou znicena !',13,10,'$'

FormTxt  db        13,10,'Preformatovavam disketu na novou kapacitu.',13,10,'$'

OKTxt    db        13,10,' >>> Kapacita diskety zvysena OK. <<<',13,10
         db        'Pred pouzitim disketu vyjmete nejdrive z mechaniky a opet ji zasunte zpet.',13,10
         db        'Preji mnoho radosti s vyssi kapacitou...',13,10,'$'

WritTxt  db        13,10,'Chyba zapisu !',13,10,'$'

Kapacita dw        0                        ; zadan  kapacita v KB
Disk     db        0                        ; ‡¡slo disku

SektFat2 dw        ?                        ; po‡et sektor– na FAT
SektRoot dw        ?                        ; po‡et sektor– na ROOT
Idnt     db        ?                        ; identifik tor disku

Buffer   label     byte                     ; buffer sektoru
         db        3 dup(?)                 ; instrukce skoku
         db        8 dup(?)                 ; identifik tor
ByteSekt dw        ?                        ; po‡et bajt– na sektor
SektBlok db        ?                        ; po‡et sektor– na blok
RezSekt  dw        ?                        ; po‡et rezervovan˜ch sektor–
NumFat   db        ?                        ; po‡et tabulek FAT
MaxRoot  dw        ?                        ; max. po‡et polo‘ek ROOT
MaxSekt  dw        ?                        ; celkov˜ po‡et sektor– disku
TypDisk  db        ?                        ; typ disku
SektFat  dw        ?                        ; po‡et sektor– na FAT
SektTrck dw        ?                        ; po‡et sektor– na stopu
NumHead  dw        ?                        ; po‡et hlav
HidSekt  dd        ?                        ; po‡et skryt˜ch sektor–
MaxSektX dd        ?                        ; celkov˜ po‡et sektor– DWORD
         db        ?
         db        ?
         db        ?                        ; 29h

Code     ENDS
         END       Start

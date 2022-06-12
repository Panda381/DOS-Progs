
; *****************************************************************************
;
;                 Zav dˆc¡ sektor opera‡n¡ho syst‚mu TDOS V2.11
;                               (disketa 360 KB)
;
;  (zav d¡ se ze sektoru 0 logick‚ho disku na adresu 0000:7c00h; zajist¡
;  zaveden¡ modulu syst‚mu TBIOS.SYS od adresy 0070:0000h, v BP p©ed v 
;         ‡¡slo relativn¡ho sektoru z kladn¡ho adres ©e ROOT)
;
; *****************************************************************************

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       0

Start:   jmp       Start0                   ; start zavadˆ‡e syst‚mu

         db        'T V2.11 '               ; identifikace firmy a verze OS

SektSize dw        512                      ; velikost sektoru (v bajtech)
ClusSize db        2                        ; velikost bloku (v sektorech)
RezSekt  dw        1                        ; po‡et rezervovan˜ch sektor– (BOOT)
NumFAT   db        2                        ; po‡et aloka‡n¡ch tabulek FAT
MaxRoot  dw        7*16                     ; max. po‡et polo‘ek adres ©e ROOT
NumSekt  dw        2*40*9                   ; celkov˜ po‡et sektor– disku
IdentMed db        0fdh                     ; popisova‡ m‚dia
SektFAT  dw        2                        ; po‡et sektor– v jedn‚ tabulce FAT
SektTrck dw        9                        ; po‡et sektor– na stopu
NumHead  dw        2                        ; po‡et hlav disku
HidSekt  dd        0                        ; po‡et skryt˜ch sektor– disku

CitRead  db        5                        ; ‡¡ta‡ pokus– o ‡ten¡ disku
NumRead  db        10                       ; po‡et sektor– ke ‡ten¡
AbsSekt  dw        0                        ; absolutn¡ ‡¡slo sektoru

; -----------------------------------------------------------------------------
;        Start zavadˆ‡e syst‚mu
; -----------------------------------------------------------------------------

; ------ inicializace segment–

Start0:  cld                                ; p©¡znak smˆru nahoru
         cli                                ; z kaz p©eru¨en¡
         mov       dx,7c0h                  ; segment k ulo‘en¡ disk. parametr–
         mov       sp,7c00h                 ; offset z sobn¡ku
         xor       ax,ax                    ; AX <- 0 segment zavadˆ‡e
         mov       ss,ax                    ; SS <- 0 segment zavadˆ‡e
         mov       es,ax                    ; ES <- 0 segment zavadˆ‡e
         sti                                ; povolen¡ p©eru¨en¡

; ------ na‡ten¡ tabulky diskov˜ch parametr–

         lds       si,es:[4*1eh]            ; ukazatel disk. parametr– INT 1Eh
         push      es                       ; £schova segmentu INT 1Eh
         mov       es,dx                    ; segment k ulo‘en¡ disk. param.
         mov       di,300h                  ; offset k ulo‘en¡ (za zavadˆ‡em)
         mov       cx,11                    ; d‚lka tabulky disk. parametr–
         rep       movsb                    ; p©enos tabulky disk. parametr–
         pop       es                       ; n vrat segmentu INT 1Eh

; ------ nastaven¡ vlastn¡ tabulky parametr–

         mov       ds,dx                    ; datov˜ segment 7c0h (se zavadˆ‡em)
         mov       bx,300h                  ; offset tabulky disk. parametr–
         mov       byte ptr ds:[bx+4],0fh   ; posledn¡ sektor stopy = 15
         mov       es:[4*1eh],bx            ; offset vlastn¡ tabulky parametr–
         mov       es:[4*1eh+2],ds          ; segment vlastn¡ tabulky parametr–

; ------ nastaven¡ ‡¡sla disku

         mov       dl,ds:[BootDisk]         ; disk pro zaveden¡ syst‚mu
         test      dl,80h                   ; je to pevn˜ disk ?
         jnz       Boot2                    ; je to pevn˜ disk
         mov       al,es:[43fh]             ; stav motor– disket. mechanik
         and       al,0fh                   ; stav motor– disket. mechanik
         xor       dx,dx                    ; ukazatel ‡¡sla disku
Boot1:   inc       dx                       ; zv˜¨en¡ ukazatele ‡¡sla disku
         shr       al,1                     ; je motor mechaniky zapnut ?
         jnc       Boot1                    ; motor nen¡ zapnut
         dec       dx                       ; n vrat ‡¡sla mechaniky
Boot2:   mov       ds:[BootDisk],dl         ; disk pro zaveden¡ syst‚mu

; ------ jeden pokus o na‡ten¡ syst‚mu

Boot3:   xor       ax,ax                    ; AX <- 0
         int       13h                      ; reset diskov‚ho syst‚mu
         jc        Boot7                    ; chyba - dal¨¡ pokus o zaveden¡
         call      ReadDir                  ; na‡ten¡ adres ©e
         jc        Boot7                    ; chyba - dal¨¡ pokus
         mov       bx,700h                  ; adresa k ulo‘en¡ TBIOS.SYS

; ------ na‡ten¡ ‡ sti TBIOS.SYS

Boot4:   call      GetSekt                  ; p©epo‡et abs. sektoru na BIOS
         mov       ax,ds:[SektTrck]         ; po‡et sektor– na stopu
         sub       al,cl                    ; po‡et zbyl˜ch sektor– na stopˆ
         inc       ax                       ; po‡et zbyl˜ch sektor–
         cmp       al,ds:[NumRead]          ; je po‡et vˆt¨¡ ne‘ po‘adovan˜ ?
         jbe       Boot5                    ; nen¡ vˆt¨¡ ne‘ po‘adovan˜
         mov       al,ds:[NumRead]          ; po‘adovan˜ po‡et sektor–
Boot5:   push      ax                       ; £schova po‡tu sektor– ke ‡ten¡
         mov       ah,2                     ; ‡ten¡ sektor–
         int       13h                      ; na‡ten¡ sektor– z jedn‚ stopy
         jc        Boot7                    ; chyba - dal¨¡ pokus
         pop       ax                       ; n vrat po‡tu po‘adovan˜ch sektor–

; ------ zv˜¨en¡ ukazatele sektor–

         sub       ds:[NumRead],al          ; sn¡‘en¡ po‘adovan‚ho po‡tu sektor–
         jz        Boot6                    ; jsou ji‘ v¨echny sektory
         xor       ah,ah                    ; AX <- po‡et sektor–
         add       ds:[AbsSekt],ax          ; zv˜¨en¡ ‡¡sla sektoru ke ‡ten¡
         shl       al,1                     ; po‡et sektor– * 2
         add       bh,al                    ; zv˜¨en¡ ukl dac¡ adresy
         jmp       short Boot4              ; na‡ten¡ TBIOS.SYS z dal¨¡ stopy

; ------ ‡ten¡ syst‚mu OK - skok do modulu TBIOS.SYS

Boot6:   mov       bx,bp                    ; po‡ te‡n¡ relativn¡ sektor ROOT
         db        0eah
         dd        00700000h                ; JMP FAR 0070:0000h

;         jmp       far ptr 00700000h       ; start modulu TBIOS.SYS

; ------ dal¨¡ pokus o ‡ten¡ syst‚mu

Boot7:   dec       byte ptr ds:[CitRead]    ; sn¡‘en¡ ‡¡ta‡e pokus– o ‡ten¡
         jz        Boot8                    ; byly ji‘ v¨echny pokusy - chyba
         jmp       short Boot3              ; dal¨¡ pokus o na‡ten¡ syst‚mu

; ------ chyba zaveden¡ syst‚mu

Boot8:   mov       cx,offset(ErrTxt0-ErrTxt)+2 ; d‚lka textu chybov‚ho hl ¨en¡
         mov       si,offset ErrTxt         ; chybov‚ hl ¨en¡ "Disk Boot ..."
         call      DispTxt                  ; zobrazen¡ chybov‚ho hl ¨en¡
Boot9:   jmp       short Boot9              ; zablokov n¡ syst‚mu

; -----------------------------------------------------------------------------
;        Chyba - nen¡ opera‡n¡ syst‚m
; -----------------------------------------------------------------------------

NoSyst:  mov       cx,offset(SysTxt0-SysTxt) ; d‚lka textu chybov‚ho hl ¨en¡
         mov       si,offset SysTxt         ; chybov‚ hl ¨en¡ "Non-System ..."
         call      DispTxt                  ; zobrazen¡ chybov‚ho hl ¨en¡
         xor       ah,ah                    ; AH <- 0
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         int       19h                      ; opakov n¡ zav dˆn¡ syst‚mu

; -----------------------------------------------------------------------------
;        Na‡ten¡ adres ©e
; -----------------------------------------------------------------------------

; ------ v˜po‡et po‡ te‡n¡ho sektoru ROOT

ReadDir: mov       al,byte ptr ds:[SektFAT] ; po‡et sektor– v jedn‚ FAT
         mul       byte ptr ds:[NumFAT]     ; v˜po‡et celkem sektor– v¨ech FAT
         add       ax,ds:[RezSekt]          ; p©i‡ten¡ rezervovan˜ch sektor–
         mov       bp,ax                    ; po‡ te‡n¡ sektor ROOT
         add       ax,word ptr ds:[HidSekt] ; p©i‡ten¡ skryt˜ch sektor–
         mov       ds:[AbsSekt],ax          ; absolutn¡ sektor ROOT

; ------ na‡ten¡ sektoru ROOT adres ©e

         mov       bx,500h                  ; ukl dac¡ adresa pro ‡ten¡
         call      GetSekt                  ; p©epo‡et abs. sektoru na BIOS
         mov       ax,201h                  ; ‡ten¡ 1 sektoru
         int       13h                      ; ‡ten¡ 1. sektoru adres ©e
         jc        ReadDir1                 ; chyba ‡ten¡ sektoru

; ------ kontrola, jestli je prvn¡m souborem TBIOS.SYS

         mov       cx,11                    ; d‚lka jm‚na souboru TBIOS.SYS
         mov       si,offset NameIO         ; jm‚no souboru TBIOS.SYS
         mov       di,500h                  ; na‡ten˜ adres © - prvn¡ polo‘ka
         repe      cmpsb                    ; porovn n¡ jm‚na prvn¡ho souboru
         jne       NoSyst                   ; nen¡ TBIOS.SYS - chyba syst‚mu

; ------ kontrola, zda je druh˜ soubor TDOS.SYS

         mov       cx,11                    ; d‚lka jm‚na souboru TDOS.SYS
         mov       di,520h                  ; druh  polo‘ka adres ©e
         repe      cmpsb                    ; porovn n¡ jm‚na druh‚ho souboru
         jne       NoSyst                   ; nen¡ TDOS.SYS - chyba syst‚mu

; ------ zji¨tˆn¡ po‡tu sektor– ke ‡ten¡

         mov       ax,ds:[SektSize]         ; velikost sektoru (v bajtech)
         xchg      ah,al                    ; AX = d‚lka sektoru v 256 Bajtech
         mul       byte ptr ds:[ClusSize]   ; velikost bloku v 256 Bajtech
         xchg      ah,al                    ; AX = velikost bloku v bajtech
         dec       ax                       ; po‡et bajt– na blok - 1
         mov       bx,ax                    ; po‡et bajt– na blok - 1
         mov       ax,es:[51ch]             ; velikost souboru TBIOS.SYS
         add       ax,bx                    ; zaokrouhlen¡ na blok
         shr       ah,1                     ; p©epo‡et velikosti na sektory
         xor       al,al                    ; AL <- 0
         xchg      ah,al                    ; AX = po‡et sektor– TBIOS.SYS
         mov       ds:[NumRead],al          ; po‡et sektor– TBIOS.SYS ke ‡ten¡

; ------ v˜po‡et prvn¡ho datov‚ho sektoru

         mov       ax,32                    ; velikost polo‘ky adres ©e
         mul       word ptr ds:[MaxRoot]    ; velikost adres ©e ROOT v bajtech
         add       ax,511                   ; zaokrouhlen¡ na sektor
         shr       ah,1                     ; po‡et sektor– ROOT
         xor       al,al                    ; AL <- 0
         xchg      ah,al                    ; AX = po‡et sektor– ROOT
         add       ds:[AbsSekt],ax          ; ‡¡slo prvn¡ho datov‚ho sektoru
         add       bp,ax                    ; zv˜¨en¡ ukazatele sektor–
         clc                                ; p©¡znak - operace OK
ReadDir1:ret

; -----------------------------------------------------------------------------
;        P©epo‡et abolutn¡ho sektoru na sektor BIOS
; -----------------------------------------------------------------------------

GetSekt: mov       ax,ds:[AbsSekt]          ; absolutn¡ ‡¡slo sektoru ke ‡ten¡
         xor       dx,dx                    ; DX:AX = ‡¡slo sektoru
         div       word ptr ds:[SektTrck]   ; v˜po‡et stopy a sektoru na stopˆ
         inc       dx                       ; ‡¡slo sektoru na stopˆ
         push      dx                       ; £schova ‡¡sla sektoru
         xor       dx,dx                    ; DX:AX = ‡¡slo stopy na disku
         div       word ptr ds:[NumHead]    ; v˜po‡et ‡¡sla v lce a hlavy
         xchg      dh,dl                    ; DH <- ‡¡slo hlavy
         mov       dl,ds:[BootDisk]         ; disk pro zaveden¡ syst‚mu
         mov       cl,6                     ; po‡et rotac¡ pro p©evod
         shl       ah,cl                    ; nejvy¨¨¡ 2 bity ‡¡sla v lce
         pop       cx                       ; CL <- ‡¡slo sektoru
         or        cl,ah                    ; ‡¡slo sektoru + 2 bity ‡¡sla v lce
         mov       ch,al                    ; CH <- ni‘¨¡ch 8 bit– ‡¡sla v lce
         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ textu chybov‚ho hl ¨en¡
; -----------------------------------------------------------------------------

DispTxt: lodsb                              ; ‡ten¡ znaku k zobrazen¡
         mov       ah,0eh                   ; funkce zobrazen¡ znaku
         mov       bx,7                     ; barva textu b¡l , str nka 0
         int       10h                      ; zobrazen¡ chybov‚ho textu
         loop      DispTxt                  ; zobrazen¡ dal¨¡ho znaku textu
         ret

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

NameIO   db        'TBIOS   SYS'            ; jm‚no souboru TBIOS.SYS
NameDOS  db        'TDOS    SYS'            ; jm‚no souboru TDOS.SYS


ErrTxt   db        13,10,'Disk Boot Failure'; chyba zaveden¡ syst‚mu
ErrTXt0  LABEL     byte

SysTxt   db        13,10
         db        'Non-System disk or disk error'
         db        13,10,'Replace and press any key when ready'
         db        13,10
SysTxt0  LABEL     byte


LicTxt   db        'TOSHIBA V2.21'          ; licen‡n¡ text

         db        18 dup(0)



BootDisk db        0                        ; disk pro zaveden¡ syst‚mu

         dw        0aa55h


code     ENDS
         END       Start
